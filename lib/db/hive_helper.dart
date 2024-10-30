import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../MVVM/Models/photo.dart';

class HiveHelper {
  static const String photoBoxName = 'photos';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PhotoAdapter());
    await Hive.openBox<Photo>(photoBoxName);
  }
  static Box<Photo> get photoBox => Hive.box<Photo>(photoBoxName);
}
