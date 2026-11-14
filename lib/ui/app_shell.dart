import 'package:flutter/material.dart';

import '../motion/tab_shell_controller.dart';
import 'glass_tab_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.pages, required this.items});

  final List<Widget> pages;
  final List<GlassTabItem> items;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  TabShellController? _controller;
  double _pageWidth = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  TabShellController _ensure(double width) {
    if (_controller != null && (_pageWidth - width).abs() < 0.5) {
      return _controller!;
    }
    _pageWidth = width;
    _controller?.dispose();
    _controller = TabShellController(
      tabCount: widget.pages.length,
      tabWidths: List<double>.filled(widget.items.length, width / widget.items.length),
      vsync: this,
    );
    return _controller!;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final c = _ensure(width);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0E),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 6),
            _Header(controller: c),
            const SizedBox(height: 10),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: c.onDragStart,
                onHorizontalDragUpdate: c.onDragUpdate,
                onHorizontalDragEnd: c.onDragEnd,
                onHorizontalDragCancel: c.onDragCancel,
                child: ClipRect(
                  child: ListenableBuilder(
                    listenable: c,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(-c.offsetPx, 0),
                        child: SizedBox(
                          width: width * widget.pages.length,
                          child: Row(
                            children: [
                              for (final p in widget.pages)
                                SizedBox(width: width, child: p),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: GlassTabBar(items: widget.items, controller: c),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final TabShellController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '棋 · 对弈',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    const subs = [
                      '开局 · 中局 · 残局',
                      '杀法与定式拆解',
                      '名局复盘与本地棋谱',
                      '外观 · 手感 · 引擎',
                    ];
                    final i = controller.fractionalIndex
                        .round()
                        .clamp(0, subs.length - 1);
                    return Text(
                      subs[i],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.45),
                        letterSpacing: 0.3,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x12FFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x18FFFFFF), width: 0.5),
            ),
            child: Text(
              '滑动切页',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
