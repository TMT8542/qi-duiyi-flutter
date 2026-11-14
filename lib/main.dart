import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/app_shell.dart';
import 'ui/glass_tab_bar.dart';
import 'ui/placeholder_board.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0B0B0E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const QiDuiYiApp());
}

class QiDuiYiApp extends StatelessWidget {
  const QiDuiYiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '棋 · 对弈',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B0E),
      ),
      home: const AppShell(
        items: [
          GlassTabItem(label: '对弈', icon: Icons.grid_4x4_outlined, activeIcon: Icons.grid_4x4),
          GlassTabItem(label: '残局', icon: Icons.extension_outlined, activeIcon: Icons.extension),
          GlassTabItem(label: '棋谱', icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book),
          GlassTabItem(label: '设置', icon: Icons.tune_outlined, activeIcon: Icons.tune),
        ],
        pages: [
          _Page(child: PlaceholderBoard(title: '中国象棋', subtitle: '红方走棋 · 长按 200ms 擦选', cols: 9, rows: 10)),
          _Page(child: PlaceholderBoard(title: '残局拆解', subtitle: '杀法 · 定式 · 逐子推演', cols: 9, rows: 10)),
          _Page(child: PlaceholderBoard(title: '棋谱', subtitle: '名局复盘与本地记录', cols: 8, rows: 8)),
          _Page(child: PlaceholderBoard(title: '设置', subtitle: '外观 · 手感 · 引擎强度', cols: 6, rows: 6)),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: child,
    );
  }
}
