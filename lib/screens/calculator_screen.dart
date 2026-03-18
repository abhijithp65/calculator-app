import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/calculator_controller.dart';
import '../widgets/calculator_button.dart';
import '../widgets/history_sheet.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorController _ctrl = CalculatorController();

  @override
  void initState() {
    super.initState();
    _ctrl.loadHistory();
    _ctrl.addListener(_refresh);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_refresh);
    _ctrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  TextStyle _displayStyle(String text) {
    if (text.length > 12) return AppTheme.displaySmall;
    if (text.length > 8)  return AppTheme.displayMedium;
    return AppTheme.displayLarge;
  }

  Future<void> _openHistory() async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollCtrl) => HistorySheet(
          manager: _ctrl.historyManager,
          scrollController: scrollCtrl,
          onClear: () async {
            await _ctrl.clearAllHistory();
            setState(() {});
          },
          onDeleteItem: (index) async {
            await _ctrl.deleteHistoryAt(index);
            setState(() {});
          },
          onLoadResult: _ctrl.loadFromHistory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const double hPad = 20;
    const double gap  = 12;
    final double btnSize = (w - hPad * 2 - gap * 3) / 4;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: IconButton(
                  onPressed: _openHistory,
                  icon: const Icon(
                    Icons.history_rounded,
                    color: AppTheme.buttonOrange,
                    size: 28,
                  ),
                  tooltip: 'History',
                  splashRadius: 24,
                ),
              ),
            ),

            const Spacer(),

            _ScrollableDisplayLine(
              text: _ctrl.expressionLine,
              style: AppTheme.historyStyle,
              padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, 4),
            ),
            _ScrollableDisplayLine(
              text: _ctrl.display,
              style: _displayStyle(_ctrl.display),
              padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, 20),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, 28),
              child: _Keypad(ctrl: _ctrl, s: btnSize, g: gap),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollableDisplayLine extends StatefulWidget {
  final String text;
  final TextStyle style;
  final EdgeInsets padding;

  const _ScrollableDisplayLine({
    required this.text,
    required this.style,
    required this.padding,
  });

  @override
  State<_ScrollableDisplayLine> createState() => _ScrollableDisplayLineState();
}

class _ScrollableDisplayLineState extends State<_ScrollableDisplayLine> {
  final ScrollController _sc = ScrollController();

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ScrollableDisplayLine old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sc.hasClients) {
          _sc.jumpTo(_sc.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: SingleChildScrollView(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        reverse: false,
        physics: const BouncingScrollPhysics(),
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }
}


class _Keypad extends StatelessWidget {
  final CalculatorController ctrl;
  final double s;
  final double g;

  const _Keypad({required this.ctrl, required this.s, required this.g});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _row([
          CalculatorButton.gray(
            label: ctrl.showC ? 'C' : 'AC',
            size: s,
            onTap: ctrl.showC ? ctrl.clearEntry : ctrl.clearAll,
            onLongPress: ctrl.clearAll,
          ),
          CalculatorButton.gray(label: '±', size: s, onTap: ctrl.toggleSign),
          CalculatorButton.gray(label: '%', size: s, onTap: ctrl.percent),
          CalculatorButton.orange(label: '÷', size: s, onTap: () => ctrl.setOperator('÷')),
        ]),
        SizedBox(height: g),
        _row([
          CalculatorButton.dark(label: '7', size: s, onTap: () => ctrl.inputNumber('7')),
          CalculatorButton.dark(label: '8', size: s, onTap: () => ctrl.inputNumber('8')),
          CalculatorButton.dark(label: '9', size: s, onTap: () => ctrl.inputNumber('9')),
          CalculatorButton.orange(label: '×', size: s, onTap: () => ctrl.setOperator('×')),
        ]),
        SizedBox(height: g),
        _row([
          CalculatorButton.dark(label: '4', size: s, onTap: () => ctrl.inputNumber('4')),
          CalculatorButton.dark(label: '5', size: s, onTap: () => ctrl.inputNumber('5')),
          CalculatorButton.dark(label: '6', size: s, onTap: () => ctrl.inputNumber('6')),
          CalculatorButton.orange(label: '-', size: s, onTap: () => ctrl.setOperator('-')),
        ]),
        SizedBox(height: g),
        _row([
          CalculatorButton.dark(label: '1', size: s, onTap: () => ctrl.inputNumber('1')),
          CalculatorButton.dark(label: '2', size: s, onTap: () => ctrl.inputNumber('2')),
          CalculatorButton.dark(label: '3', size: s, onTap: () => ctrl.inputNumber('3')),
          CalculatorButton.orange(label: '+', size: s, onTap: () => ctrl.setOperator('+')),
        ]),
        SizedBox(height: g),
        _row([
          _WideZero(size: s, gap: g, onTap: () => ctrl.inputNumber('0')),
          CalculatorButton.dark(label: '.', size: s, onTap: ctrl.inputDot),
          CalculatorButton.orange(label: '=', size: s, onTap: () => ctrl.calculateResult()),
        ]),
      ],
    );
  }

  Widget _row(List<Widget> children) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children);
}

class _WideZero extends StatelessWidget {
  final double size;
  final double gap;
  final VoidCallback onTap;

  const _WideZero({required this.size, required this.gap, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2 + gap,
      height: size,
      child: Material(
        color: AppTheme.buttonDark,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          splashColor: Colors.white12,
          highlightColor: Colors.white12,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: size * 0.38),
              child: const Text('0', style: AppTheme.buttonLabelLarge),
            ),
          ),
        ),
      ),
    );
  }
}
