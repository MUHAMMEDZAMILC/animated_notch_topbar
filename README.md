# animated_notch_topbar

An animated top app bar for Flutter with a sliding "notch" pill
indicator over the active tab and per-tab gradient header themes.

## Features

- Sliding notch-cutout indicator that measures real tab widths at
  layout time, so spacing stays correct at any bar width (no
  hardcoded magic numbers).
- Per-tab `TopBarTheme` — swap the header gradient/color/image and
  foreground color when a tab is selected.
- Optional greeting/location header row, notification bell, custom
  `leading`/`title`/`actions`, each independently configurable.
- Per-tab custom images or widgets for the selected/unselected states.
- Disabled ("coming soon") tabs with a dedicated tap callback.
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
  tabs: const [
    TopBarTab(label: 'COFFEE LABS', theme: TopBarTheme.green),
    TopBarTab(label: 'Super Mall', theme: TopBarTheme.purple),
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
);
```

## Additional information

Issues and PRs welcome at the
[repository](https://github.com/MUHAMMEDZAMILC/animated_notch_topbar).
