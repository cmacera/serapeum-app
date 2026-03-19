import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Transition durations
const _kOpenTransitionDuration = Duration(milliseconds: 250);
const _kFadeDuration = Duration(milliseconds: 200);
const _kPageScrollDuration = Duration(milliseconds: 300);

// Dismiss thresholds
const _kDismissHeightFraction = 0.2;
const _kDismissVelocityThreshold = 600.0;

// Appearance
const _kBackgroundMaxOpacity = 0.92;
const _kMaxZoom = 4.0;
const _kErrorIconSize = 48.0;
const _kCloseButtonPadding = 8.0;

// Page indicator
const _kIndicatorBottomPadding = 32.0;
const _kDotAnimDuration = Duration(milliseconds: 200);
const _kDotActiveWidth = 16.0;
const _kDotSize = 6.0;
const _kDotMargin = 3.0;

class FullscreenImageViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.urls,
    required this.initialIndex,
  });

  static String heroTag(String url) => 'screenshot_$url';

  static void show(
    BuildContext context, {
    required List<String> urls,
    required int initialIndex,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, _, _) =>
            FullscreenImageViewer(urls: urls, initialIndex: initialIndex),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: _kOpenTransitionDuration,
      ),
    );
  }

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentIndex;
  late final AnimationController _backgroundController;
  late final Animation<double> _backgroundOpacity;

  // Track vertical drag for swipe-down dismiss
  double _dragStartY = 0;
  double _dragOffsetY = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _backgroundController = AnimationController(
      vsync: this,
      value: 1,
      duration: _kFadeDuration,
    );
    _backgroundOpacity = _backgroundController.drive(
      CurveTween(curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _dismiss() {
    void onStatus(AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        _backgroundController.removeStatusListener(onStatus);
        if (mounted) Navigator.of(context).pop();
      }
    }

    _backgroundController.addStatusListener(onStatus);
    _backgroundController.reverse();
  }

  void _nextPage() {
    if (_currentIndex < widget.urls.length - 1) {
      _pageController.nextPage(
        duration: _kPageScrollDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: _kPageScrollDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _dismiss();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _nextPage();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _prevPage();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
    _isDragging = true;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final delta = details.globalPosition.dy - _dragStartY;
    if (delta < 0) return; // only downward
    setState(() {
      _dragOffsetY = delta;
    });
    // Fade background as user drags down
    final screenHeight = MediaQuery.of(context).size.height;
    final progress = 1.0 - (delta / screenHeight).clamp(0.0, 1.0);
    _backgroundController.value = progress;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;
    final screenHeight = MediaQuery.of(context).size.height;
    final shouldDismiss =
        _dragOffsetY > screenHeight * _kDismissHeightFraction ||
        (details.primaryVelocity ?? 0) > _kDismissVelocityThreshold;

    if (shouldDismiss) {
      _dismiss();
    } else {
      setState(() => _dragOffsetY = 0);
      _backgroundController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Dark background that fades with drag
            AnimatedBuilder(
              animation: _backgroundOpacity,
              builder: (_, _) => Container(
                color: Colors.black.withValues(
                  alpha: _backgroundOpacity.value * _kBackgroundMaxOpacity,
                ),
              ),
            ),
            // Draggable image view
            GestureDetector(
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              onTap: _dismiss,
              child: Transform.translate(
                offset: Offset(0, _dragOffsetY),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.urls.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, index) {
                    final url = widget.urls[index];
                    return Hero(
                      tag: FullscreenImageViewer.heroTag(url),
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: _kMaxZoom,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            placeholder: (context, _) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, _, _) => const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: _kErrorIconSize,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Close button
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(_kCloseButtonPadding),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _dismiss,
                  ),
                ),
              ),
            ),
            // Page indicator
            if (widget.urls.length > 1)
              Positioned(
                bottom: _kIndicatorBottomPadding,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.urls.length,
                    (i) => AnimatedContainer(
                      duration: _kDotAnimDuration,
                      margin: const EdgeInsets.symmetric(
                        horizontal: _kDotMargin,
                      ),
                      width: i == _currentIndex ? _kDotActiveWidth : _kDotSize,
                      height: _kDotSize,
                      decoration: BoxDecoration(
                        color: i == _currentIndex
                            ? Colors.white
                            : Colors.white38,
                        borderRadius: BorderRadius.circular(_kDotMargin),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
