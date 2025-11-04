// lib/models/pattern_info.dart
import './log_entry.dart'; // <-- Necesita esto para DailyMood

// Esta es la clase que define lo que es un "Patrón"
class PatternInfo {
  final int logCount;
  final DailyMood mostCommonMood;
  final String mostCommonNote; 

  PatternInfo({
    required this.logCount,
    required this.mostCommonMood,
    this.mostCommonNote = '',
  });
}