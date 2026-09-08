import 'package:flutter/material.dart';

import 'models.dart';
import 'notch_painter.dart';

/// An animated top app bar with a sliding "notch" pill indicator over
/// the active tab, per-tab gradient themes, and an optional search
/// field.
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

  /// Optional custom leading widget in the top app bar (e.g. BackButton or Drawer icon).
  final Widget? leading;

  /// Optional custom title widget in the top app bar.
  final Widget? title;

  /// Whether the [title] should be centered. Defaults to false.
  final bool centerTitle;

  /// Optional action widgets displayed on the right of the app bar.
  final List<Widget>? actions;

  /// App bar background gradient. If null, uses the active tab's [TopBarTheme.gradient].
  final Gradient? gradient;

  /// App bar background image decoration.
  final DecorationImage? backgroundImage;

  /// App bar background image path or URL.
  final String? backgroundImageUrl;

  /// Solid app bar background color (used if no gradient or image specified).
  final Color? backgroundColor;

  /// Fill color for the notch cutout and active tab background.
  /// Falls back to active tab's [TopBarTab.selectedColor] or [TopBarTheme.pageBackground].
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

  /// Custom search bar widget replacing the default search input.
  final Widget? searchBar;

  /// Set to null to hide the search field entirely.
  final String? searchHint;

  /// Callback when search field is tapped.
  final VoidCallback? onSearchTap;

  /// Clock text shown at the top-left of the status bar row.
  /// Pass null to use device status bar or hide status bar row.
  final String? statusTime;

  /// Optional custom status bar widget.
  final Widget? statusBar;

  /// Whether to show the decorative balloon illustration (if null, uses active theme).
  final bool? showBalloon;

  /// Custom decorative widget replacing the default balloon illustration.
  final Widget? balloonWidget;

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
    this.searchBar,
    this.searchHint = 'Search',
    this.onSearchTap,
    this.statusTime = '9:41',
    this.statusBar,
    this.showBalloon,
    this.balloonWidget,
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
    if (index == activeIndex) return;
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
        return Container(
          decoration: BoxDecoration(
            color: theme.pageBackground,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(theme),
              if (widget.searchBar != null)
                widget.searchBar!
              else if (widget.searchHint != null)
                _buildSearchBar(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(TopBarTheme theme) {
    if (widget.statusBar != null) return widget.statusBar!;
    final color =
        theme.useDarkForeground ? const Color(0xFF26311F) : Colors.white;
    return AnimatedDefaultTextStyle(
      duration: widget.themeAnimationDuration,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.statusTime!),
            Text('▂▄▆ 5G 🔋', style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  DecorationImage? _resolveBackgroundImage() {
    if (widget.backgroundImage != null) return widget.backgroundImage;
    if (widget.backgroundImageUrl != null &&
        widget.backgroundImageUrl!.isNotEmpty) {
      final url = widget.backgroundImageUrl!;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return DecorationImage(image: NetworkImage(url), fit: BoxFit.cover);
      }
      return DecorationImage(image: AssetImage(url), fit: BoxFit.cover);
    }
    return null;
  }

  Widget _buildHeader(TopBarTheme theme) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final effectiveTopPadding = widget.statusTime != null
        ? 4.0
        : (topPadding > 0 ? topPadding + 6 : 14.0);

    final bgImage = _resolveBackgroundImage();
    final gradient = widget.gradient ??
        (widget.backgroundColor == null && bgImage == null
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: theme.gradient,
              )
            : null);

    final showBalloon = widget.showBalloon ?? theme.showBalloon;

    return AnimatedContainer(
      duration: widget.themeAnimationDuration,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        image: bgImage,
        gradient: gradient,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, effectiveTopPadding, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.statusTime != null || widget.statusBar != null)
                  _buildStatusBar(theme),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (showBalloon)
                      Positioned(
                        top: -18,
                        right: -6,
                        child: AnimatedOpacity(
                          duration: widget.themeAnimationDuration,
                          opacity: 1,
                          child: widget.balloonWidget ??
                              const BalloonIcon(width: 78),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildAppBarContent(theme),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildTabbar(theme),
        ],
      ),
    );
  }

  Widget _buildAppBarContent(TopBarTheme theme) {
    if (widget.title != null ||
        widget.leading != null ||
        widget.actions != null) {
      return NavigationToolbar(
        leading: widget.leading,
        middle: widget.title,
        trailing: widget.actions != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.actions!,
              )
            : (widget.onBellTap != null
                ? _buildBellButton()
                : null),
        centerMiddle: widget.centerTitle == true,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: GestureDetector(
            onTap: widget.onLocationTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
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
          ),
        ),
        if (widget.actions != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.actions!,
          )
        else
          _buildBellButton(),
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
        theme.pageBackground;

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

    final unselectedBg = tab.unselectedColor ??
        widget.unselectedColor ??
        (tab.useBrandColor ? tab.brandColor : Colors.white);

    return AnimatedContainer(
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
          onTap: () => _selectTab(index),
          child: SizedBox.expand(
            child: Center(
              child: content,
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
    final activeTextColor = tab.selectedItemColor ??
        widget.selectedItemColor ??
        Colors.black;
    final inactiveTextColor = tab.unselectedItemColor ??
        widget.unselectedItemColor ??
        (tab.useBrandColor ? Colors.white : const Color(0xFF1C1C1C));

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
                  ? activeTextColor.withOpacity(0.85)
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

  Widget _buildSearchBar(TopBarTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: theme.pageBackground,
      child: GestureDetector(
        onTap: widget.onSearchTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFECE6DA)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 15, color: Color(0xFF9A9488)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.searchHint!,
                  style: const TextStyle(
                      fontSize: 13.5, color: Color(0xFF6B665C)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
