
import 'package:shared_preferences/shared_preferences.dart';

class SaveManager{
  static SaveManager instance = SaveManager();
  SharedPreferences? _prefs;

  Future<bool> loadPrefs() async{
    if(_prefs != null) return true;
    _prefs = await SharedPreferences.getInstance();
    return true;
  }

  Future<String?> loadString(String key) async {
    if(_prefs == null) await loadPrefs();
    return _prefs!.getString(key);
  }

  Future<bool> loadBool(String key, {bool def = false}) async {
    if(_prefs == null) await loadPrefs();
    var b  =  _prefs!.getBool(key);
    if(b==null) {
      _prefs!.setBool(key, def);
      return def;
    }
    return b;
  }
  Future<void> saveBool(String key, bool value) async {
    if(_prefs == null) await loadPrefs();
    _prefs!.setBool(key, value);
  }
  Future<void> saveString(String key, String? value) async {
    if(_prefs == null) await loadPrefs();
    if(value == null){
      _prefs!.setString(key, "");
    }else{
      _prefs!.setString(key, value);
    }
  }

}