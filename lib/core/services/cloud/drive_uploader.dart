import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'google_drive_service.dart'; // bạn đã cấu hình auth ở đây

class DriveUploader {
  final drive.DriveApi driveApi;

  DriveUploader(this.driveApi);

  // Upload một ảnh và trả về link công khai
  Future<String?> uploadImage(Uint8List imageData, String fileName) async {
    try {
      // Tạo metadata
      var media = drive.Media(Stream.value(imageData), imageData.length);
      var file = drive.File()
        ..name = fileName
        ..mimeType = 'image/jpeg';

      // Upload file
      final uploadedFile = await driveApi.files.create(
        file,
        uploadMedia: media,
      );

      final fileId = uploadedFile.id;

      // Cài đặt quyền xem công khai
      await driveApi.permissions.create(
        drive.Permission()
          ..type = 'anyone'
          ..role = 'reader',
        fileId!,
      );

      // Trả về link trực tiếp đến file
      final publicLink = "https://drive.google.com/uc?id=$fileId";
      return publicLink;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  // Upload nhiều ảnh
  Future<List<String>> uploadImages(List<Uint8List> images) async {
    List<String> links = [];
    for (int i = 0; i < images.length; i++) {
      final link = await uploadImage(images[i], 'image_$i.jpg');
      if (link != null) links.add(link);
    }
    return links;
  }
}
