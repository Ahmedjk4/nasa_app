import 'package:hive_flutter/hive_flutter.dart';

class HiveFunctions {
  static const String _boxName = 'asfinafiinf';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<Box> openBox() async {
    return await Hive.openBox(_boxName);
  }

  static Future<void> putData(String key, dynamic value) async {
    var box = await openBox();
    await box.put(key, value);
  }

  static Future<dynamic> getData(String key) async {
    var box = await openBox();
    return box.get(key);
  }

  static Future<void> deleteData(String key) async {
    var box = await openBox();
    await box.delete(key);
  }

  static Future<void> clearBox() async {
    var box = await openBox();
    await box.clear();
  }
}
