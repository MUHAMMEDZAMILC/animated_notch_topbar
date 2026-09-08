import 'package:flutter/material.dart';

/// Visual theme applied to the whole bar while a given [TopBarTab] is
/// active — gradient header background, page/notch background, status
/// bar text color, and whether the decorative balloon is shown.
class TopBarTheme {
  /// Header background gradient, top-to-bottom.
  final List<Color> gradient;

  /// Background color of the page / search area / the notch cutout
  /// behind the active tab. Usually the same across all themes.
  final Color pageBackground;

  /// If true, status bar and greeting text render in dark color
  /// (use for light gradients like mint/amber). Defaults to false
  /// (white text), suited to darker gradients.
  final bool useDarkForeground;

  /// If true, shows the decorative balloon illustration in the
  /// top-right corner of the header while this theme is active.
  final bool showBalloon;

  const TopBarTheme({
    required this.gradient,
    this.pageBackground = const Color(0xFFFDFAF6),
    this.useDarkForeground = false,
    this.showBalloon = false,
  });

  static const green = TopBarTheme(
    gradient: [Color(0xFF8FBF9A), Color(0xFFA9D0AF)],
  );
  static const purple = TopBarTheme(
    gradient: [Color(0xFF6C5CE0), Color(0xFF8A78E8)],
    showBalloon: true,
  );
  static const mint = TopBarTheme(
    gradient: [Color(0xFFEAF4D8), Color(0xFFD8ECC4)],
    useDarkForeground: true,
  );
  static const amber = TopBarTheme(
    gradient: [Color(0xFFF3DDB0), Color(0xFFECD196)],
    useDarkForeground: true,
  );
}

/// A single tab in the [AnimatedNotchTopBar].
class TopBarTab {
  /// Main label, shown bold when text is rendered.
  final String label;

  /// Optional secondary line under [label] (e.g. "OFF ZONE").
  final String? sub;

  /// Theme applied to the whole bar while this tab is active.
  final TopBarTheme theme;

  /// If true, renders this tab with a solid brand-colored pill
  /// (see [brandColor]) instead of white, when inactive.
  final bool useBrandColor;

  /// Fill color used when [useBrandColor] is true and the tab is
  /// inactive. Defaults to a blue accent.
  final Color brandColor;

  /// Image path or URL displayed when the tab is unselected (rendered with BoxFit.cover).
  final String? unselectedImage;

  /// Transparent PNG image path or URL displayed when the tab is selected.
  final String? selectedImage;

  /// Optional custom widget shown when this tab is unselected.
  final Widget? unselectedWidget;

  /// Optional custom widget shown when this tab is selected.
  final Widget? selectedWidget;

  const TopBarTab({
    this.label = '',
    this.sub,
    required this.theme,
    this.useBrandColor = false,
    this.brandColor = const Color(0xFF2B1FF0),
    this.unselectedImage,
    this.selectedImage,
    this.unselectedWidget,
    this.selectedWidget,
  });
}
