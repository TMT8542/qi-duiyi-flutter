import 'package:flutter/material.dart';
import '../motion/tab_shell_controller.dart';

class GlassTabItem {
  const GlassTabItem({required this.label, required this.icon, this.activeIcon});
  final String label;
  final IconData icon;
  final IconData? activeIcon;
}

class GlassTabBar extends StatefulWidget {
  const GlassTabBar({
    super.key,
    required this.items,
    required this.controller,
    this.height = 56,
    this.horizontalPadding = 12,
    this.tint = const Color(0x14FFFFFF),
    this.borderColor = const Color(0x18FFFFFF),
  });

  final List<GlassTabItem> items;
  final TabShellController controller;
  final double height;
  final double horizontalPadding;
  final Color tint;
  final Color borderColor;

  @override
  State<GlassTabBar> createState() => _GlassTabBarState();
}

class _GlassTabBarState extends State<GlassTabBar> {
  final List<GlobalKey> _keys = [];

  @override
  void initState() {
    super.initState();
    _syncKeys();
    widget.controller.addListener(_onTick);
  }

  @override
  void didUpdateWidget(covariant GlassTabBar old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onTick);
      widget.controller.addListener(_onTick);
    }
    _syncKeys();
  }

  void _syncKeys() {
    while (_keys.length < widget.items.length) {
      _keys.add(GlobalKey());
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: c.onDragStart,
      onHorizontalDragUpdate: c.onDragUpdate,
      onHorizontalDragEnd: c.onDragEnd,
      onHorizontalDragCancel: c.onDragCancel,
      onTapUp: (d) => _hitTest(d.globalPosition),
      child: Container(
        height: widget.height,
        margin: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.tint,
                  borderRadius: BorderRadius.circular(widget.height * 0.32),
                  border: Border.all(color: widget.borderColor, width: 0.5),
                ),
              ),
            ),
            _IndicatorLayer(
              keys: _keys,
              controller: c,
              height: widget.height,
            ),
            Positioned.fill(
              child: Row(
                children: [
                  for (int i = 0; i < widget.items.length; i++)
                    Expanded(
                      key: _keys[i],
                      child: _TabLabel(
                        item: widget.items[i],
                        progress:
                            (1.0 - (c.fractionalIndex - i).abs()).clamp(0.0, 1.0),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hitTest(Offset global) {
    for (int i = 0; i < _keys.length; i++) {
      final target = _keys[i].currentContext?.findRenderObject() as RenderBox?;
      if (target == null) continue;
      final local = target.globalToLocal(global);
      if (local.dx >= 0 &&
          local.dx <= target.size.width &&
          local.dy >= 0 &&
          local.dy <= target.size.height) {
        widget.controller.selectTab(i);
        return;
      }
    }
  }
}

class _IndicatorLayer extends StatelessWidget {
  const _IndicatorLayer({
    required this.keys,
    required this.controller,
    required this.height,
  });

  final List<GlobalKey> keys;
  final TabShellController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (keys.isEmpty) return const SizedBox.shrink();
    final idx = controller.fractionalIndex;
    final i0 = idx.floor().clamp(0, keys.length - 1);
    final i1 = (i0 + 1).clamp(0, keys.length - 1);
    final t = (idx - i0).clamp(0.0, 1.0);

    final b0 = keys[i0].currentContext?.findRenderObject() as RenderBox?;
    final b1 = keys[i1].currentContext?.findRenderObject() as RenderBox?;
    final parent = context.findRenderObject() as RenderBox?;
    if (b0 == null || parent == null) return const SizedBox.shrink();

    final origin = parent.localToGlobal(Offset.zero);
    final l0 = b0.localToGlobal(Offset.zero).dx - origin.dx;
    final l1 = (b1?.localToGlobal(Offset.zero).dx ?? b0.localToGlobal(Offset.zero).dx) - origin.dx;
    final w0 = b0.size.width;
    final w1 = b1?.size.width ?? w0;

    final left = l0 + (l1 - l0) * t;
    final width = w0 + (w1 - w0) * t;

    return Positioned(
      left: left + 3,
      top: 4,
      width: (width - 6).clamp(0.0, double.infinity),
      height: height - 8,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x2EFFFFFF), Color(0x12FFFFFF)],
            ),
            border: Border.all(color: const Color(0x26FFFFFF), width: 0.8),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
              BoxShadow(color: Color(0x1FFFFFFF), blurRadius: 1, offset: Offset(0, -0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.item, required this.progress});

  final GlassTabItem item;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(const Color(0x99FFFFFF), const Color(0xFFFFFFFF), progress)!;
    final selected = progress > 0.5;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(selected ? (item.activeIcon ?? item.icon) : item.icon, size: 20, color: color),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 10.5,
            color: color,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
