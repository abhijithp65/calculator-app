import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/history_manager.dart';
import 'history_item.dart';

class HistorySheet extends StatefulWidget {
  final HistoryManager manager;
  final ScrollController? scrollController;
  final Future<void> Function() onClear;
  final Future<void> Function(int index) onDeleteItem;
  final void Function(String result) onLoadResult;

  const HistorySheet({
    super.key,
    required this.manager,
    required this.onClear,
    required this.onDeleteItem,
    required this.onLoadResult,
    this.scrollController,
  });

  @override
  State<HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<HistorySheet> {
  bool _editMode = false;

  void _toggleEditMode() => setState(() {
    _editMode = !_editMode;
    if (!_editMode) widget.manager.clearSelection();
  });

  Future<void> _deleteSelected() async {
    final indices = <int>[];
    for (int i = 0; i < widget.manager.history.length; i++) {
      if (widget.manager.history[i].isSelected) indices.add(i);
    }
    for (final idx in indices.reversed) {
      await widget.onDeleteItem(idx);
    }
    setState(() => _editMode = false);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = widget.manager.groupedHistory();
    final hasSelection = widget.manager.hasSelection;
    final isEmpty = widget.manager.history.isEmpty;

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: isEmpty ? null : _toggleEditMode,
                child: Text(
                  _editMode ? 'Done' : 'Edit',
                  style: TextStyle(
                    color: isEmpty ? Colors.white24 : AppTheme.buttonOrange,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_editMode)
                TextButton(
                  onPressed: hasSelection ? _deleteSelected : null,
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: hasSelection ? Colors.redAccent : Colors.white24,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: isEmpty
                      ? null
                      : () async {
                          await widget.onClear();
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: isEmpty ? Colors.white24 : AppTheme.buttonOrange,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const Divider(color: AppTheme.divider, height: 1),

        Expanded(
          child: isEmpty
              ? const Center(
                  child: Text(
                    'No history yet',
                    style: TextStyle(color: AppTheme.historyText, fontSize: 17),
                  ),
                )
              : ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: grouped.length,
                  itemBuilder: (ctx, sectionIdx) {
                    final dayLabel = grouped.keys.elementAt(sectionIdx);
                    final entries = grouped[dayLabel]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 4),
                          child: Text(
                            dayLabel,
                            style: const TextStyle(
                              color: AppTheme.historyText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...entries.map((me) {
                          final globalIndex = me.key;
                          final entry = me.value;
                          return Dismissible(
                            key: ValueKey(entry.timestamp.toIso8601String()),
                            direction: _editMode
                                ? DismissDirection.none
                                : DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) async {
                              await widget.onDeleteItem(globalIndex);
                              setState(() {});
                            },
                            child: HistoryItemWidget(
                              entry: entry,
                              selected: entry.isSelected,
                              editMode: _editMode,
                              onTap: () {
                                if (_editMode) {
                                  setState(
                                    () => widget.manager.toggleSelect(
                                      globalIndex,
                                    ),
                                  );
                                  return;
                                }
                                widget.onLoadResult(entry.result);
                                Navigator.pop(context);
                              },
                              onDelete: () async {
                                await widget.onDeleteItem(globalIndex);
                                setState(() {});
                              },
                              onSelectToggle: () => setState(
                                () => widget.manager.toggleSelect(globalIndex),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
