import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageService {
  Future<void> setUid(String uid);
  Future<String?> getUid();
  Future<void> clearUid();
}

class LocalStorageServiceImpl implements LocalStorageService {
  static const _kUidKey = 'uid';
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sp async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<void> setUid(String uid) async {
    final sp = await _sp;
    await sp.setString(_kUidKey, uid);
  }

  @override
  Future<String?> getUid() async {
    final sp = await _sp;
    return sp.getString(_kUidKey);
  }

  @override
  Future<void> clearUid() async {
    final sp = await _sp;
    await sp.remove(_kUidKey);
  }
}
