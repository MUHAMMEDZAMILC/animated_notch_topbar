# animated_notch_topbar

An animated top app bar for Flutter with a sliding "notch" pill
indicator over the active tab, per-tab gradient header themes, a
decorative balloon accent, and a built-in search field — ported from a
custom mobile UI design.

![preview](https://via.placeholder.com/380x260.png?text=Screenshot+goes+here)

## Features

- Sliding notch-cutout indicator that measures real tab widths at
  layout time, so spacing stays correct at any bar width (no
  hardcoded magic numbers).
- Per-tab `TopBarTheme` — swap the header gradient, status-bar text
  color, and an optional balloon illustration when a tab is selected.
- Optional greeting/location header row, notification bell, and
  search field, each independently toggleable.
- Fully driven by data — pass any number of `TopBarTab`s.

## Getting started

```yaml
dependencies:
  animated_notch_topbar: ^0.0.1
```

## Usage

```dart
import 'package:animated_notch_topbar/animated_notch_topbar.dart';

AnimatedNotchTopBar(
  greetingName: 'Dilshad',
  locationLabel: 'Location disabled',
  searchHint: 'mobiles',
  tabs: const [
    TopBarTab(label: 'COFFEE LABS', theme: TopBarTheme.green),
    TopBarTab(
      label: 'Super Mall',
      theme: TopBarTheme.purple,
      useBrandColor: true,
    ),
    TopBarTab(label: '50%', sub: 'OFF ZONE', theme: TopBarTheme.mint),
    TopBarTab(label: 'Make a Print', theme: TopBarTheme.amber),
  ],
  onTabChanged: (index) => debugPrint('Selected $index'),
)
```

See `example/lib/main.dart` for a runnable app.

## Customizing themes

```dart
const myTheme = TopBarTheme(
  gradient: [Color(0xFFFF6B6B), Color(0xFFFFA36B)],
  useDarkForeground: false,
  showBalloon: false,
);
```

## Additional information

Issues and PRs welcome at the repository linked in `pubspec.yaml`
(update that URL to your own fork/repo before publishing).
