# NumberSpinnerV2 — A modern animated number and text spinner module

**NumberSpinnerV2**, a modern animated number and text spinner utility module for Roblox UI.

NumberSpinnerV2 was inspired by [NumberSpinner by boatbomber](https://devforum.roblox.com/t/numberspinner-module/1105961). However, using and extending older spinner implementations often meant maintaining separate value-update logic, manually synchronizing `TextLabel` properties, and working around limited `TextScaled` support.

**NumberSpinnerV2** addresses these pain points. It is built around the same general concept, but has been rewritten from scratch and expanded into a more complete, responsive, and configurable system.

The underlying spinner system has been used internally in my projects for the past two years, and I have now polished it into an open-source module for public use.

Check out the uncopylocked showcase game on Roblox:

[NumberSpinnerV2 Showcase](https://www.roblox.com/games/128706398575811/NumberSpinnerV2-Showcase)

Video showcase:

https://www.youtube.com/watch?v=_erdwv5Xg_s

## Quick example

NumberSpinnerV2 attaches directly to a normal `TextLabel`.

```lua
local NumberSpinnerV2 = require(ReplicatedStorage.Modules.NumberSpinnerV2)

local spinner = NumberSpinnerV2.Attach(label, {
	Separator = ",",
	Prefix = "$",
})

label.Text = 1250
```

You continue updating the original `TextLabel.Text` property. NumberSpinnerV2 handles the animation, formatting, layout, and responsive sizing.

## 🚀 Features

### TextLabel-driven workflow

NumberSpinnerV2 attaches directly to an existing `TextLabel`.

```lua
local spinner = NumberSpinnerV2.Attach(myTextLabel, options)

myTextLabel.Text = 1250
myTextLabel.Text = 50000
myTextLabel.Text = 1234567
```

The source `TextLabel` remains the public interface. The module hides its original rendered text and creates the animated spinner UI inside it.

This allows you to build and style your UI normally in Roblox Studio without maintaining a separate display pipeline.

### TextScaled support

NumberSpinnerV2 supports `TextScaled`.

The module measures and resizes its generated characters based on the source `TextLabel`, allowing the spinner to respond when the label or its container changes size.

This was one of the main reasons I created the module.

### Spin modes

NumberSpinnerV2 includes multiple animation modes through the `SpinMode` option.

#### Full

`"Full"` is the default mode. Each slot uses its available character pages and moves to the target character.

```lua
NumberSpinnerV2.Attach(label, {
	SpinMode = "Full",
})
```

#### SingleStep

`"SingleStep"` transitions directly from the currently displayed character to the next character.

```lua
NumberSpinnerV2.Attach(label, {
	SpinMode = "SingleStep",
})
```

#### Reel

`"Reel"` creates a slot-machine-like animation using a character reel.

`CharacterReel` accepts either a string or an ordered array of characters.

```lua
NumberSpinnerV2.Attach(label, {
	SpinMode = "Reel",
	CharacterReel = "0123456789",
	ReelStepDuration = 0.04,
	ReelMaxFinishSpread = 1,
})
```

If no custom reel is provided, the module uses its built-in number, punctuation, and letter reel.

### Number formatting

NumberSpinnerV2 supports common number-formatting options:

* Thousands separators
* Decimal places
* Forced decimals
* Abbreviations
* Abbreviation-specific decimal places
* Custom decimal separators

Example:

```lua
NumberSpinnerV2.Attach(label, {
	Separator = ",",
	DecimalPlaces = 2,
	ForceDecimals = true,
})

label.Text = 1250
-- Displays: 1,250.00
```

### Abbreviations

You can define custom abbreviation thresholds:

```lua
NumberSpinnerV2.Attach(label, {
	Abbreviations = {
		[1e3] = "K",
		[1e6] = "M",
		[1e9] = "B",
	},
	AbbreviationDecimalPlaces = 1,
})
```

Example displays:

```text
950
1.2K
48.5K
3.6M
7.1B
```

### Prefixes, suffixes, and icon affixes

NumberSpinnerV2 supports text prefixes and suffixes:

```lua
NumberSpinnerV2.Attach(label, {
	Prefix = "$",
	Suffix = " Coins",
})
```

It also supports image affixes:

```lua
NumberSpinnerV2.Attach(label, {
	IconPrefix = "rbxassetid://0000000000",
	Suffix = " Coins",
	AffixSpacing = 6,
})
```

If `IconPrefix` is set, it takes priority over the text `Prefix`.

If `IconSuffix` is set, it takes priority over the text `Suffix`.

### Animation configuration

The main spin animation can be configured through standard Roblox easing options:

```lua
NumberSpinnerV2.Attach(label, {
	Duration = 0.5,
	EasingStyle = Enum.EasingStyle.Quad,
	EasingDirection = Enum.EasingDirection.Out,
})
```

This allows the animation to be smooth, fast, bouncy, or snappy depending on the use case.

### Bounce effect

NumberSpinnerV2 can optionally apply a small pop animation to the entire spinner when its displayed value changes:

```lua
NumberSpinnerV2.Attach(label, {
	BounceOnChange = true,
	BounceScale = 1.1,
})
```

This works well for rewards, coins, damage values, level-ups, and similar UI feedback.

### UIStroke inheritance

If the source `TextLabel` contains a `UIStroke`, NumberSpinnerV2 can clone it onto the generated characters:

```lua
NumberSpinnerV2.Attach(label, {
	ApplyStrokeToChars = true,
})
```

This helps the spinner preserve the visual style of the original label.

### Roman numeral and text modes

The default mode formats numeric input, but NumberSpinnerV2 also supports Roman numerals and general text or character spinning.

Roman numeral example:

```lua
NumberSpinnerV2.Attach(label, {
	Mode = "Roman",
	Prefix = "Level ",
})

label.Text = 9
-- Displays: Level IX
```

Text or rank example:

```lua
NumberSpinnerV2.Attach(label, {
	Mode = "Text",
	Prefix = "Rank ",
})

label.Text = "S"
-- Displays: Rank S
```

These modes make the module usable for levels, ranks, short labels, and other non-standard counters.

## 📖 Basic usage

Place the `NumberSpinnerV2` module somewhere accessible to a client script. Require the module and attach it to a `TextLabel`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NumberSpinnerV2 = require(ReplicatedStorage.Modules.NumberSpinnerV2)

local label = script.Parent.AmountLabel

local spinner = NumberSpinnerV2.Attach(label, {
	Duration = 0.5,
	EasingStyle = Enum.EasingStyle.Quad,
	EasingDirection = Enum.EasingDirection.Out,

	Separator = ",",
	DecimalPlaces = 0,
	ForceDecimals = false,

	Prefix = "$",
	Suffix = "",
})
```

Update the original label normally:

```lua
label.Text = 0
label.Text = 1250
label.Text = 50000
```

The module listens to `TextLabel.Text` and handles the visual update.

### Example: leaderstats coin counter

```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local NumberSpinnerV2 = require(ReplicatedStorage.Modules.NumberSpinnerV2)

local label = script.Parent.CoinsLabel

local spinner = NumberSpinnerV2.Attach(label, {
	Duration = 0.5,
	EasingStyle = Enum.EasingStyle.Quad,
	EasingDirection = Enum.EasingDirection.Out,

	Separator = ",",
	DecimalPlaces = 0,

	IconPrefix = "rbxassetid://0000000000",
	Suffix = " Coins",
	AffixSpacing = 6,

	ApplyStrokeToChars = true,
	BounceOnChange = true,
	BounceScale = 1.08,
})

local leaderstats = player:WaitForChild("leaderstats")
local coins = leaderstats:WaitForChild("Coins")

local function updateCoins(value)
	label.Text = value
end

updateCoins(coins.Value)
coins.Changed:Connect(updateCoins)
```

### Example: abbreviated large values

```lua
local spinner = NumberSpinnerV2.Attach(label, {
	Separator = ",",

	Abbreviations = {
		[1e3] = "K",
		[1e6] = "M",
		[1e9] = "B",
	},

	AbbreviationDecimalPlaces = 1,
})

label.Text = 1260000
-- Displays: 1.3M
```

### Example: currency display

```lua
local spinner = NumberSpinnerV2.Attach(label, {
	Prefix = "$",
	Separator = ",",
	DecimalPlaces = 2,
	ForceDecimals = true,
})

label.Text = 1250
-- Displays: $1,250.00
```

### Example: Roman numeral levels

```lua
local spinner = NumberSpinnerV2.Attach(label, {
	Mode = "Roman",
	Prefix = "Level ",
	Duration = 0.35,
})

label.Text = 4
-- Displays: Level IV

label.Text = 9
-- Displays: Level IX

label.Text = 10
-- Displays: Level X
```

## ⚙️ API

### `NumberSpinnerV2.Attach(textLabel, options)`

Attaches a spinner to a `TextLabel` and returns its controller.

```lua
local spinner = NumberSpinnerV2.Attach(label, options)
```

### `NumberSpinnerV2.createSpinningNumber(textLabel, options)`

An alias for `Attach`, included for compatibility with the older usage pattern.

```lua
local spinner = NumberSpinnerV2.createSpinningNumber(label, options)
```

### `NumberSpinnerV2.FormatValue(value, options?)`

Formats a number using the module's number-formatting options without creating a spinner.

```lua
local formatted = NumberSpinnerV2.FormatValue(1260000, {
	Separator = ",",
	Abbreviations = {
		[1e3] = "K",
		[1e6] = "M",
	},
	AbbreviationDecimalPlaces = 1,
})

-- "1.3M"
```

### `NumberSpinnerV2.ToRoman(value, options?)`

Converts a number into a Roman numeral without creating a spinner.

```lua
local roman = NumberSpinnerV2.ToRoman(9)

-- "IX"
```

### `NumberSpinnerV2.DEFAULT_OPTIONS`

A copy of the module's default option values.

It can be used as a reference or starting point. Changing this table does not alter the internal defaults used by future spinners.

### `spinner:SetValue(value, animate?)`

Sets the source label text.

It animates by default. Pass `false` to update without animation.

```lua
spinner:SetValue(5000)
spinner:SetValue(5000, false)
```

This is equivalent to updating the source label:

```lua
label.Text = 5000
```

### `spinner:SetText(text, animate?)`

Sets the source label text using a text value.

It animates by default. Pass `false` to update without animation.

```lua
spinner:SetText("S")
spinner:SetText("S", false)
```

### `spinner:SetOptions(options, animate?)`

Merges new options into the spinner's current options and redraws it.

Pass `true` to animate the redraw.

```lua
spinner:SetOptions({
	BounceOnChange = true,
	Duration = 0.25,
})
```

### `spinner:Refresh(animate?)`

Forces the spinner to re-measure and redraw.

Pass `true` to animate the redraw.

```lua
spinner:Refresh()
```

### `spinner:Destroy()`

Cleans up the generated UI and restores the original `TextLabel` text visibility.

```lua
spinner:Destroy()
```

## Complete options reference

You normally only need to provide the options you want to change. Any omitted options use the module defaults.

```lua
{
	-- Animation
	Duration = 0.5,
	SlotResizeDuration = 0.08,
	SpinMode = "Full", -- "Full", "SingleStep", or "Reel"
	ReelStepDuration = nil,
	ReelMaxFinishSpread = 1,
	EasingStyle = Enum.EasingStyle.Quad,
	EasingDirection = Enum.EasingDirection.Out,
	Circular = false,

	-- Formatting
	Mode = "Number",
	Separator = ",",
	DecimalPlaces = 0,
	ForceDecimals = false,
	DecimalSeparator = ".",

	Abbreviations = {},
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
	SlotAlignment = "Auto",
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

	-- Advanced
	Formatter = nil,
}
```

## Display modes

### `"Number"`

The default mode.

It attempts to parse `TextLabel.Text` as a number and applies the configured number formatting.

```lua
Mode = "Number"
```

### `"Roman"`

Converts numeric input into Roman numerals.

```lua
Mode = "Roman"
```

### `"Text"`

Displays and spins general text or characters without numeric formatting.

```lua
Mode = "Text"
```

### `"Characters"`

Equivalent to `"Text"`.

The singular spelling `"Character"` is also accepted.

```lua
Mode = "Characters"
```

## Animation options

* `SpinMode = "Full"` uses the normal cached character pages and moves each slot to its target character. This is the default.
* `SpinMode = "SingleStep"` transitions from the currently displayed character directly to the next character.
* `SpinMode = "Reel"` plays each slot through `CharacterReel` before landing on its target.
* `SlotResizeDuration` controls the width-change animation when a character slot changes size.
* `ReelStepDuration`, when set to a value greater than zero, derives the reel animation duration from its number of steps.
* `ReelMaxFinishSpread` limits the additional finish-time spread used by reel animations.
* `Circular` applies to the normal `"Full"` spin mode. Reel and single-step animations use a non-circular sequence.

## Character layout options

* `CharacterPadding` adds horizontal spacing around characters.
* `PunctuationPaddingScale` adjusts the spacing applied to punctuation.
* `PunctuationWidthScale` adjusts the measured width of punctuation slots.
* `LetterWidthPadding` adds additional width for letter slots.
* `LetterEdgeBleed` helps prevent letter edges from appearing clipped.
* `UniformLetterSlots` gives letter slots a stable, uniform width.
* `SymbolWidthPadding` adds additional width around symbols.
* `SlotAlignment` accepts `"Auto"`, `"Left"`, or `"Right"`.
* Automatic slot alignment is right-aligned for numeric input and left-aligned for other input.
* `CharacterOrder` accepts an ordered character array and controls page ordering in `"Full"` mode.
* `CharacterReel` accepts a string or ordered character array and is used by `SpinMode = "Reel"`.

## 📝 Notes

* NumberSpinnerV2 is intended for client-side UI.
* The original `TextLabel` can be designed and styled normally in Roblox Studio.
* The generated spinner UI is created inside the source `TextLabel`.
* Updating `TextLabel.Text` is the main usage pattern.
* `TextScaled` is supported.
* If you use icon affixes, make sure the supplied asset IDs refer to valid image assets.
* For extremely small or responsive UI, consider adding a `UITextSizeConstraint` to the source label.
* Call `spinner:Destroy()` when you no longer need the spinner and want to restore the original label rendering.

## 🛠️ Installation

### Wally

Add NumberSpinnerV2 to your `wally.toml` dependencies:

```toml
[dependencies]
NumberSpinnerV2 = "biotoxin495/numberspinnerv2@1.2.0"
```

Run:

```text
wally install
```

Then require the package from the location configured by your project. Like for example:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NumberSpinnerV2 = require(
	ReplicatedStorage.Packages.NumberSpinnerV2
)
```

### Manual installation

You can install the standalone ModuleScript manually by copying it from the GitHub repository or the uncopylocked showcase game.

Recommended structure:

```text
ReplicatedStorage
└── Modules
    └── NumberSpinnerV2
```

Then require it with:

```lua
local NumberSpinnerV2 = require(
	ReplicatedStorage.Modules.NumberSpinnerV2
)
```

## 🔗 Links

* GitHub: [NumberSpinnerV2](https://github.com/biotoxin495/NumberSpinnerV2)
* Wally: [NumberSpinnerV2](https://wally.run/package/biotoxin495/numberspinnerv2?version=1.2.0)
* Uncopylocked showcase game: [NumberSpinnerV2 Showcase](https://www.roblox.com/games/128706398575811/NumberSpinnerV2-Showcase)


made with ❤️ by biotoxin495
