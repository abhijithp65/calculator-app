import 'dart:convert';
import 'package:calculator_app/Widgets/calculator_button.dart';
import 'package:calculator_app/Widgets/history_sheet.dart';
import 'package:calculator_app/utils/calculator_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorController controller = CalculatorController();
  @override
  void initState() {
    super.initState();
    controller.loadHistory();
    controller.addListener(_onController);
  }

  @override
  void dispose() {
    controller.removeListener(_onController);
    controller.dispose();
    super.dispose();
  }

  void _onController() => setState(() {});
  Future<void> _openHistory() async {
    HapticFeedback.selectionClick();
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return HistorySheet(
          historyItems: controller.historyItems,
          onClear: () async {
            await controller.clearAllHistory();
            setState(() {});
          },
          onDeleteItem: (index) async {
            await controller.deleteHistoryAt(index);
            setState(() {});
          },
          onLoadResult: (value) {
            Navigator.pop(context, value);
          },
          onToggleSelection: (selectedIndices) {},
        );
      },
    );

    if (result != null) {
      // Load tapped history result back into calculator
      controller.loadFromHistory(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showC = controller.display != '0';
    final double btnSize = 80;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // HISTORY BAR (opens bottom sheet)
            GestureDetector(
              onTap: _openHistory,
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.orange, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.historyLine,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // DISPLAY
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
              alignment: Alignment.bottomRight,
              child: Text(
                controller.display,
                style: const TextStyle(
                  fontSize: 90,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // BUTTON GRID
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                children: [
                  // row 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // C / AC: short tap delete one, long press clear all
                      GestureDetector(
                        onTap: controller.deleteOne,
                        onLongPress: controller.clearAll,
                        child: SizedBox(
                          width: btnSize,
                          height: btnSize,
                          child: Material(
                            color: Colors.grey.shade700,
                            shape: const CircleBorder(),
                            child: Center(
                              child: Text(
                                showC ? 'C' : 'AC',
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      CalculatorButton.gray(
                        label: '±',
                        size: btnSize,
                        onTap: controller.toggleSign,
                      ),
                      CalculatorButton.gray(
                        label: '%',
                        size: btnSize,
                        onTap: controller.percent,
                      ),
                      CalculatorButton.orange(
                        label: '÷',
                        size: btnSize,
                        onTap: () => controller.setOperator('÷'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // row 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CalculatorButton.dark(
                        label: '7',
                        size: btnSize,
                        onTap: () => controller.inputNumber('7'),
                      ),
                      CalculatorButton.dark(
                        label: '8',
                        size: btnSize,
                        onTap: () => controller.inputNumber('8'),
                      ),
                      CalculatorButton.dark(
                        label: '9',
                        size: btnSize,
                        onTap: () => controller.inputNumber('9'),
                      ),
                      CalculatorButton.orange(
                        label: '×',
                        size: btnSize,
                        onTap: () => controller.setOperator('×'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // row 3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CalculatorButton.dark(
                        label: '4',
                        size: btnSize,
                        onTap: () => controller.inputNumber('4'),
                      ),
                      CalculatorButton.dark(
                        label: '5',
                        size: btnSize,
                        onTap: () => controller.inputNumber('5'),
                      ),
                      CalculatorButton.dark(
                        label: '6',
                        size: btnSize,
                        onTap: () => controller.inputNumber('6'),
                      ),
                      CalculatorButton.orange(
                        label: '-',
                        size: btnSize,
                        onTap: () => controller.setOperator('-'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // row 4
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CalculatorButton.dark(
                        label: '1',
                        size: btnSize,
                        onTap: () => controller.inputNumber('1'),
                      ),
                      CalculatorButton.dark(
                        label: '2',
                        size: btnSize,
                        onTap: () => controller.inputNumber('2'),
                      ),
                      CalculatorButton.dark(
                        label: '3',
                        size: btnSize,
                        onTap: () => controller.inputNumber('3'),
                      ),
                      CalculatorButton.orange(
                        label: '+',
                        size: btnSize,
                        onTap: () => controller.setOperator('+'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // row 5
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: btnSize * 2 + 10,
                        height: btnSize,
                        child: Material(
                          color: Colors.grey.shade900,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            onTap: () => controller.inputNumber('0'),
                            borderRadius: BorderRadius.circular(50),
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 34),
                                child: Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      CalculatorButton.dark(
                        label: '.',
                        size: btnSize,
                        onTap: () => controller.inputDot(),
                      ),
                      CalculatorButton.orange(
                        label: '=',
                        size: btnSize,
                        onTap: () => controller.calculateResult(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
