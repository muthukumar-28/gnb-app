import 'package:get_storage/get_storage.dart';

class SessionStorage {
  static const String KEY_USER_TOKEN = 'userToken';
  static const String KEY_USER_DATA = 'userData';

  static final GetStorage _storage = GetStorage();

  static String? tokenValue;
  static String? name;
  static String? number;

  static Future<void> init() async => await GetStorage.init();

  static Future<void> saveToken(String token) async {
    await _storage.write(KEY_USER_TOKEN, token);
    tokenValue = token;
  }

  static String? getToken() {
    final data = _storage.read<String>(KEY_USER_TOKEN);
    print("object111111 ${data}");
    if (data != null) {
      tokenValue = data;
    } else {
      tokenValue = null;
    }
    return data;
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(KEY_USER_DATA, userData);
    name = userData['kam_name']?.toString();
    number = userData['mobile_no']?.toString();
  }

  static Map<String, dynamic>? getUserData() {
    final data = _storage.read<Map<String, dynamic>>(KEY_USER_DATA);

    if (data != null) {
      tokenValue = getToken();
      name = data['kam_name']?.toString();
      number = data['mobile_no']?.toString();
    } else {
      tokenValue = null;
      name = null;
      number = null;
    }

    return data;
  }

  static Future<void> clearSession() async {
    await _storage.remove(KEY_USER_TOKEN);
    await _storage.remove(KEY_USER_DATA);
  }
}
