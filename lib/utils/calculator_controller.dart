import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'history_manager.dart';

class CalculatorController extends ChangeNotifier {
  // ─── Display ───────────────────────────────────────────────────────────────
  String display        = '0'; // big bottom number
  String expressionLine = ''; // small top line  e.g. "2 + 2"

  // ─── Internal state ────────────────────────────────────────────────────────
  double? _left;                   // stored left-hand operand
  String  _op             = '';    // pending operator
  bool    _fresh          = true;  // next digit replaces display
  bool    _equalsPressed  = false; // blocks repeat =

  // ─── History ───────────────────────────────────────────────────────────────
  final HistoryManager _hist = HistoryManager();
  HistoryManager get historyManager => _hist;

  Future<void> loadHistory() async {
    await _hist.loadHistory();
    notifyListeners();
  }

  // ─── Helpers: build expression line ───────────────────────────────────────
  // Called after every state change so the top line always reflects reality.
  void _rebuildExpressionLine() {
    if (_left == null || _op.isEmpty) {
      // No pending operation → nothing to show above
      expressionLine = '';
    } else {
      // Show   "2 +"   while waiting for right operand
      // Show   "2 + 2"  while user is typing the right operand
      if (_fresh) {
        // User hasn't started the right number yet
        expressionLine = '${_fmt(_left)} $_op';
      } else {
        // User is typing the right number → show it live
        expressionLine = '${_fmt(_left)} $_op $display';
      }
    }
  }

  // ─── Digit / dot input ─────────────────────────────────────────────────────
  void inputNumber(String digit) {
    HapticFeedback.selectionClick();

    if (_fresh) {
      display = (digit == '.') ? '0.' : digit;
      _fresh = false;
      _equalsPressed = false;
    } else {
      if (digit == '.' && display.contains('.')) return;
      if (display == '0' && digit != '.') {
        display = digit;
      } else {
        display += digit;
      }
    }

    _rebuildExpressionLine();
    notifyListeners();
  }

  void inputDot() => inputNumber('.');

  // ─── AC / C ────────────────────────────────────────────────────────────────
  bool get showC => !_fresh || display != '0';

  /// C  — clear current entry AND fully reset state.
  ///      After a result, pressing C should mean "start completely fresh".
  void clearEntry() {
    HapticFeedback.selectionClick();
    display        = '0';
    expressionLine = '';
    _left          = null;
    _op            = '';
    _fresh         = true;
    _equalsPressed = false;
    notifyListeners();
  }

  /// AC — identical to C; kept for the long-press gesture.
  void clearAll() {
    HapticFeedback.heavyImpact();
    display        = '0';
    expressionLine = '';
    _left          = null;
    _op            = '';
    _fresh         = true;
    _equalsPressed = false;
    notifyListeners();
  }

  // ─── Backspace ─────────────────────────────────────────────────────────────
  void deleteOne() {
    HapticFeedback.selectionClick();
    if (_fresh || display == '0') {
      display = '0';
      _fresh  = true;
    } else if (display.length == 1 ||
               (display.startsWith('-') && display.length == 2)) {
      display = '0';
      _fresh  = true;
    } else {
      display = display.substring(0, display.length - 1);
      if (display.endsWith('.')) {
        display = display.substring(0, display.length - 1);
      }
      if (display.isEmpty || display == '-') {
        display = '0';
        _fresh  = true;
      }
    }
    _rebuildExpressionLine();
    notifyListeners();
  }

  // ─── ± and % ───────────────────────────────────────────────────────────────
  void toggleSign() {
    HapticFeedback.selectionClick();
    if (display == '0') return;
    final v = double.tryParse(display);
    if (v == null) return;
    display = _fmt(-v);
    _rebuildExpressionLine();
    notifyListeners();
  }

  void percent() {
    HapticFeedback.selectionClick();
    final v = double.tryParse(display);
    if (v == null) return;
    display = _fmt(v / 100.0);
    _fresh  = false;
    _rebuildExpressionLine();
    notifyListeners();
  }

  // ─── Operator ──────────────────────────────────────────────────────────────
  void setOperator(String op) {
    HapticFeedback.selectionClick();

    if (_equalsPressed) {
      // Chain from result: _left already holds it
      _equalsPressed = false;
      _op    = op;
      _fresh = true;
      _rebuildExpressionLine();
      notifyListeners();
      return;
    }

    final cur = double.tryParse(display) ?? 0.0;

    if (_left != null && !_fresh) {
      // Chain: compute the pending op first
      final r = _evaluate(_left!, _op, cur);
      _left   = r;
      display = _fmt(r);
    } else {
      _left = cur;
    }

    _op    = op;
    _fresh = true;
    _rebuildExpressionLine();
    notifyListeners();
  }

  // ─── Equals ────────────────────────────────────────────────────────────────
  Future<void> calculateResult() async {
    HapticFeedback.mediumImpact();

    if (_equalsPressed) return;           // block repeat =
    if (_left == null || _op.isEmpty) return;

    final right      = double.tryParse(display) ?? 0.0;
    final result     = _evaluate(_left!, _op, right);
    final expression = '${_fmt(_left)} $_op ${_fmt(right)}';
    final resultStr  = _fmt(result);

    // Top line shows the full expression; bottom shows the result
    expressionLine = expression;
    display        = resultStr;

    await _hist.addEntry(expression, resultStr);

    _left          = result;
    _op            = '';
    _fresh         = true;
    _equalsPressed = true;
    notifyListeners();
  }

  // ─── Load from history ─────────────────────────────────────────────────────
  void loadFromHistory(String value) {
    display        = value;
    expressionLine = '';
    _left          = null;
    _op            = '';
    _fresh         = false;
    _equalsPressed = false;
    notifyListeners();
  }

  // ─── History CRUD ──────────────────────────────────────────────────────────
  Future<void> clearAllHistory() async {
    await _hist.clearAll();
    notifyListeners();
  }

  Future<void> deleteHistoryAt(int index) async {
    await _hist.deleteAt(index);
    notifyListeners();
  }

  // ─── Private helpers ───────────────────────────────────────────────────────
  double _evaluate(double a, String op, double b) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '×': return a * b;
      case '÷': return b == 0 ? double.nan : a / b;
      default:  return b;
    }
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final double d = v is double ? v : (double.tryParse('$v') ?? 0.0);
    if (d.isNaN)      return 'Error';
    if (d.isInfinite) return d > 0 ? '∞' : '-∞';
    if (d == d.truncateToDouble() && d.abs() < 1e15) {
      return d.toInt().toString();
    }
    String s = d.toStringAsFixed(10);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }
}
