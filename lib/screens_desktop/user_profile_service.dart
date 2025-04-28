import 'package:mysql1/mysql1.dart';

class UserProfileService {
  // Thông tin kết nối MySQL
  static final ConnectionSettings _settings = ConnectionSettings(
    host: 'shortline.proxy.rlwy.net',  // Địa chỉ máy chủ
    port: 25929,                       // Cổng kết nối
    user: 'root',                      // Tên người dùng
    password: 'UqEsdGHElSPxNxvhcyNucdxBQlHlTqzP',              // Mật khẩu
    db: 'Railway-MySQL',                     // Tên cơ sở dữ liệu
  );

  // Hàm cập nhật thông tin người dùng trong cơ sở dữ liệu MySQL
  Future<bool> updateUser({
    required int userId,
    required String fullName,
    required String email,
    required String address,
    required String password,
  }) async {
    try {
      // Kết nối đến cơ sở dữ liệu MySQL
      final conn = await MySqlConnection.connect(_settings);

      // Truy vấn SQL để cập nhật thông tin người dùng
      var result = await conn.query(
        'UPDATE users SET full_name = ?, email = ?, address = ?, password = ? WHERE id = ?',
        [fullName, email, address, password, userId],
      );

      // Kiểm tra số dòng bị ảnh hưởng (cập nhật thành công)
      if (result.affectedRows != null && result.affectedRows! > 0) {
        await conn.close();  // Đóng kết nối
        return true;  // Cập nhật thành công
      } else {
        await conn.close();  // Đóng kết nối
        return false;  // Không có dòng nào bị ảnh hưởng (cập nhật thất bại)
      }
    } catch (e) {
      print('Lỗi khi cập nhật người dùng: $e');
      return false;  // Nếu có lỗi trong quá trình kết nối hoặc truy vấn
    }
  }

  // Hàm lấy thông tin người dùng từ cơ sở dữ liệu
  Future<Map<String, dynamic>?> getUser(int userId) async {
    try {
      // Kết nối đến cơ sở dữ liệu MySQL
      final conn = await MySqlConnection.connect(_settings);

      // Truy vấn SQL để lấy thông tin người dùng
      var results = await conn.query(
        'SELECT full_name, email, phone_number, address FROM users WHERE id = ?',
        [userId],
      );

      // Kiểm tra và trả về kết quả nếu có dữ liệu
      if (results.isNotEmpty) {
        var row = results.first;
        await conn.close();  // Đóng kết nối
        return {
          'fullName': row[0],
          'email': row[1],
          'phoneNumber': row[2],
          'address': row[3],
        };
      } else {
        await conn.close();  // Đóng kết nối
        return null;  // Không tìm thấy người dùng
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;  // Nếu có lỗi trong quá trình kết nối hoặc truy vấn
    }
  }
}
