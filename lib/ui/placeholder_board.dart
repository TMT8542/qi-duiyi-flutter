import 'dart:math' as math;
import 'package:flutter/material.dart';

class PlaceholderBoard extends StatelessWidget {
  const PlaceholderBoard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cols,
    required this.rows,
  });

  final String title;
  final String subtitle;
  final int cols;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x18FFFFFF), width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.38), fontSize: 11)),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: cols / rows,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomPaint(
                    painter: _BoardPainter(cols: cols, rows: rows),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.cols, required this.rows});

  final int cols;
  final int rows;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3A2A1C), Color(0xFF24180F)],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final dx = size.width / cols;
    final dy = size.height / rows;
    final line = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 0.8;

    for (int r = 0; r <= rows; r++) {
      canvas.drawLine(Offset(0, dy * r), Offset(size.width, dy * r), line);
    }
    for (int c = 0; c <= cols; c++) {
      canvas.drawLine(Offset(dx * c, 0), Offset(dx * c, size.height), line);
    }

    final rr = math.min(dx, dy) * 0.38;
    final shadow = Paint()..color = const Color(0x44000000);

    void piece(int c, int r, bool dark) {
      final o = Offset(dx * (c + 0.5), dy * (r + 0.5));
      final p = Paint()
        ..shader = RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 1.1,
          colors: dark
              ? const [Color(0xFF4A4A52), Color(0xFF1E1E24)]
              : const [Color(0xFFF7F1E4), Color(0xFFD9C9A8)],
        ).createShader(Rect.fromCircle(center: o, radius: rr));
      canvas.drawCircle(o.translate(0, 1.6), rr, shadow);
      canvas.drawCircle(o, rr, p);
    }

    if (cols > 4 && rows > 5) {
      piece(cols ~/ 2 - 1, rows ~/ 2, false);
      piece(cols ~/ 2 + 1, rows ~/ 2, true);
      piece(cols ~/ 2, rows ~/ 2 + 2, false);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) =>
      old.cols != cols || old.rows != rows;
}
