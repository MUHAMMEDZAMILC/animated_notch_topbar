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

  final String greetingName;
  final String locationLabel;
  final VoidCallback? onLocationTap;
  final VoidCallback? onBellTap;

  /// Set to null to hide the search field entirely.
  final String? searchHint;
  final VoidCallback? onSearchTap;

  /// Clock text shown at the top-left of the status bar row.
  /// Pass null to hide the status bar row entirely.
  final String? statusTime;

  final Duration shapeAnimationDuration;
  final Duration themeAnimationDuration;
  final double borderRadius;

  const AnimatedNotchTopBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.greetingName = '',
    this.locationLabel = '',
    this.onLocationTap,
    this.onBellTap,
    this.searchHint = 'Search',
    this.onSearchTap,
    this.statusTime = '9:41',
    this.shapeAnimationDuration = const Duration(milliseconds: 400),
    this.themeAnimationDuration = const Duration(milliseconds: 450),
    this.borderRadius = 36,
  }) : assert(tabs.length > 0, 'AnimatedNotchTopBar needs at least one tab');

  @override
  State<AnimatedNotchTopBar> createState() => _AnimatedNotchTopBarState();
}

class _AnimatedNotchTopBarState extends State<AnimatedNotchTopBar> {
  static const double _kShapeWidth = 89.02;
  static const double _kShapeHeight = 56.92;
  static const double _kTabHeight = 46.92;
  static const double _kTabGap = 11;
  static const double _kTabbarHPad = _kTabGap;

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
              if (widget.searchHint != null) _buildSearchBar(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(TopBarTheme theme) {
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

  Widget _buildHeader(TopBarTheme theme) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final effectiveTopPadding = widget.statusTime != null
        ? 4.0
        : (topPadding > 0 ? topPadding + 6 : 14.0);

    return AnimatedContainer(
      duration: widget.themeAnimationDuration,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.gradient,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, effectiveTopPadding, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.statusTime != null) _buildStatusBar(theme),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -18,
                      right: -6,
                      child: AnimatedOpacity(
                        duration: widget.themeAnimationDuration,
                        opacity: theme.showBalloon ? 1 : 0,
                        child: const BalloonIcon(width: 78),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onLocationTap,
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      child:
                                          Text('Hi, ${widget.greetingName} 👋'),
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
                                      child:
                                          Text('📍 ${widget.locationLabel} ⌄'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onBellTap,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xE6FFFFFF),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text('🔔',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTabbar(TopBarTheme theme) {
    return SizedBox(
      height: _kShapeHeight,
      child: Stack(
        key: _tabbarKey,
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: widget.shapeAnimationDuration,
            curve: Curves.easeInOut,
            top: 0,
            left: _measuredOnce ? _shapeLeft : _kTabGap,
            width: _measuredOnce ? _shapeWidth : _kShapeWidth,
            height: _kShapeHeight,
            child: CustomPaint(
              painter: NotchPainter(color: theme.pageBackground),
              child: SizedBox(
                  width: _measuredOnce ? _shapeWidth : _kShapeWidth,
                  height: _kShapeHeight),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kTabGap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.tabs.length * 2 - 1, (i) {
                if (i.isOdd) return const SizedBox(width: _kTabGap);
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

    return AnimatedContainer(
      key: _tabKeys[index],
      duration: widget.shapeAnimationDuration,
      curve: Curves.easeInOut,
      height: _kTabHeight,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.transparent
            : (tab.useBrandColor ? tab.brandColor : Colors.white),
        borderRadius: BorderRadius.circular(9.62),
        boxShadow: isActive
            ? null
            : const [
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4)),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9.62),
          onTap: () => _selectTab(index),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.1,
                    color: isActive
                        ? Colors.black
                        : (tab.useBrandColor
                            ? Colors.white
                            : const Color(0xFF1C1C1C)),
                  ),
                ),
                if (tab.sub != null)
                  Text(
                    tab.sub!,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFF1C1C1C)
                          : const Color(0xFF8A8A8A),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
