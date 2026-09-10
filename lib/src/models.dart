import 'package:flutter/material.dart';

/// Visual theme applied to the whole bar while a given [TopBarTab] is
/// active.
///
/// Exactly one background style is used, resolved in this order:
/// [backgroundImageUrl] (or [backgroundImage]) > [gradient] > [backgroundColor].
/// Provide whichever one matches the look you want for this theme.
class TopBarTheme {
  /// Header + tab-section background gradient, top-to-bottom. Ignored if
  /// [backgroundImage]/[backgroundImageUrl] is set.
  final List<Color>? gradient;

  /// Solid header + tab-section background color, used only if neither
  /// [gradient] nor an image is set.
  final Color? backgroundColor;

  /// Header + tab-section background image decoration. Takes precedence
  /// over [backgroundImageUrl] if both are set.
  final DecorationImage? backgroundImage;

  /// Header + tab-section background image path or URL. Takes precedence
  /// over [gradient] and [backgroundColor].
  final String? backgroundImageUrl;

  /// Background color of the page / search area behind the active tab.
  /// Usually the same across all themes.
  final Color pageBackground;

  /// Solid color applied to the selected notch cutout / active tab
  /// background. If null, it is derived from this theme's own background
  /// ([backgroundColor], or the first [gradient] color, or [pageBackground])
  /// so the notch always matches whatever background style this theme uses.
  final Color? notchColor;

  /// If true, greeting/title text renders in dark color (use for light
  /// backgrounds like mint/amber). Defaults to false (white text), suited
  /// to darker backgrounds.
  final bool useDarkForeground;

  const TopBarTheme({
    this.gradient,
    this.backgroundColor,
    this.backgroundImage,
    this.backgroundImageUrl,
    this.pageBackground = const Color(0xFFFDFAF6),
    this.notchColor,
    this.useDarkForeground = false,
  }) : assert(
          gradient != null ||
              backgroundColor != null ||
              backgroundImage != null ||
              backgroundImageUrl != null,
          'TopBarTheme requires one of gradient, backgroundColor, backgroundImage, or backgroundImageUrl',
        );

  /// The effective solid color for the notch/active-tab background:
  /// [notchColor] if set, otherwise derived from this theme's own
  /// background so it always matches.
  Color get effectiveNotchColor =>
      notchColor ?? backgroundColor ?? gradient?.first ?? pageBackground;

  static const green = TopBarTheme(
    gradient: [Color(0xFF8FBF9A), Color(0xFFA9D0AF)],
  );
  static const purple = TopBarTheme(
    gradient: [Color(0xFF6C5CE0), Color(0xFF8A78E8)],
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

  /// Image path or URL displayed when the tab is unselected (rendered with BoxFit.cover).
  final String? unselectedImage;

  /// Transparent PNG image path or URL displayed when the tab is selected.
  final String? selectedImage;

  /// Optional custom widget shown when this tab is unselected.
  final Widget? unselectedWidget;

  /// Optional custom widget shown when this tab is selected.
  final Widget? selectedWidget;

  /// Optional background color when this tab is selected (notch cutout fill).
  /// Ignored if [selectedGradient] is set.
  final Color? selectedColor;

  /// Optional background gradient when this tab is selected (notch cutout
  /// fill), top-to-bottom. Needs at least 2 colors to paint as a gradient;
  /// takes precedence over [selectedColor] when set.
  final List<Color>? selectedGradient;

  /// Optional background color when this tab is unselected.
  final Color? unselectedColor;

  /// Optional icon/text color when this tab is selected.
  final Color? selectedItemColor;

  /// Optional icon/text color when this tab is unselected.
  final Color? unselectedItemColor;

  /// If false, this tab can't be tapped/selected and renders at reduced
  /// opacity (e.g. for a "coming soon" destination). Defaults to true.
  final bool enabled;

  const TopBarTab({
    this.label = '',
    this.sub,
    required this.theme,
    this.unselectedImage,
    this.selectedImage,
    this.unselectedWidget,
    this.selectedWidget,
    this.selectedColor,
    this.selectedGradient,
    this.unselectedColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.enabled = true,
  });
}
