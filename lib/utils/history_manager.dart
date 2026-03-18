import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';

class HistoryManager {
  static const String _storageKey = 'calc_history_v2';

  List<HistoryEntry> history = [];

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_storageKey);
    if (jsonData == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(jsonData);
      history = decoded
          .map((e) => HistoryEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      history = [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(history.map((e) => e.toMap()).toList()),
    );
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<void> addEntry(String expression, String result) async {
    history.insert(
      0,
      HistoryEntry(
        expression: expression,
        result: result,
        timestamp: DateTime.now(),
      ),
    );
    await _persist();
  }

  Future<void> deleteAt(int index) async {
    if (index < 0 || index >= history.length) return;
    history.removeAt(index);
    await _persist();
  }

  Future<void> deleteSelected() async {
    history.removeWhere((e) => e.isSelected);
    await _persist();
  }

  Future<void> clearAll() async {
    history.clear();
    await _persist();
  }

  // ── Selection helpers ──────────────────────────────────────────────────────

  void toggleSelect(int index) {
    if (index < 0 || index >= history.length) return;
    history[index].isSelected = !history[index].isSelected;
  }

  void clearSelection() {
    for (final e in history) {
      e.isSelected = false;
    }
  }

  bool get hasSelection => history.any((e) => e.isSelected);

  // ── Grouping ───────────────────────────────────────────────────────────────

  Map<String, List<MapEntry<int, HistoryEntry>>> groupedHistory() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<MapEntry<int, HistoryEntry>>> groups = {};

    for (int i = 0; i < history.length; i++) {
      final entry = history[i];
      final entryDay = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      final String label;
      if (entryDay == today) {
        label = 'Today';
      } else if (entryDay == yesterday) {
        label = 'Yesterday';
      } else {
        label =
            '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}';
      }

      groups.putIfAbsent(label, () => []);
      groups[label]!.add(MapEntry(i, entry));
    }

    return groups;
  }
}
