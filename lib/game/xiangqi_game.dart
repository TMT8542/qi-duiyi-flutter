/// 中国象棋规则引擎
enum Side { red, black }

enum PieceKind { king, advisor, elephant, horse, chariot, cannon, soldier }

class Piece {
  const Piece(this.side, this.kind);
  final Side side;
  final PieceKind kind;

  String get label {
    if (side == Side.red) {
      switch (kind) {
        case PieceKind.king: return '帅';
        case PieceKind.advisor: return '仕';
        case PieceKind.elephant: return '相';
        case PieceKind.horse: return '马';
        case PieceKind.chariot: return '车';
        case PieceKind.cannon: return '炮';
        case PieceKind.soldier: return '兵';
      }
    } else {
      switch (kind) {
        case PieceKind.king: return '将';
        case PieceKind.advisor: return '士';
        case PieceKind.elephant: return '象';
        case PieceKind.horse: return '馬';
        case PieceKind.chariot: return '車';
        case PieceKind.cannon: return '砲';
        case PieceKind.soldier: return '卒';
      }
    }
  }
}

class Move {
  const Move(this.fromRow, this.fromCol, this.toRow, this.toCol, {this.capture});
  final int fromRow, fromCol, toRow, toCol;
  final Piece? capture;
}

class XiangqiGame {
  XiangqiGame() { _setup(); }

  static const int rows = 10;
  static const int cols = 9;

  final List<List<Piece?>> board =
      List.generate(rows, (_) => List<Piece?>.filled(cols, null));

  Side turn = Side.red;
  final List<Move> history = [];
  Side? winner;

  void _setup() {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) { board[r][c] = null; }
    }
    board[0][0] = const Piece(Side.black, PieceKind.chariot);
    board[0][1] = const Piece(Side.black, PieceKind.horse);
    board[0][2] = const Piece(Side.black, PieceKind.elephant);
    board[0][3] = const Piece(Side.black, PieceKind.advisor);
    board[0][4] = const Piece(Side.black, PieceKind.king);
    board[0][5] = const Piece(Side.black, PieceKind.advisor);
    board[0][6] = const Piece(Side.black, PieceKind.elephant);
    board[0][7] = const Piece(Side.black, PieceKind.horse);
    board[0][8] = const Piece(Side.black, PieceKind.chariot);
    board[2][1] = const Piece(Side.black, PieceKind.cannon);
    board[2][7] = const Piece(Side.black, PieceKind.cannon);
    for (final c in [0, 2, 4, 6, 8]) {
      board[3][c] = const Piece(Side.black, PieceKind.soldier);
    }
    board[9][0] = const Piece(Side.red, PieceKind.chariot);
    board[9][1] = const Piece(Side.red, PieceKind.horse);
    board[9][2] = const Piece(Side.red, PieceKind.elephant);
    board[9][3] = const Piece(Side.red, PieceKind.advisor);
    board[9][4] = const Piece(Side.red, PieceKind.king);
    board[9][5] = const Piece(Side.red, PieceKind.advisor);
    board[9][6] = const Piece(Side.red, PieceKind.elephant);
    board[9][7] = const Piece(Side.red, PieceKind.horse);
    board[9][8] = const Piece(Side.red, PieceKind.chariot);
    board[7][1] = const Piece(Side.red, PieceKind.cannon);
    board[7][7] = const Piece(Side.red, PieceKind.cannon);
    for (final c in [0, 2, 4, 6, 8]) {
      board[6][c] = const Piece(Side.red, PieceKind.soldier);
    }
    turn = Side.red;
    winner = null;
    history.clear();
  }

  Piece? at(int r, int c) =>
      (r >= 0 && r < rows && c >= 0 && c < cols) ? board[r][c] : null;

  bool _inside(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  bool _inPalace(int r, int c, Side s) {
    if (c < 3 || c > 5) return false;
    return s == Side.red ? (r >= 7 && r <= 9) : (r >= 0 && r <= 2);
  }

  bool _crossedRiver(int r, Side s) => s == Side.red ? r <= 4 : r >= 5;

  List<Move> movesFrom(int r, int c) {
    final p = at(r, c);
    if (p == null) return const [];
    final out = <Move>[];
    void add(int tr, int tc) {
      if (!_inside(tr, tc)) return;
      final t = board[tr][tc];
      if (t != null && t.side == p.side) return;
      out.add(Move(r, c, tr, tc, capture: t));
    }

    switch (p.kind) {
      case PieceKind.king:
        for (final d in const [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
          final tr = r + d[0], tc = c + d[1];
          if (_inPalace(tr, tc, p.side)) add(tr, tc);
        }
        for (var rr = r - 1; rr >= 0; rr--) {
          final t = board[rr][c];
          if (t == null) continue;
          if (t.kind == PieceKind.king && t.side != p.side) {
            out.add(Move(r, c, rr, c, capture: t));
          }
          break;
        }
        for (var rr = r + 1; rr < rows; rr++) {
          final t = board[rr][c];
          if (t == null) continue;
          if (t.kind == PieceKind.king && t.side != p.side) {
            out.add(Move(r, c, rr, c, capture: t));
          }
          break;
        }
        break;

      case PieceKind.advisor:
        for (final d in const [[1, 1], [1, -1], [-1, 1], [-1, -1]]) {
          final tr = r + d[0], tc = c + d[1];
          if (_inPalace(tr, tc, p.side)) add(tr, tc);
        }
        break;

      case PieceKind.elephant:
        for (final d in const [[2, 2], [2, -2], [-2, 2], [-2, -2]]) {
          final tr = r + d[0], tc = c + d[1];
          if (!_inside(tr, tc)) continue;
          if (p.side == Side.red && tr < 5) continue;
          if (p.side == Side.black && tr > 4) continue;
          if (board[r + d[0] ~/ 2][c + d[1] ~/ 2] != null) continue;
          add(tr, tc);
        }
        break;

      case PieceKind.horse:
        for (final d in const [
          [2, 1], [2, -1], [-2, 1], [-2, -1],
          [1, 2], [1, -2], [-1, 2], [-1, -2],
        ]) {
          final tr = r + d[0], tc = c + d[1];
          if (!_inside(tr, tc)) continue;
          final lr = r + (d[0].abs() == 2 ? d[0] ~/ 2 : 0);
          final lc = c + (d[1].abs() == 2 ? d[1] ~/ 2 : 0);
          if (board[lr][lc] != null) continue;
          add(tr, tc);
        }
        break;

      case PieceKind.chariot:
        for (final d in const [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
          var tr = r + d[0], tc = c + d[1];
          while (_inside(tr, tc)) {
            final t = board[tr][tc];
            if (t == null) {
              add(tr, tc);
            } else {
              if (t.side != p.side) add(tr, tc);
              break;
            }
            tr += d[0];
            tc += d[1];
          }
        }
        break;

      case PieceKind.cannon:
        for (final d in const [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
          var tr = r + d[0], tc = c + d[1];
          var jumped = false;
          while (_inside(tr, tc)) {
            final t = board[tr][tc];
            if (!jumped) {
              if (t == null) {
                add(tr, tc);
              } else {
                jumped = true;
              }
            } else {
              if (t != null) {
                if (t.side != p.side) add(tr, tc);
                break;
              }
            }
            tr += d[0];
            tc += d[1];
          }
        }
        break;

      case PieceKind.soldier:
        final forward = p.side == Side.red ? -1 : 1;
        add(r + forward, c);
        if (_crossedRiver(r, p.side)) {
          add(r, c - 1);
          add(r, c + 1);
        }
        break;
    }
    return out;
  }

  bool move(Move m) {
    if (winner != null) return false;
    final p = at(m.fromRow, m.fromCol);
    if (p == null || p.side != turn) return false;

    final legal = movesFrom(m.fromRow, m.fromCol)
        .any((x) => x.toRow == m.toRow && x.toCol == m.toCol);
    if (!legal) return false;

    final captured = board[m.toRow][m.toCol];
    board[m.toRow][m.toCol] = p;
    board[m.fromRow][m.fromCol] = null;
    history.add(Move(m.fromRow, m.fromCol, m.toRow, m.toCol, capture: captured));

    if (captured != null && captured.kind == PieceKind.king) {
      winner = p.side;
    } else {
      turn = p.side == Side.red ? Side.black : Side.red;
      if (_hasNoMove(turn)) winner = p.side;
    }
    return true;
  }

  bool _hasNoMove(Side s) {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final p = board[r][c];
        if (p != null && p.side == s && movesFrom(r, c).isNotEmpty) return false;
      }
    }
    return true;
  }

  bool undo() {
    if (history.isEmpty) return false;
    final m = history.removeLast();
    final p = board[m.toRow][m.toCol];
    board[m.fromRow][m.fromCol] = p;
    board[m.toRow][m.toCol] = m.capture;
    turn = p!.side;
    winner = null;
    return true;
  }

  void reset() => _setup();
}
