import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
class CloudinaryService {
  final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
  final String apiKey = dotenv.env['CLOUDINARY_API_KEY']!;
  final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET']!;
  final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

  Future<String?> uploadImage(String imagePath) async {
    print('uploadImage called with imagePath: $imagePath'); // Debug line

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final bytes = utf8.encode('$apiKey:$apiSecret');
    final auth = base64.encode(bytes);

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imagePath))
      ..headers['Authorization'] = 'Basic $auth';

    try {
      final response = await request.send();
      print('Response status code: ${response.statusCode}'); // Debug line

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        return jsonData['secure_url'];
      } else {
        print('Error uploading image: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug line
      return null;
    }
  }

}
