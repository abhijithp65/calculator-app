class HistoryEntry {
  final String expression;
  final String result;
  final DateTime timestamp;
  bool isSelected;

  HistoryEntry({
    required this.expression,
    required this.result,
    required this.timestamp,
    this.isSelected = false,
  });

  Map<String, dynamic> toMap() => {
        'expression': expression,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
        'isSelected': isSelected,
      };

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    DateTime ts;
    final rawTs = map['timestamp'];
    if (rawTs is int) {
      ts = DateTime.fromMillisecondsSinceEpoch(rawTs);
    } else if (rawTs is String) {
      ts = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else {
      ts = DateTime.now();
    }

    return HistoryEntry(
      expression: map['expression'] ?? '',
      result: map['result'] ?? '',
      timestamp: ts,
      isSelected: map['isSelected'] ?? false,
    );
  }

  @override
  String toString() => 'HistoryEntry($expression = $result)';
}
