# NumberSpinnerV2 - A modern animated number and text spinner module
![NumberSpinnerV2 title|video](upload://cfRRce1JkfWxIy4Vq0jYnRkRGz0.mp4)

hi

I am releasing NumberSpinnerV2, a modern animated number and text spinner utility module for Roblox UI.

This was originally inspired by the [NumberSpinner by boatbomber](https://devforum.roblox.com/t/numberspinner-module/1105961) module. However, implementing it (and other similar effect modules) often meant rewriting data pipelines, manually syncing TextLabel properties, and, notably, the TextScaled property not working properly.

**NumberSpinnerV2** solves all of these pain points - built conceptually on the original idea but entirely rewritten from scratch.
I have used this system internally for the past 2 years in my own projects, and I have finally polished it into an open-source tool for public use.

Check out the [NumberSpinnerV2 showcase game](https://www.roblox.com/games/128706398575811/NumberSpinnerV2-Showcase):
https://www.youtube.com/watch?v=_erdwv5Xg_s

## 🚀 Features
### TextLabel-driven workflow
NumberSpinnerV2 attaches directly to an existing `TextLabel`.
```lua
local spinner = NumberSpinnerV2.Attach(myTextLabel, options) 
myTextLabel.Text = 1250 
myTextLabel.Text = 50000 
myTextLabel.Text = 1234567
```
The source `TextLabel` remains the public interface. The module hides the original label text and renders the animated spinner inside it.
This makes it easier to use with UI that was already built and styled in Roblox Studio.

### TextScaled support
NumberSpinnerV2 supports `TextScaled`.

The module measures and resizes the generated spinner characters based on the original `TextLabel` , so the spinner can respond properly when the label/container changes size.

This is one of the biggest reasons I made this module.

### Number formatting
NumberSpinnerV2 supports various common formatting options

* Thousands seperators
* Decimal places
* Forced decimals
* Abbreviations
* Abbreviation-specific decimal places
* Custom decimal seperator

For example:
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
You can also define abbreviation thresholds:
```lua
NumberSpinnerV2.Attach(label, { Abbreviations = { [1e3] = "K", [1e6] = "M", [1e9] = "B", }, AbbreviationDecimalPlaces = 1, })
Display examples:
-- 950 ; 1.2K ; 48.5K ; 3.6M ; 7.1B
```

### Prefixes, suffixes and icon affixes
NumberSpinnerV2 also supports prefixes/suffixes:

```lua
NumberSpinnerV2.Attach(label, { Prefix = "$", Suffix = " Coins", })
```
It also supports image affixes:
```lua
NumberSpinnerV2.Attach(label, { IconPrefix = "rbxassetid://0000000000", Suffix = " Coins", AffixSpacing = 6, })
```
If `IconPrefix` is set, it takes priority over the text `Prefix` .
If `IconSuffix` is set, it takes priority over the text `Suffix` .

### Animation configuration
The spin animation can be configured:

```
NumberSpinnerV2.Attach(label, {
	Duration = 0.5,
	EasingStyle = Enum.EasingStyle.Quad,
	EasingDirection = Enum.EasingDirection.Out,
})
```

You can make it smooth, snappy, bouncy, or very fast depending on the use case.

### Spin modes
By default, each character moves directly to its target page. You can choose two additional behaviours with `SpinMode`:

```lua
NumberSpinnerV2.Attach(label, {
	SpinMode = "SingleStep", -- only transition from the current character to the next one
})
```

Use `SpinMode = "Reel"` for a slot-machine-like pass through a character reel. `CharacterReel` accepts either a string or an array, and `ReelStepDuration` can be used to derive the reel duration from its number of steps.

```lua
NumberSpinnerV2.Attach(label, {
	SpinMode = "Reel",
	CharacterReel = "0123456789",
	ReelStepDuration = 0.04,
	ReelMaxFinishSpread = 1,
})
```


### Bounce effect
NumberSpinnerV2 can optionally apply a small pop animation to the whole spinner when the displayed value changes:

```
NumberSpinnerV2.Attach(label, {
	BounceOnChange = true,
	BounceScale = 1.1,
})
```

This works well for rewards, coins, damage numbers, level-ups, and similar UI feedback.

### UIStroke inheritance
If the source `TextLabel` has a `UIStroke` , NumberSpinnerV2 can clone that stroke onto the generated characters:

```
NumberSpinnerV2.Attach(label, {
	ApplyStrokeToChars = true,
})
```

This helps the spinner preserve the look of the original TextLabel.

### Roman numeral and text modes
The default mode is number formatting, but NumberSpinnerV2 also supports Roman numerals and general character/text spinning.

Roman numerals:

```
NumberSpinnerV2.Attach(label, {
	Mode = "Roman",
	Prefix = "Level ",
})

label.Text = 9
-- Displays: Level IX
```

Text/rank mode:

```
NumberSpinnerV2.Attach(label, {
	Mode = "Text",
	Prefix = "Rank ",
})

label.Text = "S"
-- Displays: Rank S
```

This makes it usable for levels, ranks, short labels, and other non-standard counters.


# 📖 Basic usage
Place the `NumberSpinnerV2` module somewhere you can require it, then attach it to a `TextLabel`:
```
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

Then update the original label normally:

```
label.Text = 0
label.Text = 1250
label.Text = 50000
```

The module listens to `TextLabel.Text` and handles the visual update.


## Example - leaderstat coin counter

```
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

## Example: abbreviated large values

```
local spinner = NumberSpinnerV2.Attach(label, {
	Separator = ",",

	Abbreviations = {
		[1e3] = "K",
		[1e6] = "M",
		[1e9] = "B",
	},

	AbbreviationDecimalPlaces = 1,
})

label.Text = 1250000
-- Displays around: 1.3M
```

---

## Example: currency display

```
local spinner = NumberSpinnerV2.Attach(label, {
	Prefix = "$",
	Separator = ",",
	DecimalPlaces = 2,
	ForceDecimals = true,
})

label.Text = 1250
-- Displays: $1,250.00
```

---

## Example: Roman numeral levels

```
local spinner = NumberSpinnerV2.Attach(label, {
	Mode = "Roman",
	Prefix = "Level ",
	Duration = 0.35,
})

label.Text = 4
-- Level IV

label.Text = 9
-- Level IX

label.Text = 10
-- Level X
```

# ⚙️ API

### `NumberSpinnerV2.Attach(textLabel, options)`

Attaches a spinner to a `TextLabel` .

Returns a spinner controller.

```
local spinner = NumberSpinnerV2.Attach(label, options)
```

---

### `NumberSpinnerV2.createSpinningNumber(textLabel, options)`

Alias for `Attach` .

This exists for compatibility with older usage patterns.

```
NumberSpinnerV2.createSpinningNumber(label, options)
```

---

### `NumberSpinnerV2.FormatValue(value, options?)`

Formats a number using the module's number-formatting options without creating a spinner.

```
local formatted = NumberSpinnerV2.FormatValue(1250000, {
	Separator = ",",
	Abbreviations = { [1e3] = "K", [1e6] = "M" },
	AbbreviationDecimalPlaces = 1,
})
-- "1.3M"
```

---

### `NumberSpinnerV2.ToRoman(value, options?)`

Converts a number to a Roman numeral without creating a spinner.

```
local roman = NumberSpinnerV2.ToRoman(9)
-- "IX"
```

---

### `NumberSpinnerV2.DEFAULT_OPTIONS`

A copy of the module's default option values. Use it as a reference or starting point; changing it does not alter the defaults used by future spinners.

---

### `spinner:SetValue(value, animate?)`

Sets the source label text. It animates by default; pass `false` to update without animation.

```
spinner:SetValue(5000)
```

Equivalent to:

```
label.Text = 5000
```

---

### `spinner:SetText(text, animate?)`

Sets the source label text as text. It animates by default; pass `false` to update without animation.

```
spinner:SetText("S")
```

---

### `spinner:SetOptions(options, animate?)`

Merges options into the current options and redraws the spinner. Pass `true` to animate the redraw.

```
spinner:SetOptions({
	BounceOnChange = true,
	Duration = 0.25,
})
```

---

### `spinner:Refresh(animate?)`

Forces the spinner to re-measure and redraw. Pass `true` to animate the redraw.

```
spinner:Refresh()
```

---

### `spinner:Destroy()`

Cleans up the generated UI and restores the original `TextLabel` text visibility.

```
spinner:Destroy()
```

---

## Options

```
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

---

## Modes

### `"Number"`

Default mode. Attempts to parse `TextLabel.Text` as a number and apply number formatting.

```
Mode = "Number"
```

---

### `"Roman"`

Converts numeric input into Roman numerals.

```
Mode = "Roman"
```

---

### `"Text"`

Displays and spins general text/characters without numeric formatting.

```
Mode = "Text"
```

---

### `"Characters"`

Equivalent to `"Text"`. The singular spelling `"Character"` is also accepted.

```
Mode = "Characters"
```

## Animation options

* `SpinMode = "Full"` — each slot uses its cached character pages, moving directly to the target character. This is the default.
* `SpinMode = "SingleStep"` — each update transitions from the currently displayed character to the next character only.
* `SpinMode = "Reel"` — each slot plays through `CharacterReel` before landing on its target. If no reel is supplied, the module's built-in number, punctuation, and letter reel is used.
* `SlotResizeDuration` — duration used when a character slot changes width.
* `ReelStepDuration` — when greater than zero, derives reel duration from the reel length. `ReelMaxFinishSpread` caps the extra finish-time spread.
* `Circular` applies to the normal full-page spin mode; reel and single-step spins always use a non-circular sequence.

## Character layout options

* `CharacterPadding` adds horizontal padding around every character.
* `PunctuationPaddingScale` and `PunctuationWidthScale` tune spacing and width for punctuation.
* `LetterWidthPadding` and `LetterEdgeBleed` prevent clipped or tightly packed letters.
* `UniformLetterSlots` makes letter slots use a stable, uniform width.
* `SymbolWidthPadding` adds width around symbols.
* `SlotAlignment` is `"Auto"`, `"Left"`, or `"Right"`; automatic alignment is right-aligned for numeric input and left-aligned otherwise.
* `CharacterOrder` is an ordered character array that controls page ordering in `"Full"` mode.
* `CharacterReel` is a string or character array used by `SpinMode = "Reel"`.

# 📝  Notes

* This module is intended for client-side UI.
* The original `TextLabel` should be designed in Studio.
* The module creates its generated spinner UI inside the source `TextLabel` .
* Updating the source `TextLabel.Text` is the main usage pattern.
* `TextScaled` is supported.
* If you use icon affixes, make sure the asset IDs are valid image assets.
* If your UI is extremely small, consider adding a `UITextSizeConstraint` to the source label.
* This **should** work with React and Fusion

# 🛠️ Installation

### Wally

```
[dependencies]
NumberSpinnerV2 = "biotoxin495/NumberSpinnerV2@1.2.0"
```

Then require it from your package location depending on your project setup. - for example:

```
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NumberSpinnerV2 = require(ReplicatedStorage.Packages.NumberSpinnerV2)
```

### Manual install

You can also copy the standalone ModuleScript into your project manually, by copying it from the placeholder game below.


# 🔗 Links

* GitHub: [NumberSpinnerV2](https://github.com/biotoxin495/NumberSpinnerV2)
* Wally: [NumberSpinnerV2](https://wally.run/package/biotoxin495/numberspinnerv2?version=1.2.0)
* Roblox demo showcase game (Uncopylocked): [NumberSpinnerV2 Showcase](https://www.roblox.com/games/128706398575811/NumberSpinnerV2-Showcase)

Please let me know your feedback, if you've found any bugs, edge cases or similar.
Thanks for checking it out!