import 'package:shared_preferences/shared_preferences.dart';

import '../utils/get_it_injection.dart';

class CacheService {
  static const String userToken = "token";
  final _prefs = getIt<SharedPreferences>();


  Future<bool> setUserToken({required String token}) async {
    return _prefs.setString(userToken, "Bearer $token");
  }

  String? getUserToken(){
    return _prefs.getString(userToken);
  }

  Future<bool?> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      return null;
    }
  }

}
