import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'spring.dart';

/// 对齐 jicun 的 TabDragGestureMixin：
/// _onTabSwipeStart / _onTabSwipeUpdate / _onTabSwipeEnd / _forceSnapToNearestTab
class TabShellController extends ChangeNotifier {
  TabShellController({
    required this.tabCount,
    required this.tabWidths,
    required TickerProvider vsync,
  }) : _vsync = vsync {
    _controller = AnimationController.unbounded(vsync: vsync)..addListener(_onTick);
  }

  final int tabCount;
  final List<double> tabWidths;
  final TickerProvider _vsync;

  late final AnimationController _controller;

  double _offsetPx = 0;
  double get offsetPx => _offsetPx;

  double _dragStartX = 0;
  double _dragStartOffset = 0;
  bool _dragging = false;
  bool get isDragging => _dragging;

  final VelocityTracker _tracker =
      VelocityTracker.withKind(PointerDeviceKind.touch);

  void _onTick() {
    _offsetPx = _controller.value;
    notifyListeners();
  }

  double _cumulative(int i) {
    double s = 0;
    for (int k = 0; k < i && k < tabWidths.length; k++) {
      s += tabWidths[k];
    }
    return s;
  }

  double get _totalWidth {
    double s = 0;
    for (final w in tabWidths) {
      s += w;
    }
    return s;
  }

  double get fractionalIndex => _pxToIndex(_offsetPx);

  int get currentIndex => fractionalIndex.round().clamp(0, tabCount - 1);

  double _pxToIndex(double px) {
    if (tabWidths.isEmpty) return 0;
    double acc = 0;
    for (int i = 0; i < tabWidths.length; i++) {
      final w = tabWidths[i];
      if (px < acc + w) {
        final t = w == 0 ? 0.0 : (px - acc) / w;
        return i + t;
      }
      acc += w;
    }
    return (tabWidths.length - 1).toDouble();
  }

  double indexToPx(double idx) {
    if (tabWidths.isEmpty) return 0;
    final i = idx.floor().clamp(0, tabWidths.length - 1);
    final t = idx - i;
    if (i >= tabWidths.length - 1) return _cumulative(i);
    return _cumulative(i) + tabWidths[i] * t;
  }

  // ───── 手势：1:1 跟手，无透明/模糊/缩放 ─────

  void onDragStart(DragStartDetails d) {
    _controller.stop();
    _dragging = true;
    _dragStartX = d.localPosition.dx;
    _dragStartOffset = _offsetPx;
    _tracker.addPosition(d.timestamp ?? Duration.zero, d.localPosition);
    HapticFeedback.selectionClick();
  }

  void onDragUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    _tracker.addPosition(d.timestamp ?? Duration.zero, d.localPosition);
    final dx = d.localPosition.dx - _dragStartX;
    double next = _dragStartOffset - dx;
    final max = _totalWidth;
    if (next < 0) {
      next = next * 0.35;
    } else if (next > max) {
      next = max + (next - max) * 0.35;
    }
    _controller.value = next;
  }

  void onDragEnd(DragEndDetails d) {
    if (!_dragging) return;
    _dragging = false;

    final vx = d.velocity.pixelsPerSecond.dx;
    final cur = fractionalIndex;

    int target;
    final fling = vx.abs() > 220;
    if (fling) {
      target = vx < 0 ? cur.floor() + 1 : cur.ceil() - 1;
    } else {
      target = cur.round();
    }
    target = target.clamp(0, tabCount - 1);
    _animateTo(target, velocity: -vx);
  }

  void onDragCancel() {
    if (!_dragging) return;
    _dragging = false;
    _animateTo(currentIndex, velocity: 0);
  }

  void _animateTo(int index, {double velocity = 0}) {
    final targetPx = indexToPx(index.toDouble());
    final sim = GlassSpring.standard.simulation(_offsetPx, targetPx, velocity);
    _controller.animateWith(sim);
    HapticFeedback.selectionClick();
  }

  void selectTab(int index) {
    index = index.clamp(0, tabCount - 1);
    _dragging = false;
    _animateTo(index);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }
}
