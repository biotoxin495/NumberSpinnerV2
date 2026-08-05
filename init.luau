--!nonstrict
--  _   _                 _               ____        _
-- | \ | |_   _ _ __ ___ | |__   ___ _ __/ ___| _ __ (_)_ __  _ __   ___ _ __
-- |  \| | | | | '_ ` _ \| '_ \ / _ \ '__\___ \| '_ \| | '_ \| '_ \ / _ \ '__|
-- | |\  | |_| | | | | | | |_) |  __/ |   ___) | |_) | | | | | | | |  __/ |
-- |_| \_|\__,_|_| |_| |_|_.__/ \___|_|  |____/| .__/|_|_| |_|_| |_|\___|_|
--        ____                                 |_|
-- __   _|___ \
-- \ \ / / __) |
--  \ V / / __/
--   \_/ |_____|

-- made with ❤️ by biotoxin495

-- A Roblox UI module that turns any TextLabel into an animated number/text spinner.
-- Each character is placed in its own slot and animated via UIPageLayout for a reel-style effect.
--
-- Usage:
--   local NumberSpinnerV2 = require(path.to.NumberSpinnerV2)
--   local spinner = NumberSpinnerV2.Attach(textLabel, options)
--
--   spinner:SetValue(1234, true)       -- animate to a number
--   spinner:SetText("Rank A", true)    -- animate to arbitrary text
--   spinner:SetOptions({ Mode = "Roman" }, true) -- change options at runtime
--   spinner:Refresh(true)              -- re-render with current text
--   spinner:Destroy()                  -- cleanup and restore original TextLabel
--
-- Static helpers:
--   NumberSpinnerV2.FormatValue(value, options) -- format a number with separators/abbreviations
--   NumberSpinnerV2.ToRoman(value, options)     -- convert a number to roman numerals
--
-- Options (all optional, see DEFAULT_OPTIONS for defaults):
--   Animation:       Duration, SlotResizeDuration, SpinMode ("Full"|"SingleStep"|"Reel"),
--                    ReelStepDuration, ReelMaxFinishSpread, EasingStyle, EasingDirection, Circular
--   Formatting:      Mode ("Number"|"Roman"|"Text"|"Characters"), Separator, DecimalPlaces,
--                    ForceDecimals, DecimalSeparator, Abbreviations ({[1e3]="K"}),
--                    AbbreviationDecimalPlaces, ForceAbbreviationDecimals
--   Roman:           RomanZero, RomanMax, RomanAllowLarge
--   Affixes:         Prefix, Suffix, IconPrefix, IconSuffix, AffixSpacing, IconAffixSpacing
--   Character layout: CharacterPadding, PunctuationPaddingScale, PunctuationWidthScale,
--                    LetterWidthPadding, LetterEdgeBleed, UniformLetterSlots,
--                    SymbolWidthPadding, SlotAlignment ("Auto"|"Left"|"Right"), CharacterOrder,
--                    CharacterReel (string or array used by SpinMode = "Reel")
--   Visual:          ApplyStrokeToChars
--   Bounce:          BounceOnChange, BounceScale, BounceDuration, BounceReturnDuration,
--                    BounceEasingStyle, BounceEasingDirection
--   Accessibility:   RespectReducedMotion
--   TextScaled:      MinTextSize, MaxTextSize
--   Advanced:        Formatter (function(rawText, options, spinner) -> string)

local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local NumberSpinnerV2 = {}

local Spinner = {}
Spinner.__index = Spinner

local INTERNAL_HOLDER_NAME = "_NumberSpinnerV2"
local INTERNAL_STROKE_ATTRIBUTE = "_NumberSpinnerV2Stroke"

local DEFAULT_CHARACTER_REEL = {
	"-",
	"+",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	".",
	",",
	" ",
	"I",
	"V",
	"X",
	"L",
	"C",
	"D",
	"M",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
}

local DEFAULT_CHARACTER_ORDER = {}
for index, char in ipairs(DEFAULT_CHARACTER_REEL) do
	if DEFAULT_CHARACTER_ORDER[char] == nil then
		DEFAULT_CHARACTER_ORDER[char] = index
	end
end

local DEFAULT_OPTIONS = {
	-- Animation
	Duration = 0.5,
	SlotResizeDuration = 0.08,
	SpinMode = "Full", -- "Full", "SingleStep", "Reel"
	ReelStepDuration = nil,
	ReelMaxFinishSpread = 1,
	EasingStyle = Enum.EasingStyle.Quad,
	EasingDirection = Enum.EasingDirection.Out,
	Circular = false,

	-- Formatting
	Mode = "Number", -- "Number", "Roman", "Text", "Characters"
	Separator = ",",
	DecimalPlaces = 0,
	ForceDecimals = false,
	DecimalSeparator = ".",

	Abbreviations = {}, -- {[1e3] = "K", [1e6] = "M"}
	AbbreviationDecimalPlaces = 1,
	ForceAbbreviationDecimals = false,

	-- Roman formatting
	RomanZero = "N",
	RomanMax = 3999,
	RomanAllowLarge = false,

	-- Affixes
	Prefix = "",
	Suffix = "",
	IconPrefix = "",
	IconSuffix = "",
	AffixSpacing = 0,
	IconAffixSpacing = 4,

	-- Character layout
	CharacterPadding = 2,
	PunctuationPaddingScale = 1.5,
	PunctuationWidthScale = 0.45,
	LetterWidthPadding = 5,
	LetterEdgeBleed = 2,
	UniformLetterSlots = false,
	SymbolWidthPadding = 1,
	SlotAlignment = "Auto", -- "Auto", "Left", "Right"
	CharacterOrder = nil,
	CharacterReel = nil,

	-- Visual styling
	ApplyStrokeToChars = true,

	-- Bounce
	BounceOnChange = false,
	BounceScale = 1.08,
	BounceDuration = 0.12,
	BounceReturnDuration = 0.14,
	BounceEasingStyle = Enum.EasingStyle.Quad,
	BounceEasingDirection = Enum.EasingDirection.Out,

	-- Accessibility
	RespectReducedMotion = true,

	-- TextScaled bounds
	MinTextSize = 1,
	MaxTextSize = 100,

	-- Advanced escape hatch
	Formatter = nil, -- function(rawText, options, spinner) -> string
}

local ROMAN_DIGITS = {
	{ 1000, "M" },
	{ 900, "CM" },
	{ 500, "D" },
	{ 400, "CD" },
	{ 100, "C" },
	{ 90, "XC" },
	{ 50, "L" },
	{ 40, "XL" },
	{ 10, "X" },
	{ 9, "IX" },
	{ 5, "V" },
	{ 4, "IV" },
	{ 1, "I" },
}

local ROMAN_REFERENCE_CHARS = "IVXLCDM"

local function deepClone(value)
	if type(value) ~= "table" then
		return value
	end

	local clone = {}
	for key, childValue in pairs(value) do
		clone[key] = deepClone(childValue)
	end

	return clone
end

local function mergeOptions(baseOptions, userOptions)
	local merged = deepClone(baseOptions)

	if userOptions then
		for key, value in pairs(userOptions) do
			local correctedKey = key

			if correctedKey == "Seperator" then
				correctedKey = "Separator"
			elseif correctedKey == "DecimalPieces" then
				correctedKey = "DecimalPlaces"
			end

			merged[correctedKey] = value
		end
	end

	return merged
end

local function asNumber(value, fallback)
	local numberValue = tonumber(value)
	if numberValue == nil then
		return fallback
	end

	return numberValue
end

local function asPixels(value, fallback)
	if value == nil then
		return fallback or 0
	end

	if typeof(value) == "UDim" then
		return value.Offset
	end

	if typeof(value) == "Vector2" then
		return value.X
	end

	local numberValue = tonumber(value)
	if numberValue == nil then
		return fallback or 0
	end

	return numberValue
end

local function normalizeAssetId(value)
	if value == nil then
		return nil
	end

	if type(value) == "number" then
		if value <= 0 then
			return nil
		end

		return "rbxassetid://" .. tostring(value)
	end

	local text = tostring(value)
	if text == "" or text == "0" then
		return nil
	end

	if tonumber(text) ~= nil then
		return "rbxassetid://" .. text
	end

	return text
end

-- GetTextSize only accepts the legacy Enum.Font approximation of a label's font, which can
-- diverge from the FontFace actually used to render it (different Weight/Style, or a custom
-- font asset with no Enum.Font equivalent). Since digits are near tabular-width across weights
-- but letters vary widely, that divergence is invisible on numbers but shows up as inconsistent
-- per-letter over/under sizing in letter modes. GetTextBoundsAsync measures the real FontFace,
-- so prefer it and only fall back to the legacy measurement if it's unavailable.
local function safeTextSize(text, textSize, font, fontFace, bounds)
	text = tostring(text or "")
	textSize = math.max(1, math.floor(textSize or 1))

	if fontFace then
		local ok, result = pcall(function()
			local params = Instance.new("GetTextBoundsParams")
			params.Text = text
			params.Size = textSize
			params.Font = fontFace
			params.Width = (bounds and bounds.X and bounds.X < math.huge) and bounds.X or 1000000
			return TextService:GetTextBoundsAsync(params)
		end)

		if ok then
			return result
		end
	end

	local ok, result = pcall(function()
		return TextService:GetTextSize(text, textSize, font, bounds or Vector2.new(math.huge, math.huge))
	end)

	if ok then
		return result
	end

	return Vector2.new(#text * textSize * 0.5, textSize)
end

local function splitCharacters(text)
	text = tostring(text or "")

	local chars = {}
	local ok = pcall(function()
		for first, last in utf8.graphemes(text) do
			table.insert(chars, string.sub(text, first, last))
		end
	end)

	if ok then
		return chars
	end

	for index = 1, #text do
		table.insert(chars, string.sub(text, index, index))
	end

	return chars
end

local function isDigitCharacter(char)
	return string.match(char, "^%d$") ~= nil
end

local function isLetterCharacter(char)
	return string.match(char, "^%a$") ~= nil
end

local function isWhitespaceCharacter(char)
	return string.match(char, "^%s$") ~= nil
end

local function isPunctuationCharacter(char)
	return char == "." or char == "," or char == ":" or char == ";"
end

local function trimTrailingZeroes(text)
	text = tostring(text)

	if string.find(text, ".", 1, true) == nil then
		return text
	end

	text = string.gsub(text, "0+$", "")
	text = string.gsub(text, "%.$", "")

	if text == "-0" then
		return "0"
	end

	return text
end

local function addThousandsSeparator(integerPart, separator)
	separator = tostring(separator or "")
	if separator == "" then
		return integerPart
	end

	local groups = {}

	while #integerPart > 3 do
		table.insert(groups, 1, string.sub(integerPart, -3))
		integerPart = string.sub(integerPart, 1, #integerPart - 3)
	end

	if integerPart ~= "" then
		table.insert(groups, 1, integerPart)
	end

	return table.concat(groups, separator)
end

local function formatNumber(value, options)
	local numberValue = tonumber(value)

	if numberValue == nil then
		return tostring(value)
	end

	if numberValue ~= numberValue then
		return "NaN"
	end

	if numberValue == math.huge then
		return "Inf"
	end

	if numberValue == -math.huge then
		return "-Inf"
	end

	local abbreviation = ""
	local abbreviationThreshold = nil
	local abbreviations = options.Abbreviations or {}

	for threshold, suffix in pairs(abbreviations) do
		local numericThreshold = tonumber(threshold)

		if numericThreshold and numericThreshold > 0 then
			if math.abs(numberValue) >= numericThreshold then
				if abbreviationThreshold == nil or numericThreshold > abbreviationThreshold then
					abbreviationThreshold = numericThreshold
					abbreviation = tostring(suffix or "")
				end
			end
		end
	end

	local displayedNumber = numberValue
	local decimalPlaces = math.max(0, math.floor(asNumber(options.DecimalPlaces, 0)))
	local forceDecimals = options.ForceDecimals == true

	if abbreviationThreshold ~= nil then
		displayedNumber = numberValue / abbreviationThreshold
		decimalPlaces = math.max(0, math.floor(asNumber(options.AbbreviationDecimalPlaces, decimalPlaces)))
		forceDecimals = options.ForceAbbreviationDecimals == true
	end

	local formatted = string.format("%." .. tostring(decimalPlaces) .. "f", displayedNumber)

	if not forceDecimals then
		formatted = trimTrailingZeroes(formatted)
	end

	if formatted == "-0" then
		formatted = "0"
	end

	local decimalSeparator = tostring(options.DecimalSeparator or ".")
	local integerPart = formatted
	local decimalPart = nil

	local dotIndex = string.find(formatted, ".", 1, true)
	if dotIndex then
		integerPart = string.sub(formatted, 1, dotIndex - 1)
		decimalPart = string.sub(formatted, dotIndex + 1)
	end

	local sign = ""
	if string.sub(integerPart, 1, 1) == "-" then
		sign = "-"
		integerPart = string.sub(integerPart, 2)
	end

	integerPart = addThousandsSeparator(integerPart, options.Separator)

	local result = sign .. integerPart

	if decimalPart and decimalPart ~= "" then
		result ..= decimalSeparator .. decimalPart
	end

	result ..= abbreviation

	return result
end

local function toRoman(value, options)
	local numberValue = tonumber(value)
	if numberValue == nil then
		return tostring(value)
	end

	if numberValue ~= numberValue then
		return "NaN"
	end

	if numberValue == math.huge then
		return "Inf"
	end

	if numberValue == -math.huge then
		return "-Inf"
	end

	local sign = ""
	if numberValue < 0 then
		sign = "-"
	end

	local integer = math.floor(math.abs(numberValue) + 0.5)

	if integer == 0 then
		return tostring(options.RomanZero or "N")
	end

	local romanMax = asNumber(options.RomanMax, 3999)
	if integer > romanMax and options.RomanAllowLarge ~= true then
		return sign .. tostring(integer)
	end

	local result = ""

	for _, pair in ipairs(ROMAN_DIGITS) do
		local amount = pair[1]
		local symbol = pair[2]

		while integer >= amount do
			result ..= symbol
			integer -= amount
		end
	end

	return sign .. result
end

local function getUITextSizeConstraintBounds(textLabel, options)
	local minTextSize = math.max(1, math.floor(asNumber(options.MinTextSize, 1)))
	local maxTextSize = math.max(minTextSize, math.floor(asNumber(options.MaxTextSize, 100)))

	for _, child in ipairs(textLabel:GetChildren()) do
		if child:IsA("UITextSizeConstraint") then
			minTextSize = math.max(minTextSize, child.MinTextSize)
			maxTextSize = math.min(maxTextSize, child.MaxTextSize)
		end
	end

	maxTextSize = math.max(minTextSize, maxTextSize)

	return minTextSize, maxTextSize
end

local function shouldReduceMotion(options)
	if options.RespectReducedMotion ~= true then
		return false
	end

	local ok, reducedMotionEnabled = pcall(function()
		return GuiService.ReducedMotionEnabled
	end)

	return ok and reducedMotionEnabled == true
end

function NumberSpinnerV2.FormatValue(value, options)
	return formatNumber(value, mergeOptions(DEFAULT_OPTIONS, options))
end

function NumberSpinnerV2.ToRoman(value, options)
	return toRoman(value, mergeOptions(DEFAULT_OPTIONS, options))
end

function Spinner.new(textLabel, userOptions)
	assert(typeof(textLabel) == "Instance" and textLabel:IsA("TextLabel"), "NumberSpinnerV2.Attach expects a TextLabel")

	local self = setmetatable({}, Spinner)

	self.Source = textLabel
	self.Options = mergeOptions(DEFAULT_OPTIONS, userOptions)

	self._destroyed = false
	self._connections = {}
	self._slots = {}
	self._lastDisplayText = nil
	self._lastRawWasNumber = false
	self._fontSize = textLabel.TextSize
	self._lineHeight = textLabel.TextSize
	self._nextRenderAnimate = nil

	self._originalTextTransparency = textLabel.TextTransparency
	self._originalTextStrokeTransparency = textLabel.TextStrokeTransparency

	self._visibleTextTransparency = textLabel.TextTransparency
	self._visibleTextStrokeTransparency = textLabel.TextStrokeTransparency
	self._originalAdornmentTransparency = {}

	self:_destroyExistingInternalHolder()
	self:_buildGui()
	self:_hideSourceText()
	self:_connectSignals()
	self:_render(false)

	return self
end

function Spinner:_destroyExistingInternalHolder()
	local existing = self.Source:FindFirstChild(INTERNAL_HOLDER_NAME)
	if existing then
		existing:Destroy()
	end
end

function Spinner:_connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self._connections, connection)
	return connection
end

function Spinner:_connectProperty(propertyName, callback)
	local ok, signal = pcall(function()
		return self.Source:GetPropertyChangedSignal(propertyName)
	end)

	if ok and signal then
		self:_connect(signal, callback)
	end
end

function Spinner:_connectSignals()
	self:_connectProperty("Text", function()
		local animate = true
		if self._nextRenderAnimate ~= nil then
			animate = self._nextRenderAnimate
			self._nextRenderAnimate = nil
		end

		self:_render(animate)
	end)

	local styleProperties = {
		"AbsoluteSize",
		"TextSize",
		"TextScaled",
		"TextColor3",
		"TextStrokeColor3",
		"TextXAlignment",
		"TextYAlignment",
		"Font",
		"RichText",
	}

	for _, propertyName in ipairs(styleProperties) do
		self:_connectProperty(propertyName, function()
			self:_render(false)
		end)
	end

	self:_connectProperty("FontFace", function()
		self:_render(false)
	end)

	self:_connect(self.Source.ChildAdded, function(child)
		if child:IsA("UIStroke") or child:IsA("UITextSizeConstraint") then
			task.defer(function()
				if not self._destroyed then
					self:_render(false)
				end
			end)
		end
	end)

	self:_connect(self.Source.ChildRemoved, function(child)
		if child:IsA("UIStroke") or child:IsA("UITextSizeConstraint") then
			task.defer(function()
				if not self._destroyed then
					self:_render(false)
				end
			end)
		end
	end)

	if workspace.CurrentCamera then
		self:_connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
			self:_render(false)
		end)
	end

	self:_connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		if workspace.CurrentCamera then
			self:_connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
				self:_render(false)
			end)
		end
	end)
end

function Spinner:_hideSourceText()
	if self._destroyed then
		return
	end

	self.Source.TextTransparency = 1
	self.Source.TextStrokeTransparency = 1

	for _, child in ipairs(self.Source:GetChildren()) do
		if child:IsA("UIStroke") then
			if self._originalAdornmentTransparency[child] == nil then
				self._originalAdornmentTransparency[child] = child.Transparency
			end

			child.Transparency = 1
		end
	end
end

function Spinner:_restoreSourceText()
	if not self.Source or not self.Source.Parent then
		return
	end

	self.Source.TextTransparency = self._originalTextTransparency
	self.Source.TextStrokeTransparency = self._originalTextStrokeTransparency

	for child, transparency in pairs(self._originalAdornmentTransparency) do
		if child and child.Parent == self.Source then
			child.Transparency = transparency
		end
	end
end

function Spinner:_buildGui()
	local holder = Instance.new("Frame")
	holder.Name = INTERNAL_HOLDER_NAME
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.ClipsDescendants = false
	holder.Size = UDim2.fromScale(1, 1)
	holder.Position = UDim2.fromScale(0, 0)
	holder.AnchorPoint = Vector2.zero
	holder.ZIndex = self.Source.ZIndex
	holder.Parent = self.Source
	self._holder = holder

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ClipsDescendants = false
	content.Size = UDim2.fromOffset(0, 0)
	content.Position = UDim2.fromScale(0.5, 0.5)
	content.AnchorPoint = Vector2.new(0.5, 0.5)
	content.ZIndex = self.Source.ZIndex
	content.Parent = holder
	self._content = content

	local scale = Instance.new("UIScale")
	scale.Name = "BounceScale"
	scale.Scale = 1
	scale.Parent = content
	self._contentScale = scale

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Name = "ContentLayout"
	contentLayout.FillDirection = Enum.FillDirection.Horizontal
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	contentLayout.Padding = UDim.new(0, asPixels(self.Options.AffixSpacing, 0))
	contentLayout.Parent = content
	self._contentLayout = contentLayout

	local numberContainer = Instance.new("Frame")
	numberContainer.Name = "Number"
	numberContainer.BackgroundTransparency = 1
	numberContainer.BorderSizePixel = 0
	numberContainer.ClipsDescendants = false
	numberContainer.Size = UDim2.fromOffset(0, 0)
	numberContainer.LayoutOrder = 2
	numberContainer.ZIndex = self.Source.ZIndex
	numberContainer.Parent = content
	self._numberContainer = numberContainer

	local numberLayout = Instance.new("UIListLayout")
	numberLayout.Name = "CharacterLayout"
	numberLayout.FillDirection = Enum.FillDirection.Horizontal
	numberLayout.SortOrder = Enum.SortOrder.LayoutOrder
	numberLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	numberLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	numberLayout.Padding = UDim.new(0, 0)
	numberLayout.Parent = numberContainer
	self._numberLayout = numberLayout
end

function Spinner:_getAlignmentAnchors()
	local x = 0.5
	local y = 0.5

	if self.Source.TextXAlignment == Enum.TextXAlignment.Left then
		x = 0
	elseif self.Source.TextXAlignment == Enum.TextXAlignment.Right then
		x = 1
	end

	if self.Source.TextYAlignment == Enum.TextYAlignment.Top then
		y = 0
	elseif self.Source.TextYAlignment == Enum.TextYAlignment.Bottom then
		y = 1
	end

	return x, y
end

function Spinner:_applyTextStyle(label)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.TextColor3 = self.Source.TextColor3
	label.TextTransparency = self._visibleTextTransparency
	label.TextStrokeColor3 = self.Source.TextStrokeColor3
	label.TextStrokeTransparency = self._visibleTextStrokeTransparency
	label.TextSize = self._fontSize
	label.TextScaled = false
	label.TextWrapped = false
	label.Font = self.Source.Font
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = self.Source.TextYAlignment
	label.RichText = false
	label.ZIndex = self.Source.ZIndex

	pcall(function()
		label.FontFace = self.Source.FontFace
	end)

	self:_applyStroke(label)
end

function Spinner:_applyStroke(target)
	for _, child in ipairs(target:GetChildren()) do
		if child:IsA("UIStroke") and child:GetAttribute(INTERNAL_STROKE_ATTRIBUTE) then
			child:Destroy()
		end
	end

	if self.Options.ApplyStrokeToChars ~= true then
		return
	end

	for _, child in ipairs(self.Source:GetChildren()) do
		if child:IsA("UIStroke") and child.Enabled then
			local stroke = child:Clone()
			stroke.Transparency = self._originalAdornmentTransparency[child] or child.Transparency
			stroke:SetAttribute(INTERNAL_STROKE_ATTRIBUTE, true)
			stroke.Parent = target
		end
	end
end

function Spinner:_isSingleStepSpinMode()
	local spinMode = tostring(self.Options.SpinMode or "Full")

	return spinMode == "SingleStep" or spinMode == "Single" or spinMode == "Direct" or spinMode == "Once"
end

function Spinner:_isReelSpinMode()
	local spinMode = tostring(self.Options.SpinMode or "Full")

	return spinMode == "Reel" or spinMode == "Cycle" or spinMode == "FullCycle"
end

function Spinner:_getCharacterReel(targetChar)
	local configuredReel = self.Options.CharacterReel
	local reel

	if type(configuredReel) == "string" then
		reel = splitCharacters(configuredReel)
	elseif type(configuredReel) == "table" then
		reel = {}

		for _, char in ipairs(configuredReel) do
			table.insert(reel, tostring(char))
		end
	else
		reel = DEFAULT_CHARACTER_REEL
	end

	local targetIsUppercase = string.match(targetChar, "^[A-Z]$") ~= nil
	local targetIsLowercase = string.match(targetChar, "^[a-z]$") ~= nil
	local targetIsDigit = isDigitCharacter(targetChar)
	local matchingReel = {}

	for _, reelChar in ipairs(reel) do
		local isMatchingCharacterType = (targetIsUppercase and string.match(reelChar, "^[A-Z]$") ~= nil)
			or (targetIsLowercase and string.match(reelChar, "^[a-z]$") ~= nil)
			or (targetIsDigit and isDigitCharacter(reelChar))

		if isMatchingCharacterType then
			table.insert(matchingReel, reelChar)

			if reelChar == targetChar then
				return matchingReel
			end
		end
	end

	return { targetChar }
end

function Spinner:_getStrokePadding()
	if self.Options.ApplyStrokeToChars ~= true then
		return 0
	end

	local maxThickness = 0

	for _, child in ipairs(self.Source:GetChildren()) do
		if child:IsA("UIStroke") and child.Enabled then
			maxThickness = math.max(maxThickness, child.Thickness)
		end
	end

	return maxThickness
end

function Spinner:_measureText(text, fontSize)
	if text == "" then
		return Vector2.zero
	end

	return safeTextSize(text, fontSize, self.Source.Font, self.Source.FontFace, Vector2.new(math.huge, math.huge))
end

function Spinner:_getGlyphWidthPadding(char, _fontSize)
	local basePadding = math.max(0, math.floor(asNumber(self.Options.SymbolWidthPadding, 1)))
	local letterPadding = math.max(basePadding, math.floor(asNumber(self.Options.LetterWidthPadding, 5)))

	if isLetterCharacter(char) then
		return letterPadding
	end

	if isDigitCharacter(char) or isWhitespaceCharacter(char) then
		return 0
	end

	if isPunctuationCharacter(char) then
		return math.max(0, math.floor(basePadding * 0.5))
	end

	if char == "" then
		return 0
	end

	return basePadding
end

function Spinner:_measureWidestGlyphWidth(sampleText, fontSize)
	local widest = 0

	for _, sampleChar in ipairs(splitCharacters(sampleText)) do
		local sampleSize = self:_measureText(sampleChar, fontSize)
		widest = math.max(widest, sampleSize.X)
	end

	return widest
end

function Spinner:_getGlyphEdgeBleed(char)
	if isLetterCharacter(char) then
		return math.max(0, math.floor(asNumber(self.Options.LetterEdgeBleed, 2)))
	end

	return 0
end

function Spinner:_getUniformReferenceSet(char)
	local mode = tostring(self.Options.Mode or "Number")

	if mode == "Roman" and string.match(char, "^[A-Z]$") then
		return ROMAN_REFERENCE_CHARS
	end

	if string.match(char, "^[A-Z]$") then
		return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	elseif string.match(char, "^[a-z]$") then
		return "abcdefghijklmnopqrstuvwxyz"
	else
		return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	end
end

function Spinner:_getStableGlyphWidth(char, fontSize)
	local measuredWidth = self:_measureText(char, fontSize).X

	if self.Options.UniformLetterSlots ~= true or not isLetterCharacter(char) then
		return measuredWidth
	end

	local referenceSet = self:_getUniformReferenceSet(char)
	local referenceWidth = math.max(measuredWidth, self:_measureWidestGlyphWidth(referenceSet, fontSize))

	return referenceWidth
end

function Spinner:_getWidthScale(char)
	if isPunctuationCharacter(char) then
		return math.max(0.2, asNumber(self.Options.PunctuationWidthScale, 0.45))
	end

	return 1
end

function Spinner:_getTextWidthPadding(text, fontSize)
	local maxPadding = 0

	for _, char in ipairs(splitCharacters(text)) do
		maxPadding = math.max(maxPadding, self:_getGlyphWidthPadding(char, fontSize))
	end

	return maxPadding
end

function Spinner:_getInterCharacterGap(previousChar, nextChar)
	if previousChar == nil or nextChar == nil then
		return 0
	end

	local baseGap = asPixels(self.Options.CharacterPadding, 0)
	local punctuationScale = asNumber(self.Options.PunctuationPaddingScale, 0)

	if isPunctuationCharacter(previousChar) or isPunctuationCharacter(nextChar) then
		return math.max(0, math.floor(baseGap * punctuationScale + 0.5))
	end

	return math.max(0, baseGap)
end

function Spinner:_getEffectiveAffixSpacing(prefixInfo, suffixInfo)
	local spacing = asPixels(self.Options.AffixSpacing, 0)
	local iconSpacing = asPixels(self.Options.IconAffixSpacing, 4)

	if (prefixInfo and prefixInfo.Kind == "Icon") or (suffixInfo and suffixInfo.Kind == "Icon") then
		return math.max(spacing, iconSpacing)
	end

	return spacing
end

function Spinner:_hasPrefix()
	return normalizeAssetId(self.Options.IconPrefix) ~= nil or tostring(self.Options.Prefix or "") ~= ""
end

function Spinner:_hasSuffix()
	return normalizeAssetId(self.Options.IconSuffix) ~= nil or tostring(self.Options.Suffix or "") ~= ""
end

function Spinner:_measureAffix(isPrefix, fontSize, lineHeight, strokePadding)
	local icon = normalizeAssetId(isPrefix and self.Options.IconPrefix or self.Options.IconSuffix)
	local text = tostring(isPrefix and self.Options.Prefix or self.Options.Suffix or "")

	if icon then
		return {
			Exists = true,
			Kind = "Icon",
			Value = icon,
			Width = lineHeight,
			Height = lineHeight,
		}
	end

	if text ~= "" then
		local textSize = self:_measureText(text, fontSize)
		local textWidthPadding = self:_getTextWidthPadding(text, fontSize)

		return {
			Exists = true,
			Kind = "Text",
			Value = text,
			Width = math.ceil(textSize.X + strokePadding * 2 + textWidthPadding * 2),
			Height = math.ceil(math.max(textSize.Y, fontSize) + strokePadding * 2),
		}
	end

	return {
		Exists = false,
		Kind = nil,
		Value = nil,
		Width = 0,
		Height = 0,
	}
end

function Spinner:_measureAtFontSize(fontSize, chars)
	local strokePadding = self:_getStrokePadding()

	local referenceSize = self:_measureText("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", fontSize)
	local lineHeight = math.ceil(math.max(referenceSize.Y, fontSize) + strokePadding * 2)

	local charWidths = {}
	local charRenderWidths = {}
	local numberWidth = 0

	for index, char in ipairs(chars) do
		local glyphWidth = self:_getStableGlyphWidth(char, fontSize)
		local widthPadding = self:_getGlyphWidthPadding(char, fontSize)
		local edgeBleed = self:_getGlyphEdgeBleed(char)
		local scaledTextWidth = math.max(1, glyphWidth * self:_getWidthScale(char))
		local width = math.ceil(scaledTextWidth + strokePadding * 2 + widthPadding * 2)
		local renderWidth = math.ceil(width + edgeBleed * 2)

		charWidths[index] = width
		charRenderWidths[index] = renderWidth
		numberWidth += width

		if index > 1 then
			numberWidth += self:_getInterCharacterGap(chars[index - 1], char)
		end
	end

	local prefixInfo = self:_measureAffix(true, fontSize, lineHeight, strokePadding)
	local suffixInfo = self:_measureAffix(false, fontSize, lineHeight, strokePadding)
	local affixSpacing = self:_getEffectiveAffixSpacing(prefixInfo, suffixInfo)

	local elementCount = 0
	if prefixInfo.Exists then
		elementCount += 1
	end
	if #chars > 0 then
		elementCount += 1
	end
	if suffixInfo.Exists then
		elementCount += 1
	end

	local totalWidth = numberWidth + prefixInfo.Width + suffixInfo.Width
	if elementCount > 1 then
		totalWidth += affixSpacing * (elementCount - 1)
	end

	local totalHeight = math.max(lineHeight, prefixInfo.Height, suffixInfo.Height)

	return {
		FontSize = fontSize,
		LineHeight = totalHeight,
		NumberHeight = lineHeight,
		CharWidths = charWidths,
		CharRenderWidths = charRenderWidths,
		NumberWidth = math.ceil(numberWidth),
		TotalWidth = math.ceil(totalWidth),
		TotalHeight = math.ceil(totalHeight),
		Prefix = prefixInfo,
		Suffix = suffixInfo,
	}
end

function Spinner:_calculateMeasurement(chars)
	local minTextSize, maxTextSize = getUITextSizeConstraintBounds(self.Source, self.Options)

	if not self.Source.TextScaled then
		local fontSize = math.floor(math.clamp(self.Source.TextSize, minTextSize, maxTextSize))
		return self:_measureAtFontSize(fontSize, chars)
	end

	local bounds = self.Source.AbsoluteSize
	if bounds.X <= 0 or bounds.Y <= 0 then
		return self:_measureAtFontSize(minTextSize, chars)
	end

	local bestSize = minTextSize
	local low = minTextSize
	local high = maxTextSize

	while low <= high do
		local mid = math.floor((low + high) / 2)
		local measurement = self:_measureAtFontSize(mid, chars)

		if measurement.TotalWidth <= bounds.X and measurement.TotalHeight <= bounds.Y then
			bestSize = mid
			low = mid + 1
		else
			high = mid - 1
		end
	end

	return self:_measureAtFontSize(bestSize, chars)
end

function Spinner:_refreshAffix(isPrefix, affixInfo, measurement)
	local fieldName = isPrefix and "_prefixElement" or "_suffixElement"
	local existing = self[fieldName]

	if not affixInfo.Exists then
		if existing then
			existing:Destroy()
			self[fieldName] = nil
		end

		return
	end

	local needsNew = false
	if existing == nil then
		needsNew = true
	elseif existing:GetAttribute("AffixKind") ~= affixInfo.Kind then
		needsNew = true
	end

	if needsNew then
		if existing then
			existing:Destroy()
		end

		if affixInfo.Kind == "Icon" then
			existing = Instance.new("ImageLabel")
			existing.ScaleType = Enum.ScaleType.Fit
			existing.BackgroundTransparency = 1
			existing.BorderSizePixel = 0
		else
			existing = Instance.new("TextLabel")
		end

		existing.Name = isPrefix and "Prefix" or "Suffix"
		existing.LayoutOrder = isPrefix and 1 or 3
		existing.ZIndex = self.Source.ZIndex
		existing:SetAttribute("AffixKind", affixInfo.Kind)
		existing.Parent = self._content

		self[fieldName] = existing
	end

	if affixInfo.Kind == "Icon" then
		existing.Image = affixInfo.Value
		existing.Size = UDim2.fromOffset(measurement.LineHeight, measurement.LineHeight)
	else
		existing.Text = affixInfo.Value
		self:_applyTextStyle(existing)
		existing.Size = UDim2.fromOffset(affixInfo.Width, measurement.LineHeight)
	end
end

function Spinner:_getCharacterRank(char)
	local customOrder = self.Options.CharacterOrder

	if type(customOrder) == "table" then
		for index, orderedChar in ipairs(customOrder) do
			if tostring(orderedChar) == char then
				return index
			end
		end
	end

	local defaultRank = DEFAULT_CHARACTER_ORDER[char]
	if defaultRank then
		return defaultRank
	end

	local ok, codepoint = pcall(function()
		return utf8.codepoint(char)
	end)

	if ok and codepoint then
		return 10000 + codepoint
	end

	return 20000 + string.byte(char, 1, 1) or 20000
end

function Spinner:_createSlot()
	local frame = Instance.new("Frame")
	frame.Name = "Slot"
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = false
	frame.Size = UDim2.fromOffset(0, 0)
	frame.ZIndex = self.Source.ZIndex
	frame.Parent = self._numberContainer

	local viewport = Instance.new("Frame")
	viewport.Name = "Viewport"
	viewport.BackgroundTransparency = 1
	viewport.BorderSizePixel = 0
	viewport.ClipsDescendants = true
	viewport.Position = UDim2.fromScale(0.5, 0.5)
	viewport.AnchorPoint = Vector2.new(0.5, 0.5)
	viewport.Size = UDim2.fromOffset(0, 0)
	viewport.ZIndex = self.Source.ZIndex
	viewport.Parent = frame

	local pageLayout = Instance.new("UIPageLayout")
	pageLayout.Name = "PageLayout"
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.FillDirection = Enum.FillDirection.Vertical
	pageLayout.Padding = UDim.new(0, 0)
	pageLayout.Animated = true
	pageLayout.Circular = self.Options.Circular == true
	pageLayout.EasingStyle = self.Options.EasingStyle
	pageLayout.EasingDirection = self.Options.EasingDirection
	pageLayout.TweenTime = self.Options.Duration
	pageLayout.TouchInputEnabled = false
	pageLayout.GamepadInputEnabled = false
	pageLayout.ScrollWheelInputEnabled = false
	pageLayout.Parent = viewport

	local slot = {
		Frame = frame,
		Viewport = viewport,
		PageLayout = pageLayout,
		Pages = {},
		CurrentChar = nil,
		CurrentPage = nil,
		SizeTween = nil,
		ViewportSizeTween = nil,
		ReelTransitionId = 0,
	}

	return slot
end

function Spinner:_removeSlot(index)
	local slot = table.remove(self._slots, index)
	if not slot then
		return
	end

	if slot.SizeTween then
		slot.SizeTween:Cancel()
	end

	if slot.ViewportSizeTween then
		slot.ViewportSizeTween:Cancel()
	end

	slot.Frame:Destroy()
end

function Spinner:_createCharacterPage(slot, char, layoutOrder, pageName)
	local label = Instance.new("TextLabel")
	label.Name = pageName or ("Char_" .. tostring(layoutOrder))
	label.Text = char
	label.Size = UDim2.fromScale(1, 1)
	label.LayoutOrder = layoutOrder
	label.Parent = slot.Viewport

	self:_applyTextStyle(label)

	return label
end

function Spinner:_getOrCreatePage(slot, char)
	local existing = slot.Pages[char]
	if existing and existing.Parent then
		return existing
	end

	local label = self:_createCharacterPage(
		slot,
		char,
		self:_getCharacterRank(char),
		"Char_" .. tostring(self:_getCharacterRank(char))
	)
	slot.Pages[char] = label

	return label
end

function Spinner:_cleanupUntrackedSlotPages(slot)
	local trackedPages = {}

	for _, page in pairs(slot.Pages) do
		if page and page.Parent then
			trackedPages[page] = true
		end
	end

	for _, child in ipairs(slot.Viewport:GetChildren()) do
		if child:IsA("TextLabel") and not trackedPages[child] then
			child:Destroy()
		end
	end
end

function Spinner:_refreshSlotPages(slot)
	for _, child in ipairs(slot.Viewport:GetChildren()) do
		if child:IsA("TextLabel") then
			child.Size = UDim2.fromScale(1, 1)
			self:_applyTextStyle(child)
		end
	end
end

function Spinner:_setSlotSize(slot, width, renderWidth, height, animate)
	renderWidth = math.max(width, renderWidth or width)

	local targetSize = UDim2.fromOffset(width, height)
	local targetViewportSize = UDim2.fromOffset(renderWidth, height)

	if slot.SizeTween then
		slot.SizeTween:Cancel()
		slot.SizeTween = nil
	end

	if slot.ViewportSizeTween then
		slot.ViewportSizeTween:Cancel()
		slot.ViewportSizeTween = nil
	end

	if animate and self.Options.Duration > 0 and not shouldReduceMotion(self.Options) then
		local resizeDuration = math.max(0.01, asNumber(self.Options.SlotResizeDuration, 0.08))
		local tweenInfo = TweenInfo.new(
			math.min(self.Options.Duration, resizeDuration),
			self.Options.EasingStyle,
			self.Options.EasingDirection
		)

		slot.SizeTween = TweenService:Create(slot.Frame, tweenInfo, {
			Size = targetSize,
		})

		slot.ViewportSizeTween = TweenService:Create(slot.Viewport, tweenInfo, {
			Size = targetViewportSize,
		})

		slot.SizeTween:Play()
		slot.ViewportSizeTween:Play()
	else
		slot.Frame.Size = targetSize
		slot.Viewport.Size = targetViewportSize
	end
end

function Spinner:_setSlotChar(slot, char, animate)
	slot.ReelTransitionId += 1
	local transitionId = slot.ReelTransitionId
	local isReelSpinMode = self:_isReelSpinMode()

	if slot.CurrentChar == char and not (isReelSpinMode and animate) then
		self:_refreshSlotPages(slot)
		return
	end

	if isReelSpinMode then
		local shouldAnimate = animate and self.Options.Duration > 0 and not shouldReduceMotion(self.Options)

		for _, child in ipairs(slot.Viewport:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		table.clear(slot.Pages)

		if not shouldAnimate then
			local page = self:_createCharacterPage(slot, char, 1, "Char_Current")
			slot.PageLayout.Animated = false
			slot.PageLayout:JumpTo(page)
			slot.CurrentChar = char
			slot.CurrentPage = page
			return
		end

		local reel = self:_getCharacterReel(char)
		local reelDuration = asNumber(self.Options.Duration, 0.5)
		local reelStepDuration = asNumber(self.Options.ReelStepDuration, 0)

		if reelStepDuration > 0 then
			local stepCount = math.max(1, #reel - 1)
			local maxFinishSpread = math.max(0, asNumber(self.Options.ReelMaxFinishSpread, 1))
			reelDuration = math.min(stepCount * reelStepDuration, reelStepDuration + maxFinishSpread)
		end

		slot.PageLayout.Circular = false
		slot.PageLayout.EasingStyle = self.Options.EasingStyle
		slot.PageLayout.EasingDirection = self.Options.EasingDirection
		slot.PageLayout.TweenTime = reelDuration

		local startChar = reel[1] or slot.CurrentChar or char
		local currentPage = self:_createCharacterPage(slot, startChar, 1, "Char_ReelStart")
		local layoutOrder = 1

		for index = 2, #reel - 1 do
			layoutOrder += 1
			self:_createCharacterPage(slot, reel[index], layoutOrder, "Char_Reel_" .. tostring(index))
		end

		layoutOrder += 1
		local finalPage = self:_createCharacterPage(slot, char, layoutOrder, "Char_ReelFinal")

		slot.PageLayout.Animated = false
		slot.PageLayout:JumpTo(currentPage)
		slot.PageLayout.Animated = true
		slot.PageLayout:JumpTo(finalPage)
		slot.CurrentChar = char
		slot.CurrentPage = finalPage

		task.delay(reelDuration + 0.05, function()
			if
				self._destroyed
				or slot.ReelTransitionId ~= transitionId
				or not finalPage.Parent
				or not slot.Frame.Parent
			then
				return
			end

			for _, child in ipairs(slot.Viewport:GetChildren()) do
				if child:IsA("TextLabel") and child ~= finalPage then
					child:Destroy()
				end
			end

			finalPage.Name = "Char_Current"
			finalPage.LayoutOrder = 1
			slot.PageLayout.Animated = false
			slot.PageLayout:JumpTo(finalPage)
		end)

		return
	end

	if self:_isSingleStepSpinMode() then
		slot.PageLayout.Circular = false
		slot.PageLayout.EasingStyle = self.Options.EasingStyle
		slot.PageLayout.EasingDirection = self.Options.EasingDirection
		slot.PageLayout.TweenTime = self.Options.Duration

		local shouldAnimate = animate and self.Options.Duration > 0 and not shouldReduceMotion(self.Options)
		local currentPage = slot.CurrentPage

		if not (currentPage and currentPage.Parent and shouldAnimate) then
			for _, child in ipairs(slot.Viewport:GetChildren()) do
				if child:IsA("TextLabel") then
					child:Destroy()
				end
			end

			table.clear(slot.Pages)

			local page = self:_createCharacterPage(slot, char, 1, "Char_Current")
			slot.PageLayout.Animated = false
			slot.PageLayout:JumpTo(page)
			slot.CurrentChar = char
			slot.CurrentPage = page
			return
		end

		for _, child in ipairs(slot.Viewport:GetChildren()) do
			if child:IsA("TextLabel") and child ~= currentPage then
				child:Destroy()
			end
		end

		table.clear(slot.Pages)

		currentPage.Name = "Char_Current"
		currentPage.LayoutOrder = 1
		currentPage.Size = UDim2.fromScale(1, 1)
		self:_applyTextStyle(currentPage)

		local page = self:_createCharacterPage(slot, char, 2, "Char_Next")
		slot.PageLayout.Animated = true
		slot.PageLayout:JumpTo(page)
		slot.CurrentChar = char
		slot.CurrentPage = page
		return
	end

	self:_cleanupUntrackedSlotPages(slot)

	local page = self:_getOrCreatePage(slot, char)

	slot.PageLayout.Circular = self.Options.Circular == true
	slot.PageLayout.EasingStyle = self.Options.EasingStyle
	slot.PageLayout.EasingDirection = self.Options.EasingDirection
	slot.PageLayout.TweenTime = self.Options.Duration
	slot.PageLayout.Animated = animate and self.Options.Duration > 0 and not shouldReduceMotion(self.Options)

	if slot.PageLayout.CurrentPage == nil then
		slot.PageLayout.Animated = false
		slot.PageLayout:JumpTo(page)
	else
		slot.PageLayout:JumpTo(page)
	end

	slot.CurrentChar = char
	slot.CurrentPage = page
end

function Spinner:_resolveDisplayText(rawText)
	rawText = tostring(rawText or "")

	if type(self.Options.Formatter) == "function" then
		local ok, result = pcall(self.Options.Formatter, rawText, self.Options, self)

		if ok then
			return tostring(result or "")
		else
			warn("[NumberSpinnerV2] Formatter failed:", result)
		end
	end

	local numberValue = tonumber(rawText)
	self._lastRawWasNumber = numberValue ~= nil

	local mode = tostring(self.Options.Mode or "Number")

	if mode == "Roman" then
		if numberValue ~= nil then
			return toRoman(numberValue, self.Options)
		end

		return rawText
	elseif mode == "Text" or mode == "Characters" or mode == "Character" then
		return rawText
	end

	if numberValue ~= nil then
		return formatNumber(numberValue, self.Options)
	end

	return rawText
end

function Spinner:_shouldAlignSlotsRight()
	local slotAlignment = tostring(self.Options.SlotAlignment or "Auto")

	if slotAlignment == "Right" then
		return true
	end

	if slotAlignment == "Left" then
		return false
	end

	return self._lastRawWasNumber == true
end

function Spinner:_syncSlotCount(count)
	local alignRight = self:_shouldAlignSlotsRight()
	local currentCount = #self._slots

	if count > currentCount then
		local difference = count - currentCount

		for _ = 1, difference do
			local slot = self:_createSlot()

			if alignRight then
				table.insert(self._slots, 1, slot)
			else
				table.insert(self._slots, slot)
			end
		end
	elseif count < currentCount then
		local difference = currentCount - count

		for _ = 1, difference do
			if alignRight then
				self:_removeSlot(1)
			else
				self:_removeSlot(#self._slots)
			end
		end
	end
end

function Spinner:_playBounce()
	if self.Options.BounceOnChange ~= true then
		return
	end

	if shouldReduceMotion(self.Options) then
		return
	end

	local bounceScale = asNumber(self.Options.BounceScale, 1)
	if bounceScale <= 1 then
		return
	end

	if self._bounceTween then
		self._bounceTween:Cancel()
		self._bounceTween = nil
	end

	if self._bounceReturnTween then
		self._bounceReturnTween:Cancel()
		self._bounceReturnTween = nil
	end

	local upDuration = math.max(0.01, asNumber(self.Options.BounceDuration, 0.12))
	local returnDuration = math.max(0.01, asNumber(self.Options.BounceReturnDuration, 0.14))

	self._contentScale.Scale = 1

	local upTween = TweenService:Create(
		self._contentScale,
		TweenInfo.new(upDuration, self.Options.BounceEasingStyle, self.Options.BounceEasingDirection),
		{ Scale = bounceScale }
	)

	local returnTween = TweenService:Create(
		self._contentScale,
		TweenInfo.new(returnDuration, self.Options.BounceEasingStyle, Enum.EasingDirection.Out),
		{ Scale = 1 }
	)

	self._bounceTween = upTween
	self._bounceReturnTween = returnTween

	upTween.Completed:Connect(function()
		if self._destroyed then
			return
		end

		returnTween:Play()
	end)

	upTween:Play()
end

function Spinner:_render(animate)
	if self._destroyed then
		return
	end

	if not self.Source or not self.Source.Parent then
		self:Destroy()
		return
	end

	self:_hideSourceText()

	local displayText = self:_resolveDisplayText(self.Source.Text)
	local chars = splitCharacters(displayText)

	local measurement = self:_calculateMeasurement(chars)

	self._fontSize = measurement.FontSize
	self._lineHeight = measurement.LineHeight

	self._contentLayout.Padding = UDim.new(0, self:_getEffectiveAffixSpacing(measurement.Prefix, measurement.Suffix))
	self._numberLayout.Padding = UDim.new(0, 0)

	self:_refreshAffix(true, measurement.Prefix, measurement)
	self:_refreshAffix(false, measurement.Suffix, measurement)

	self._numberContainer.Visible = #chars > 0
	self._numberContainer.Size = UDim2.fromOffset(measurement.NumberWidth, measurement.NumberHeight)

	local anchorX, anchorY = self:_getAlignmentAnchors()
	self._content.AnchorPoint = Vector2.new(anchorX, anchorY)
	self._content.Position = UDim2.fromScale(anchorX, anchorY)
	self._content.Size = UDim2.fromOffset(measurement.TotalWidth, measurement.TotalHeight)

	self:_syncSlotCount(#chars)

	for index, slot in ipairs(self._slots) do
		local char = chars[index] or ""
		local slotWidth = measurement.CharWidths[index] or 0
		local renderWidth = measurement.CharRenderWidths[index] or slotWidth

		if index > 1 then
			slotWidth += self:_getInterCharacterGap(chars[index - 1], char)
		end

		slot.Frame.LayoutOrder = index
		slot.Frame.ZIndex = self.Source.ZIndex
		slot.PageLayout.Circular = self.Options.Circular == true

		self:_refreshSlotPages(slot)
		self:_setSlotSize(slot, slotWidth, renderWidth, measurement.NumberHeight, animate == true)
		self:_setSlotChar(slot, char, animate == true)
	end

	local didChange = self._lastDisplayText ~= nil and self._lastDisplayText ~= displayText
	self._lastDisplayText = displayText

	if animate and didChange then
		self:_playBounce()
	end
end

function Spinner:SetValue(value, animate)
	self._nextRenderAnimate = animate ~= false
	self.Source.Text = tostring(value)
end

function Spinner:SetText(text, animate)
	self:SetValue(text, animate)
end

function Spinner:SetOptions(newOptions, animate)
	self.Options = mergeOptions(self.Options, newOptions or {})
	self:_render(animate == true)
end

function Spinner:Refresh(animate)
	self:_render(animate == true)
end

function Spinner:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	table.clear(self._connections)

	if self._bounceTween then
		self._bounceTween:Cancel()
	end

	if self._bounceReturnTween then
		self._bounceReturnTween:Cancel()
	end

	for _, slot in ipairs(self._slots) do
		if slot.SizeTween then
			slot.SizeTween:Cancel()
		end

		if slot.ViewportSizeTween then
			slot.ViewportSizeTween:Cancel()
		end
	end
	table.clear(self._slots)

	if self._holder then
		self._holder:Destroy()
		self._holder = nil
	end

	self:_restoreSourceText()
end

function NumberSpinnerV2.Attach(textLabel, options)
	return Spinner.new(textLabel, options)
end

function NumberSpinnerV2.createSpinningNumber(textLabel, options)
	return NumberSpinnerV2.Attach(textLabel, options)
end

NumberSpinnerV2.DEFAULT_OPTIONS = deepClone(DEFAULT_OPTIONS)

return NumberSpinnerV2
