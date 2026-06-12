import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'disztxaqt';
  static const String uploadPreset = 'Online-perfume-app';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
      );

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('🔹 Cloudinary Status Code: ${response.statusCode}');
      print('🔹 Cloudinary Response: $responseData');

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(responseData);
        String? url = result['secure_url'];
        print(' Image Uploaded Successfully: $url');
        return url;
      } else {
        print(' Cloudinary Upload Failed');
        return null;
      }
    } catch (e) {
      print(' Cloudinary Exception: $e');
      return null;
    }
  }
}