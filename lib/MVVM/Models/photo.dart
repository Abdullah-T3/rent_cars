import 'package:hive/hive.dart';

part 'photo.g.dart';
@HiveType(typeId: 5)
class Photo {
  @HiveField(0)
  final String url;

  Photo({required this.url});
}
