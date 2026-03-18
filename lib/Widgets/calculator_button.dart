import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum _Variant { dark, gray, orange }

class CalculatorButton extends StatelessWidget {
  final String label;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final _Variant _variant;

  const CalculatorButton._({
    required this.label,
    required this.size,
    required this.onTap,
    required _Variant variant,
    this.onLongPress,
  }) : _variant = variant;

  factory CalculatorButton.dark({
    required String label,
    required double size,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) =>
      CalculatorButton._(
        label: label, size: size, onTap: onTap,
        variant: _Variant.dark, onLongPress: onLongPress,
      );

  factory CalculatorButton.gray({
    required String label,
    required double size,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) =>
      CalculatorButton._(
        label: label, size: size, onTap: onTap,
        variant: _Variant.gray, onLongPress: onLongPress,
      );

  factory CalculatorButton.orange({
    required String label,
    required double size,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) =>
      CalculatorButton._(
        label: label, size: size, onTap: onTap,
        variant: _Variant.orange, onLongPress: onLongPress,
      );

  Color get _bg {
    switch (_variant) {
      case _Variant.dark:   return AppTheme.buttonDark;
      case _Variant.gray:   return AppTheme.buttonGray;
      case _Variant.orange: return AppTheme.buttonOrange;
    }
  }

  Color get _splash {
    switch (_variant) {
      case _Variant.dark:   return Colors.white12;
      case _Variant.gray:   return Colors.black12;
      case _Variant.orange: return Colors.white24;
    }
  }

  TextStyle get _labelStyle {
    switch (_variant) {
      case _Variant.gray:   return AppTheme.buttonLabelGray;
      default:              return AppTheme.buttonLabelLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: _bg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          customBorder: const CircleBorder(),
          splashColor: _splash,
          highlightColor: _splash,
          child: Center(
            child: Text(label, style: _labelStyle),
          ),
        ),
      ),
    );
  }
}
