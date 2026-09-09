# animated_notch_topbar

An animated top app bar for Flutter with a sliding "notch" pill
indicator over the active tab and per-tab gradient header themes.

<!--
TODO: demo GIF — once doc/demo.gif is added, uncomment:
<p align="center">
  <img src="doc/demo.gif" alt="animated_notch_topbar demo" width="320">
</p>
-->

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
- No tap ripple/highlight/hover artifacts on tab selection — a clean,
  flat press.
- Fully driven by data — pass any number of `TopBarTab`s.

## Getting started

```yaml
dependencies:
  animated_notch_topbar: ^0.0.3
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

See `example/lib/main.dart` for a runnable app, including a full
data-driven setup that maps a `/destinations`-style API response onto
`TopBarTab`/`TopBarTheme` — see `example/DESTINATIONS_API.md` for that
response contract.

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

## Author

Built and maintained by **Muhammed Zamil C**.

- LinkedIn: [muhammed-zamil-c](https://www.linkedin.com/in/muhammed-zamil-c-4506ab243/)
- GitHub: [@MUHAMMEDZAMILC](https://github.com/MUHAMMEDZAMILC/)
