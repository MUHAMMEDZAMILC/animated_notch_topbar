import 'package:flutter/material.dart';

import 'models.dart';
import 'notch_painter.dart';

/// An animated top app bar with a sliding "notch" pill indicator over
/// the active tab and per-tab gradient themes.
///
/// Tab spacing is measured live from each tab's actual rendered
/// width/position (via [GlobalKey]/[RenderBox]) rather than assumed —
/// so the notch and the small push-margin on neighbouring tabs stay
/// correctly centered at any bar width.
class AnimatedNotchTopBar extends StatefulWidget {
  /// The tabs to display. Must contain at least one entry.
  final List<TopBarTab> tabs;

  /// Index of the initially-selected tab.
  final int initialIndex;

  /// Called with the new index whenever the user taps a different tab.
  final ValueChanged<int>? onTabChanged;

  /// Called with the tapped index whenever the user taps a tab whose
  /// [TopBarTab.enabled] is false (e.g. a "coming soon" destination),
  /// instead of switching to it. Use this to show a poster, dialog, or
  /// any other app-specific feedback.
  final ValueChanged<int>? onDisabledTabTap;

  /// Optional custom leading widget in the top app bar (e.g. BackButton or Drawer icon).
  final Widget? leading;

  /// Optional custom title widget in the top app bar.
  final Widget? title;

  /// Whether the [title] should be centered. Defaults to false.
  final bool centerTitle;

  /// Optional action widgets displayed on the right of the app bar.
  final List<Widget>? actions;

  /// Background gradient for the whole bar (app bar section + tab section),
  /// overriding the active tab's [TopBarTheme.gradient].
  final Gradient? gradient;

  /// Background image decoration for the whole bar, overriding the active
  /// tab's [TopBarTheme.backgroundImage]/[TopBarTheme.backgroundImageUrl].
  /// Takes precedence over [gradient] and [backgroundColor] when set.
  final DecorationImage? backgroundImage;

  /// Background image path or URL for the whole bar, overriding the active
  /// tab's theme. Takes precedence over [gradient] and [backgroundColor].
  final String? backgroundImageUrl;

  /// Solid background color for the whole bar, overriding the active tab's
  /// [TopBarTheme.backgroundColor]. Used only if no gradient or image is
  /// resolved.
  final Color? backgroundColor;

  /// Fill color for the notch cutout and active tab background.
  /// Falls back to active tab's [TopBarTab.selectedColor] or
  /// [TopBarTheme.effectiveNotchColor] (which itself matches the active
  /// theme's own background — color, gradient, or image).
  final Color? selectedWidgetColor;

  /// Background color for unselected tabs.
  /// Falls back to tab's [TopBarTab.unselectedColor] or brand color / white.
  final Color? unselectedColor;

  /// Color for active tab text/icon.
  final Color? selectedItemColor;

  /// Color for inactive tab text/icon.
  final Color? unselectedItemColor;

  /// Height of the tab cards. Defaults to 46.92.
  final double tabHeight;

  /// Height of the sliding notch cutout. Defaults to 56.92.
  final double notchHeight;

  /// Gap between tab items and horizontal padding. Defaults to 11.0.
  final double tabGap;

  /// Corner radius of the notch cutout curves. Defaults to 9.62.
  final double notchCornerRadius;

  /// Corner radius of the tab cards. Defaults to 9.62.
  final double tabBorderRadius;

  /// Whether to strictly validate that [tabs] has exactly 4 items.
  final bool validateFourTabs;

  /// Greeting name string displayed if [title] is not provided.
  final String greetingName;

  /// Location subtitle string displayed if [title] is not provided.
  final String locationLabel;

  /// Callback when the location label is tapped.
  final VoidCallback? onLocationTap;

  /// Callback when the default bell action is tapped.
  final VoidCallback? onBellTap;

  /// Duration of the notch sliding shape animation.
  final Duration shapeAnimationDuration;

  /// Duration of the gradient / color transition animations.
  final Duration themeAnimationDuration;

  /// Outer border radius of the entire top bar container. Defaults to 36 (or 0 for edge-to-edge).
  final double borderRadius;

  const AnimatedNotchTopBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.onDisabledTabTap,
    this.leading,
    this.title,
    this.centerTitle = false,
    this.actions,
    this.gradient,
    this.backgroundImage,
    this.backgroundImageUrl,
    this.backgroundColor,
    this.selectedWidgetColor,
    this.unselectedColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.tabHeight = 46.92,
    this.notchHeight = 56.92,
    this.tabGap = 11,
    this.notchCornerRadius = 9.62,
    this.tabBorderRadius = 9.62,
    this.validateFourTabs = false,
    this.greetingName = '',
    this.locationLabel = '',
    this.onLocationTap,
    this.onBellTap,
    this.shapeAnimationDuration = const Duration(milliseconds: 400),
    this.themeAnimationDuration = const Duration(milliseconds: 450),
    this.borderRadius = 36,
  })  : assert(tabs.length > 0, 'AnimatedNotchTopBar needs at least one tab'),
        assert(
          !validateFourTabs || tabs.length == 4,
          'AnimatedNotchTopBar requires exactly 4 tabs when validateFourTabs is true',
        );

  @override
  State<AnimatedNotchTopBar> createState() => _AnimatedNotchTopBarState();
}

class _AnimatedNotchTopBarState extends State<AnimatedNotchTopBar> {
  static const double _kShapeWidth = 89.02;

  late int activeIndex = widget.initialIndex;

  late List<GlobalKey> _tabKeys =
      List.generate(widget.tabs.length, (_) => GlobalKey());
  final GlobalKey _tabbarKey = GlobalKey();

  double _shapeLeft = 0;
  double _shapeWidth = _kShapeWidth;
  bool _measuredOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant AnimatedNotchTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
      _measuredOnce = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    if (!mounted) return;
    final tabbarBox =
        _tabbarKey.currentContext?.findRenderObject() as RenderBox?;
    final activeBox =
        _tabKeys[activeIndex].currentContext?.findRenderObject() as RenderBox?;
    if (tabbarBox == null || activeBox == null) return;

    final tabWidth = activeBox.size.width;
    final activeTopLeft =
        activeBox.localToGlobal(Offset.zero, ancestor: tabbarBox);

    setState(() {
      _shapeLeft = activeTopLeft.dx;
      _shapeWidth = tabWidth;
      _measuredOnce = true;
    });
  }

  void _selectTab(int index) {
    if (index == activeIndex || !widget.tabs[index].enabled) return;
    setState(() => activeIndex = index);
    widget.onTabChanged?.call(index);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.tabs[activeIndex].theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

        final hasWidgetOverride = widget.backgroundImage != null ||
            (widget.backgroundImageUrl?.isNotEmpty ?? false) ||
            widget.gradient != null ||
            widget.backgroundColor != null;

        final bgImage = hasWidgetOverride
            ? _resolveImage(widget.backgroundImage, widget.backgroundImageUrl)
            : _resolveImage(theme.backgroundImage, theme.backgroundImageUrl);

        final gradientColors = hasWidgetOverride ? null : theme.gradient;
        final gradient = bgImage != null
            ? null
            : widget.gradient ??
                (gradientColors != null
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: gradientColors,
                      )
                    : null);

        final color = (bgImage != null || gradient != null)
            ? null
            : widget.backgroundColor ??
                theme.backgroundColor ??
                theme.pageBackground;

        return AnimatedContainer(
          duration: widget.themeAnimationDuration,
          decoration: BoxDecoration(
            color: color,
            image: bgImage,
            gradient: gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(theme),
              _buildTabbar(theme),
            ],
          ),
        );
      },
    );
  }

  DecorationImage? _resolveImage(DecorationImage? explicit, String? url) {
    if (explicit != null) return explicit;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return DecorationImage(image: NetworkImage(url), fit: BoxFit.cover);
      }
      return DecorationImage(image: AssetImage(url), fit: BoxFit.cover);
    }
    return null;
  }

  Widget _buildHeader(TopBarTheme theme) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final effectiveTopPadding = topPadding > 0 ? topPadding + 6 : 14.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, effectiveTopPadding, 20, 14),
      child: _buildAppBarContent(theme),
    );
  }

  /// The effective title widget: [widget.title] if provided, otherwise a
  /// merged "welcome message + location" widget built from [greetingName]
  /// and [locationLabel] (or null if neither is set).
  Widget? _resolveTitle(TopBarTheme theme) {
    if (widget.title != null) return widget.title;
    if (widget.greetingName.isEmpty && widget.locationLabel.isEmpty) {
      return null;
    }

    return GestureDetector(
      onTap: widget.onLocationTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: (widget.centerTitle == true)
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (widget.greetingName.isNotEmpty)
            AnimatedDefaultTextStyle(
              duration: widget.themeAnimationDuration,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: theme.useDarkForeground
                    ? const Color(0xFF26311F)
                    : Colors.white,
              ),
              child: Text('Hi, ${widget.greetingName} 👋'),
            ),
          if (widget.greetingName.isNotEmpty && widget.locationLabel.isNotEmpty)
            const SizedBox(height: 4),
          if (widget.locationLabel.isNotEmpty)
            AnimatedDefaultTextStyle(
              duration: widget.themeAnimationDuration,
              style: TextStyle(
                fontSize: 12.5,
                color: theme.useDarkForeground
                    ? const Color(0xB01E2814)
                    : const Color(0xE6FFFFFF),
              ),
              child: Text('📍 ${widget.locationLabel} ⌄'),
            ),
        ],
      ),
    );
  }

  /// The effective trailing (actions) widget: the [widget.actions] list
  /// wrapped in a [Row], falling back to the default bell button.
  Widget _resolveActions() {
    if (widget.actions != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.actions!,
      );
    }
    return _buildBellButton();
  }

  Widget _buildAppBarContent(TopBarTheme theme) {
    final title = _resolveTitle(theme) ?? const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: widget.centerTitle == true ? Center(child: title) : title,
        ),
        const SizedBox(width: 12),
        _resolveActions(),
      ],
    );
  }

  Widget _buildBellButton() {
    return GestureDetector(
      onTap: widget.onBellTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xE6FFFFFF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text('🔔', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildTabbar(TopBarTheme theme) {
    final activeTab = widget.tabs[activeIndex];
    final notchColor = activeTab.selectedColor ??
        widget.selectedWidgetColor ??
        theme.effectiveNotchColor;

    return SizedBox(
      height: widget.notchHeight,
      child: Stack(
        key: _tabbarKey,
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: widget.shapeAnimationDuration,
            curve: Curves.easeInOut,
            top: 0,
            left: _measuredOnce ? _shapeLeft : widget.tabGap,
            width: _measuredOnce ? _shapeWidth : _kShapeWidth,
            height: widget.notchHeight,
            child: CustomPaint(
              painter: NotchPainter(
                color: notchColor,
                cornerRadius: widget.notchCornerRadius,
              ),
              child: SizedBox(
                width: _measuredOnce ? _shapeWidth : _kShapeWidth,
                height: widget.notchHeight,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.tabGap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.tabs.length * 2 - 1, (i) {
                if (i.isOdd) return SizedBox(width: widget.tabGap);
                final index = i ~/ 2;
                return Expanded(child: _buildTab(index));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index) {
    final tab = widget.tabs[index];
    final isActive = index == activeIndex;

    Widget content;
    if (isActive) {
      if (tab.selectedWidget != null) {
        content = tab.selectedWidget!;
      } else if (tab.selectedImage != null && tab.selectedImage!.isNotEmpty) {
        content = Center(
          child: _buildImage(
            tab.selectedImage!,
            fit: BoxFit.contain,
            height: widget.tabHeight * 0.65,
          ),
        );
      } else {
        content = _buildDefaultText(tab, isActive: true);
      }
    } else {
      if (tab.unselectedWidget != null) {
        content = tab.unselectedWidget!;
      } else if (tab.unselectedImage != null &&
          tab.unselectedImage!.isNotEmpty) {
        content = SizedBox.expand(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.tabBorderRadius),
            child: _buildImage(
              tab.unselectedImage!,
              fit: BoxFit.cover,
            ),
          ),
        );
      } else {
        content = _buildDefaultText(tab, isActive: false);
      }
    }

    final unselectedBg =
        tab.unselectedColor ?? widget.unselectedColor ?? Colors.white;

    return AnimatedOpacity(
      duration: widget.shapeAnimationDuration,
      opacity: tab.enabled ? 1 : 0.45,
      child: AnimatedContainer(
        key: _tabKeys[index],
        duration: widget.shapeAnimationDuration,
        curve: Curves.easeInOut,
        height: widget.tabHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isActive ? Colors.transparent : unselectedBg,
          borderRadius: BorderRadius.circular(widget.tabBorderRadius),
          boxShadow: isActive
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.tabBorderRadius),
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: tab.enabled
                ? () => _selectTab(index)
                : () => widget.onDisabledTabTap?.call(index),
            child: SizedBox.expand(
              child: Center(
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultText(TopBarTab tab, {required bool isActive}) {
    if (tab.label.isEmpty && tab.sub == null) {
      return const SizedBox.shrink();
    }
    final activeTextColor =
        tab.selectedItemColor ?? widget.selectedItemColor ?? Colors.black;
    final inactiveTextColor = tab.unselectedItemColor ??
        widget.unselectedItemColor ??
        const Color(0xFF1C1C1C);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tab.label.isNotEmpty)
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.1,
              color: isActive ? activeTextColor : inactiveTextColor,
            ),
          ),
        if (tab.sub != null)
          Text(
            tab.sub!,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? activeTextColor.withValues(alpha: 0.85)
                  : const Color(0xFF8A8A8A),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(
    String pathOrUrl, {
    required BoxFit fit,
    double? width,
    double? height,
  }) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) =>
            Icon(Icons.image, size: (height ?? 24) * 0.7, color: Colors.grey),
      );
    }
    return Image.asset(
      pathOrUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.image, size: (height ?? 24) * 0.7, color: Colors.grey),
    );
  }
}
