
import 'package:shared_preferences/shared_preferences.dart';

abstract class IDatabaseRepository {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  
  Future<void> saveInt(String key, int value);
  Future<int?> getInt(String key);
  
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPreferencesRepository implements IDatabaseRepository {
  final SharedPreferences _prefs;

  SharedPreferencesRepository(this._prefs);

  static Future<SharedPreferencesRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesRepository(prefs);
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}
