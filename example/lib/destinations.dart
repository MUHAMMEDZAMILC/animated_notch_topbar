import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:animated_notch_topbar/animated_notch_topbar.dart';

/// A background spec as returned by the destinations API. [type] is the
/// authoritative switch between the three supported kinds:
/// - `'solid'`   — use `colors[0]`.
/// - `'gradient'` — use all of `colors` as stops, direction from `angle`
///   (CSS-style degrees; 180 = top-to-bottom).
/// - `'image'`   — use `image` (asset path or URL); `mediaType` describes
///   what kind of media `image` points to. Both `'image'` and `'gif'` are
///   rendered the same way (via [Image.network]/[Image.asset], which decode
///   and animate multi-frame GIFs automatically) — `mediaType` is otherwise
///   informational.
class TabBackground {
  final String type; // 'solid' | 'gradient' | 'image'
  final List<Color> colors;
  final double angle;
  final String? image;
  final String? mediaType; // 'image' | 'gif' (only supported kinds for now)

  const TabBackground({
    required this.type,
    required this.colors,
    required this.angle,
    this.image,
    this.mediaType,
  });

  factory TabBackground.fromJson(Map<String, dynamic> json) {
    return TabBackground(
      type: json['type'] as String? ?? 'solid',
      colors: ((json['colors'] as List?) ?? const [])
          .map((c) => _colorFromHex(c as String))
          .toList(),
      angle: (json['angle'] as num?)?.toDouble() ?? 180,
      image: json['image'] as String?,
      mediaType: json['mediaType'] as String?,
    );
  }

  static const _supportedMediaTypes = {'image', 'gif'};

  bool get hasImage =>
      type == 'image' &&
      _supportedMediaTypes.contains(mediaType) &&
      (image?.isNotEmpty ?? false);

  bool get isGradient => type == 'gradient' && colors.length > 1;

  /// The single representative color for this background — the first
  /// gradient stop, or the solid color.
  Color get solidColor => colors.isNotEmpty ? colors.first : Colors.white;

  LinearGradient? toGradient() {
    if (!isGradient) return null;
    final rad = angle * math.pi / 180;
    final dx = math.sin(rad);
    final dy = -math.cos(rad);
    return LinearGradient(
      begin: Alignment(-dx, -dy),
      end: Alignment(dx, dy),
      colors: colors,
    );
  }

  /// Resolves this background into a [BoxDecoration] — image, gradient, or
  /// solid color, in that precedence order (same as [TopBarTheme]'s own
  /// resolution).
  BoxDecoration toBoxDecoration() {
    if (hasImage) {
      final url = image!;
      final provider = url.startsWith('http://') || url.startsWith('https://')
          ? NetworkImage(url)
          : AssetImage(url) as ImageProvider;
      return BoxDecoration(
          image: DecorationImage(image: provider, fit: BoxFit.cover));
    }
    final gradient = toGradient();
    if (gradient != null) return BoxDecoration(gradient: gradient);
    return BoxDecoration(color: solidColor);
  }
}

Color _colorFromHex(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

/// One entry from the destinations API response.
class Destination {
  final String id;
  final String key;

  /// Image shown for this tab while it's unselected. If null and
  /// [selectedImage] is set, [selectedImage] is reused here too. If both are
  /// null/empty, this destination has no icon and renders as text instead
  /// (see [destinationToTab]).
  final String? unselectedImage;

  /// Image shown for this tab while it's selected. If null and
  /// [unselectedImage] is set, [unselectedImage] is reused here too, so the
  /// icon never disappears when tapped.
  final String? selectedImage;

  final bool isComingSoon;
  final String label;
  final int order;
  final TabBackground tabBackground;
  final TabBackground tabRowBackground;

  /// Background for the page/body content shown below the bar while this
  /// destination is active — independent of [tabBackground]/[tabRowBackground].
  /// Falls back to [tabRowBackground] if the API doesn't send it, so older
  /// payloads still work.
  final TabBackground pageBackground;

  /// Poster image (asset path or URL) to show in a bottom sheet when this
  /// destination is tapped while [isComingSoon]. Null if the API didn't
  /// provide one.
  final String? posterUrl;

  /// Opacity this tab renders at while [isComingSoon] is true. Null means
  /// "use the bar's own default" ([AnimatedNotchTopBar.disabledOpacity]);
  /// send `1` here to keep a specific coming-soon destination at full
  /// opacity instead of the usual dimmed look. Ignored while
  /// [isComingSoon] is false.
  final double? comingSoonOpacity;

  const Destination({
    required this.id,
    required this.key,
    this.unselectedImage,
    this.selectedImage,
    required this.isComingSoon,
    required this.label,
    required this.order,
    required this.tabBackground,
    required this.tabRowBackground,
    required this.pageBackground,
    this.posterUrl,
    this.comingSoonOpacity,
  });

  /// Whether this destination is currently selectable (the inverse of
  /// [isComingSoon]).
  bool get isActive => !isComingSoon;

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['_id'] as String,
      key: json['key'] as String,
      unselectedImage: json['unselectedImage'] as String?,
      selectedImage: json['selectedImage'] as String?,
      isComingSoon: json['isComingSoon'] as bool? ?? false,
      label: json['label'] as String,
      order: json['order'] as int? ?? 0,
      tabBackground:
          TabBackground.fromJson(json['tabBackground'] as Map<String, dynamic>),
      tabRowBackground: TabBackground.fromJson(
          json['tabRowBackground'] as Map<String, dynamic>),
      pageBackground: json['pageBackground'] != null
          ? TabBackground.fromJson(
              json['pageBackground'] as Map<String, dynamic>)
          : TabBackground.fromJson(
              json['tabRowBackground'] as Map<String, dynamic>),
      posterUrl: json['posterUrl'] as String?,
      comingSoonOpacity: (json['comingSoonOpacity'] as num?)?.toDouble(),
    );
  }

  static List<Destination> listFromJson(Map<String, dynamic> json) {
    final list = (json['destinations'] as List)
        .map((e) => Destination.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return list;
  }
}

/// Builds a [TopBarTab] from a [Destination]:
/// - [Destination.tabRowBackground] (the bar's overall background for this
///   destination) becomes the [TopBarTheme]'s gradient/color/image.
/// - [Destination.tabBackground] (the individual tab's own background)
///   becomes the tab's notch fill: [TopBarTab.selectedColor] for a
///   `"solid"` background, or [TopBarTab.selectedGradient] (which takes
///   precedence) for a `"gradient"` one — matching whichever [type] the
///   API sent for that destination's `tabBackground`.
/// - [Destination.isComingSoon] disables the tab ([TopBarTab.enabled]) and
///   shows a "Coming soon" sub-label. [Destination.comingSoonOpacity]
///   becomes [TopBarTab.disabledOpacity] — null keeps the bar's own
///   default dimmed look ([AnimatedNotchTopBar.disabledOpacity]), while a
///   value (e.g. `1`) overrides it for just this destination.
/// - [Destination.unselectedImage]/[Destination.selectedImage] decide
///   whether the tab renders as an icon or as text — never both. If either
///   image is set, the tab shows images in both states (missing one falls
///   back to the other, so the icon never disappears when tapped), and
///   [Destination.label] is then only used for the "coming soon" sheet
///   title, not shown on the tab itself. If neither image is set, the tab
///   shows [Destination.label] as text in both states instead.
TopBarTab destinationToTab(Destination d) {
  final row = d.tabRowBackground;
  final unselectedImage = d.unselectedImage ?? d.selectedImage;
  final selectedImage = d.selectedImage ?? d.unselectedImage;

  final theme = TopBarTheme(
    gradient: row.isGradient ? row.colors : null,
    backgroundColor: !row.isGradient && !row.hasImage ? row.solidColor : null,
    backgroundImageUrl: row.hasImage ? row.image : null,
    useDarkForeground: _isLight(row.solidColor),
  );

  return TopBarTab(
    label: d.label,
    sub: d.isComingSoon ? 'Coming soon' : null,
    theme: theme,
    selectedColor: d.tabBackground.solidColor,
    selectedGradient:
        d.tabBackground.isGradient ? d.tabBackground.colors : null,
    unselectedImage: unselectedImage,
    selectedImage: selectedImage,
    enabled: d.isActive,
    disabledOpacity: d.comingSoonOpacity,
  );
}

bool _isLight(Color color) => color.computeLuminance() > 0.6;
