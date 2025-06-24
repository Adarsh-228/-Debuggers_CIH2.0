import 'dart:convert';

import 'package:hackathon/feature/logs/data/models/meal_log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealLogRepository {
  static const _kMealLogsKey = 'meal_logs';
  final SharedPreferences _prefs;

  MealLogRepository(this._prefs);

  Future<void> saveMealLog(MealLogModel log) async {
    final logs = await getMealLogs();

    // Remove existing log with same ID to avoid duplicates
    logs.removeWhere((existingLog) => existingLog.id == log.id);

    // Add the new log
    logs.add(log);

    final jsonLogs = logs.map((log) => log.toJson()).toList();
    await _prefs.setString(_kMealLogsKey, jsonEncode(jsonLogs));
  }

  Future<List<MealLogModel>> getMealLogs() async {
    final jsonString = _prefs.getString(_kMealLogsKey);
    if (jsonString == null) return [];

    final jsonLogs = jsonDecode(jsonString) as List;
    return jsonLogs.map((json) => MealLogModel.fromJson(json)).toList();
  }

  Future<void> clearLogs() async {
    await _prefs.remove(_kMealLogsKey);
  }
}
