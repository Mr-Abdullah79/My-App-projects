import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryStorageService {
  static const String _key = 'solar_history_entries';
  static const int _maxEntries = 100;

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? <String>[];

    final parsed = <Map<String, dynamic>>[];
    for (final item in rawList) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          parsed.add(decoded);
        }
      } catch (_) {
        // Ignore malformed history item and continue.
      }
    }
    return parsed;
  }

  static Future<void> saveEntry(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? <String>[];

    rawList.insert(0, jsonEncode(entry));
    if (rawList.length > _maxEntries) {
      rawList.removeRange(_maxEntries, rawList.length);
    }
    await prefs.setStringList(_key, rawList);
  }

  static Future<void> deleteAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? <String>[];
    if (index < 0 || index >= rawList.length) return;
    rawList.removeAt(index);
    await prefs.setStringList(_key, rawList);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
