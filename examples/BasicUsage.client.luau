--!strict
-- BasicUsage.client.luau
--
-- Place this LocalScript in StarterPlayerScripts, StarterGui, or another client-side location.
--
-- Expected setup:
--
-- ReplicatedStorage
-- └── NumberSpinnerV2
--
-- If your module is somewhere else, update the require path below.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NumberSpinnerV2 = require(ReplicatedStorage:WaitForChild("NumberSpinnerV2"))

-- Create a simple ScreenGui for the example.
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NumberSpinnerV2BasicUsage"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Create a background frame just to make the example easier to see.
local background = Instance.new("Frame")
background.Name = "Background"
background.AnchorPoint = Vector2.new(0.5, 0.5)
background.Position = UDim2.fromScale(0.5, 0.5)
background.Size = UDim2.fromScale(0.75, 0.32)
background.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
background.BorderSizePixel = 0
background.Parent = screenGui

local backgroundCorner = Instance.new("UICorner")
backgroundCorner.CornerRadius = UDim.new(0, 18)
backgroundCorner.Parent = background

local backgroundStroke = Instance.new("UIStroke")
backgroundStroke.Thickness = 2
backgroundStroke.Color = Color3.fromRGB(80, 90, 120)
backgroundStroke.Transparency = 0.25
backgroundStroke.Parent = background

-- Create the TextLabel that NumberSpinnerV2 will attach to.
--
-- Important:
-- This is a normal TextLabel. The spinner uses this label as the source.
-- Updating numberLabel.Text is enough to update the spinner.
local numberLabel = Instance.new("TextLabel")
numberLabel.Name = "NumberLabel"
numberLabel.AnchorPoint = Vector2.new(0.5, 0.5)
numberLabel.Position = UDim2.fromScale(0.5, 0.5)
numberLabel.Size = UDim2.fromScale(0.9, 0.55)
numberLabel.BackgroundTransparency = 1
numberLabel.Text = "0"
numberLabel.TextScaled = true
numberLabel.Font = Enum.Font.GothamBold
numberLabel.TextColor3 = Color3.fromRGB(255, 236, 160)
numberLabel.TextStrokeTransparency = 1
numberLabel.TextXAlignment = Enum.TextXAlignment.Center
numberLabel.TextYAlignment = Enum.TextYAlignment.Center
numberLabel.Parent = background

-- Recommended when using TextScaled:
-- This prevents the text from becoming absurdly small or huge.
local textSizeConstraint = Instance.new("UITextSizeConstraint")
textSizeConstraint.MinTextSize = 18
textSizeConstraint.MaxTextSize = 96
textSizeConstraint.Parent = numberLabel

-- Optional styling.
-- If ApplyStrokeToChars is true, NumberSpinnerV2 will clone this UIStroke
-- onto the generated spinning characters.
local labelStroke = Instance.new("UIStroke")
labelStroke.Thickness = 2
labelStroke.Color = Color3.fromRGB(80, 52, 10)
labelStroke.Transparency = 0
labelStroke.Parent = numberLabel

-- Optional small description label.
local descriptionLabel = Instance.new("TextLabel")
descriptionLabel.Name = "Description"
descriptionLabel.AnchorPoint = Vector2.new(0.5, 1)
descriptionLabel.Position = UDim2.fromScale(0.5, 0.93)
descriptionLabel.Size = UDim2.fromScale(0.9, 0.18)
descriptionLabel.BackgroundTransparency = 1
descriptionLabel.Text = "NumberSpinnerV2 example - this TextLabel is periodically updated by changing .Text"
descriptionLabel.TextScaled = true
descriptionLabel.Font = Enum.Font.Gotham
descriptionLabel.TextColor3 = Color3.fromRGB(190, 195, 215)
descriptionLabel.TextTransparency = 0.05
descriptionLabel.TextXAlignment = Enum.TextXAlignment.Center
descriptionLabel.TextYAlignment = Enum.TextYAlignment.Center
descriptionLabel.Parent = background

local descriptionConstraint = Instance.new("UITextSizeConstraint")
descriptionConstraint.MinTextSize = 10
descriptionConstraint.MaxTextSize = 20
descriptionConstraint.Parent = descriptionLabel

-- This options table intentionally shows every supported option.
-- You usually do not need to define all of these; unspecified options use defaults.
local spinnerOptions = {
	-- Animation
	Duration = 0.5,
	EasingStyle = Enum.EasingStyle.Quad,
	EasingDirection = Enum.EasingDirection.Out,
	Circular = false,

	-- Formatting
	Mode = "Number", -- "Number", "Roman", or "Text"
	Separator = ",",
	DecimalPlaces = 0,
	ForceDecimals = false,
	DecimalSeparator = ".",

	-- Abbreviations
	-- Example:
	-- 1250 -> 1.3K
	-- 1250000 -> 1.3M

	--Abbreviations = {
	--	[1e3] = "K",
	--	[1e6] = "M",
	--	[1e9] = "B",
	--	[1e12] = "T",
	--},
	--AbbreviationDecimalPlaces = 1,
	--ForceAbbreviationDecimals = false,

	-- Roman numeral options
	-- These only matter when Mode = "Roman".
	RomanZero = "N",
	RomanMax = 3999,
	RomanAllowLarge = false,

	-- Affixes
	Prefix = "$",
	Suffix = " Coins",

	-- IconPrefix/IconSuffix override Prefix/Suffix when set.
	-- Leave them empty for this basic example.
	IconPrefix = "",
	IconSuffix = "",

	AffixSpacing = 6,

	-- Character layout
	CharacterPadding = 2,
	SlotAlignment = "Auto", -- "Auto", "Left", or "Right"
	CharacterOrder = nil,

	-- Visual styling
	ApplyStrokeToChars = true,

	-- Bounce effect
	BounceOnChange = true,
	BounceScale = 1.08,
	BounceDuration = 0.12,
	BounceReturnDuration = 0.14,
	BounceEasingStyle = Enum.EasingStyle.Quad,
	BounceEasingDirection = Enum.EasingDirection.Out,

	-- Accessibility
	RespectReducedMotion = true,

	-- TextScaled bounds.
	-- These are also affected by UITextSizeConstraint if the source label has one.
	MinTextSize = 1,
	MaxTextSize = 100,

	-- Advanced custom formatter.
	-- Leave nil for normal built-in formatting.
	--
	-- Example:
	-- Formatter = function(rawText, options, spinner)
	-- 	return "Value: " .. tostring(rawText)
	-- end,
	Formatter = nil,
}

-- Attach NumberSpinnerV2 to the normal TextLabel.
numberLabel.TextScaled = true
local spinner = NumberSpinnerV2.Attach(numberLabel, spinnerOptions)

-- Demonstration loop:
-- Instead of buttons, this periodically increases the number.
-- The only thing being changed is numberLabel.Text.
local value = 0

while screenGui.Parent do
	value += math.random(85, 425)

	numberLabel.Text = tostring(value)

	task.wait(1.25)
end

-- If this example ever stops manually, you can clean up with:
-- spinner:Destroy()
