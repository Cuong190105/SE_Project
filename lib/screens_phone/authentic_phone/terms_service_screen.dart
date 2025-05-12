import 'package:flutter/material.dart';

class TermsServiceScreen extends StatelessWidget {
  final String title;
  final String content;

  const TermsServiceScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsServiceContent {
  static const String termsOfServiceTitle = "Điều khoản dịch vụ";
  static const String privacyPolicyTitle = "Chính sách bảo mật";

  static const String termsOfServiceContent = '''
# ĐIỀU KHOẢN DỊCH VỤ

## 1. Giới thiệu

Chào mừng bạn đến với ứng dụng Dictionary. Bằng việc sử dụng ứng dụng này, bạn đồng ý tuân thủ và chịu ràng buộc bởi các điều khoản và điều kiện được nêu dưới đây.

## 2. Sử dụng dịch vụ

Bạn đồng ý sử dụng dịch vụ của chúng tôi chỉ cho các mục đích hợp pháp và theo cách không vi phạm quyền của người khác, hoặc hạn chế hoặc cản trở việc sử dụng và hưởng thụ dịch vụ của bất kỳ ai.

## 3. Tài khoản người dùng

Để sử dụng một số tính năng của ứng dụng, bạn có thể cần phải đăng ký tài khoản. Bạn đồng ý cung cấp thông tin chính xác, cập nhật và đầy đủ khi đăng ký và duy trì tính chính xác của thông tin đó.

## 4. Quyền sở hữu trí tuệ

Tất cả nội dung, tính năng và chức năng trong ứng dụng Dictionary, bao gồm nhưng không giới hạn ở văn bản, đồ họa, logo, biểu tượng, hình ảnh, clip âm thanh, và phần mềm, đều là tài sản của chúng tôi hoặc các nhà cung cấp nội dung của chúng tôi và được bảo vệ bởi luật bản quyền, thương hiệu, bằng sáng chế, bí mật thương mại và các quyền sở hữu trí tuệ hoặc quyền sở hữu khác.

## 5. Giới hạn trách nhiệm

Trong mọi trường hợp, chúng tôi sẽ không chịu trách nhiệm đối với bạn hoặc bất kỳ bên thứ ba nào về bất kỳ thiệt hại trực tiếp, gián tiếp, do hậu quả, ngẫu nhiên, đặc biệt hoặc trừng phạt nào phát sinh từ việc sử dụng hoặc không thể sử dụng dịch vụ của chúng tôi.

## 6. Thay đổi điều khoản

Chúng tôi có quyền sửa đổi hoặc thay thế các điều khoản này bất cứ lúc nào. Việc bạn tiếp tục sử dụng ứng dụng sau khi những thay đổi được đăng tải sẽ cấu thành sự chấp nhận của bạn đối với các điều khoản mới.

## 7. Liên hệ

Nếu bạn có bất kỳ câu hỏi nào về các Điều khoản Dịch vụ này, vui lòng liên hệ với chúng tôi qua email: support@dictionary-app.com
''';

  static const String privacyPolicyContent = '''
# CHÍNH SÁCH BẢO MẬT

## 1. Thông tin chúng tôi thu thập

Khi bạn đăng ký tài khoản với Dictionary, chúng tôi có thể thu thập thông tin cá nhân như tên, địa chỉ email, và thông tin thiết bị của bạn.

## 2. Cách chúng tôi sử dụng thông tin

Chúng tôi sử dụng thông tin thu thập được để:
- Cung cấp, duy trì và cải thiện dịch vụ của chúng tôi
- Gửi thông báo liên quan đến tài khoản của bạn
- Phản hồi các yêu cầu, câu hỏi và phản hồi của bạn
- Phân tích cách người dùng sử dụng ứng dụng để cải thiện trải nghiệm

## 3. Bảo mật thông tin

Chúng tôi thực hiện các biện pháp bảo mật hợp lý để bảo vệ thông tin cá nhân của bạn khỏi mất mát, truy cập trái phép, sử dụng, thay đổi và tiết lộ.

## 4. Chia sẻ thông tin

Chúng tôi không bán, trao đổi hoặc chuyển giao thông tin cá nhân của bạn cho các bên thứ ba. Điều này không bao gồm các bên thứ ba đáng tin cậy hỗ trợ chúng tôi vận hành ứng dụng của mình, miễn là các bên đồng ý giữ bí mật thông tin này.

## 5. Quyền của bạn

Bạn có quyền truy cập, sửa đổi hoặc xóa thông tin cá nhân của mình bất cứ lúc nào. Bạn cũng có thể chọn không nhận email từ chúng tôi bằng cách sử dụng liên kết hủy đăng ký trong bất kỳ email nào chúng tôi gửi.

## 6. Thay đổi chính sách

Chúng tôi có thể cập nhật Chính sách Bảo mật này theo thời gian. Chúng tôi sẽ thông báo cho bạn về bất kỳ thay đổi nào bằng cách đăng chính sách mới trên ứng dụng của chúng tôi.

## 7. Liên hệ

Nếu bạn có bất kỳ câu hỏi nào về Chính sách Bảo mật này, vui lòng liên hệ với chúng tôi qua email: privacy@dictionary-app.com
''';
}
