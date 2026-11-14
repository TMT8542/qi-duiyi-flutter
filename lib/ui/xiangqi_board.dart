import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/xiangqi_game.dart';

class XiangqiBoard extends StatefulWidget {
  const XiangqiBoard({super.key});

  @override
  State<XiangqiBoard> createState() => _XiangqiBoardState();
}

class _XiangqiBoardState extends State<XiangqiBoard> {
  final XiangqiGame game = XiangqiGame();
  int? selRow;
  int? selCol;
  List<Move> moves = const [];

  void _tapCell(int r, int c) {
    if (game.winner != null) return;

    if (selRow != null && selCol != null) {
      final target = moves.where((m) => m.toRow == r && m.toCol == c);
      if (target.isNotEmpty) {
        setState(() {
          game.move(target.first);
          selRow = null;
          selCol = null;
          moves = const [];
        });
        HapticFeedback.selectionClick();
        return;
      }
    }

    final p = game.at(r, c);
    if (p != null && p.side == game.turn) {
      setState(() {
        selRow = r;
        selCol = c;
        moves = game.movesFrom(r, c);
      });
      HapticFeedback.selectionClick();
      return;
    }

    setState(() {
      selRow = null;
      selCol = null;
      moves = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = game.winner != null
        ? (game.winner == Side.red ? '红方胜' : '黑方胜')
        : (game.turn == Side.red ? '红方走棋' : '黑方走棋');

    return Column(
      children: [
        Row(
          children: [
            Text(
              status,
              style: TextStyle(
                fontSize: 13,
                color: game.winner != null
                    ? const Color(0xFFFFD666)
                    : Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _MiniBtn(label: '悔棋', onTap: () {
              setState(() {
                game.undo();
                selRow = null;
                selCol = null;
                moves = const [];
              });
            }),
            const SizedBox(width: 8),
            _MiniBtn(label: '重开', onTap: () {
              setState(() {
                game.reset();
                selRow = null;
                selCol = null;
                moves = const [];
              });
            }),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final h = box.maxHeight;
              double cell = w / 9.4;
              if (cell * 10.4 > h) cell = h / 10.4;
              return Center(
                child: SizedBox(
                  width: cell * 9.4,
                  height: cell * 10.4,
                  child: GestureDetector(
                    onTapUp: (d) {
                      final c = ((d.localPosition.dx - cell * 0.2) / cell).round();
                      final r = ((d.localPosition.dy - cell * 0.2) / cell).round();
                      if (r >= 0 && r < 10 && c >= 0 && c < 9) {
                        _tapCell(r, c);
                      }
                    },
                    child: CustomPaint(
                      painter: _XqPainter(
                        game: game,
                        cell: cell,
                        selRow: selRow,
                        selCol: selCol,
                        moves: moves,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x1FFFFFFF), width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75)),
        ),
      ),
    );
  }
}

class _XqPainter extends CustomPainter {
  _XqPainter({
    required this.game,
    required this.cell,
    required this.selRow,
    required this.selCol,
    required this.moves,
  });

  final XiangqiGame game;
  final double cell;
  final int? selRow;
  final int? selCol;
  final List<Move> moves;

  Offset _p(int r, int c) =>
      Offset(cell * 0.2 + c * cell, cell * 0.2 + r * cell);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8D3A8), Color(0xFFCBB183)],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      bg,
    );

    final line = Paint()
      ..color = const Color(0x99000000)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    for (var r = 0; r < 10; r++) {
      canvas.drawLine(_p(r, 0), _p(r, 8), line);
    }
    for (var c = 0; c < 9; c++) {
      if (c == 0 || c == 8) {
        canvas.drawLine(_p(0, c), _p(9, c), line);
      } else {
        canvas.drawLine(_p(0, c), _p(4, c), line);
        canvas.drawLine(_p(5, c), _p(9, c), line);
      }
    }
    canvas.drawLine(_p(0, 3), _p(2, 5), line);
    canvas.drawLine(_p(0, 5), _p(2, 3), line);
    canvas.drawLine(_p(7, 3), _p(9, 5), line);
    canvas.drawLine(_p(7, 5), _p(9, 3), line);

    final border = Paint()
      ..color = const Color(0xCC000000)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromPoints(_p(0, 0), _p(9, 8)), border);

    final tp = TextPainter(
      text: TextSpan(
        text: '楚 河          汉 界',
        style: TextStyle(
          color: const Color(0x66000000),
          fontSize: cell * 0.45,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width / 2 - tp.width / 2, _p(4, 4).dy + cell * 0.28),
    );

    for (final m in moves) {
      final o = _p(m.toRow, m.toCol);
      if (m.capture != null) {
        canvas.drawCircle(
          o,
          cell * 0.44,
          Paint()
            ..color = const Color(0x66FF3B30)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      } else {
        canvas.drawCircle(o, cell * 0.14, Paint()..color = const Color(0xAA20A060));
      }
    }

    if (selRow != null && selCol != null) {
      canvas.drawCircle(
        _p(selRow!, selCol!),
        cell * 0.47,
        Paint()
          ..color = const Color(0xFF1E88E5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }

    for (var r = 0; r < 10; r++) {
      for (var c = 0; c < 9; c++) {
        final p = game.at(r, c);
        if (p == null) continue;
        final o = _p(r, c);
        final radius = cell * 0.42;
        final isRed = p.side == Side.red;

        canvas.drawCircle(
          o.translate(0, 1.5),
          radius,
          Paint()..color = const Color(0x44000000),
        );
        canvas.drawCircle(
          o,
          radius,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.35, -0.4),
              radius: 1.15,
              colors: isRed
                  ? const [Color(0xFFFFF6E8), Color(0xFFE8CFA8)]
                  : const [Color(0xFFF2EEE6), Color(0xFFCFC4B2)],
            ).createShader(Rect.fromCircle(center: o, radius: radius)),
        );
        canvas.drawCircle(
          o,
          radius,
          Paint()
            ..color = isRed ? const Color(0xFFB03A2E) : const Color(0xFF2C2C2C)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        canvas.drawCircle(
          o,
          radius * 0.82,
          Paint()
            ..color = isRed ? const Color(0x66B03A2E) : const Color(0x552C2C2C)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );

        final tp2 = TextPainter(
          text: TextSpan(
            text: p.label,
            style: TextStyle(
              color: isRed ? const Color(0xFF9E2A20) : const Color(0xFF1E1E1E),
              fontSize: radius * 1.05,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp2.paint(canvas, o - Offset(tp2.width / 2, tp2.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _XqPainter old) => true;
}
