# color_utils

Useful utils and extensions over Flutter's built-in `Color` data type.

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dependencies:
  color_utils: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  color_utils:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: color_utils
      ref: main
```

## Example

### Hex Conversion

- Convert `Color` to Hex representation.
- Convert Hex representation to `Color` (with optional opacity).

```dart
final color = Color(0xFFAABBCC);

// Color to Hex
final Hex = color.toHexString();

// Hex to Color
final color = RepresentationUtils.fromHex('#AABBCC', opacity: 0.5);
```

### Brightness Adjustment

- Darken a color: Reduce the lightness of a color by a specified amount.
- Lighten a color: Increase the lightness of a color by a specified amount.

```dart
// Darken & lighten a given color
final color = Color(0xFF808080); // Grey
final darkened = color.darken(0.2); // Darker grey
final lightened = color.lighten(0.2); // Lighter grey
```

### Color Manipulation

- Invert a color: Get the inverted version of a color with optional opacity.
- Complementary color: Get the complementary color (180° hue shift).
- Check brightness: Determine if a color is dark or light.

```dart
final color = Color(0xFFFF0000); // Red
final inverted = color.invert(1.0); // Cyan
final complementary = color.complementary; // Cyan
final isDark = color.isDark; // false
final isLight = color.isLight; // true
```

### Random Color Generation

Generate a random color: Create a random color with a specified opacity.

```dart
// Random color with 50% opacity
final randomColor = RandomizationUtils.random(0.5);
```

## License

Click [here](../LICENSE) to see the license.