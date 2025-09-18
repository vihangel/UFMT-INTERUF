import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _chosenAthleticNameKey = 'chosen_athletic_name';
  static const String _chosenAthleticSeriesKey = 'chosen_athletic_series';

  Future<void> saveChosenAthletic(String name, String series) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chosenAthleticNameKey, name);
    await prefs.setString(_chosenAthleticSeriesKey, series);
  }

  Future<String?> getChosenAthleticName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chosenAthleticNameKey);
  }
}
