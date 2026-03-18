import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../theme/app_theme.dart';

class HistoryItemWidget extends StatelessWidget {
  final HistoryEntry entry;
  final bool selected;
  final bool editMode;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onSelectToggle;

  const HistoryItemWidget({
    super.key,
    required this.entry,
    this.selected = false,
    this.editMode = false,
    this.onTap,
    this.onDelete,
    this.onSelectToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            if (editMode) ...[
              GestureDetector(
                onTap: onSelectToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppTheme.buttonOrange : Colors.white30,
                      width: 2,
                    ),
                    color: selected
                        ? AppTheme.buttonOrange
                        : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    entry.expression,
                    style: const TextStyle(
                      color: AppTheme.historyText,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '= ${entry.result}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),

            if (!editMode && onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white24,
                  size: 20,
                ),
                onPressed: onDelete,
                splashRadius: 20,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
