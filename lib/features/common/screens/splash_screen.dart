import 'package:flutter/material.dart';
import 'package:eng_dictionary/core/services/auth_service.dart';
import 'package:eng_dictionary/features/desktop/home/home_screen.dart';
import 'package:eng_dictionary/features/mobile/home/home_screen.dart';
import 'login_screen.dart';
import 'package:flutter/foundation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Kiểm tra trạng thái đăng nhập và chuyển hướng người dùng
  Future<void> _checkLoginStatus() async {
    // Đợi 2 giây để hiển thị splash screen
    await Future.delayed(Duration(seconds: 2));

    // Kiểm tra xem người dùng đã đăng nhập chưa
    final isLoggedIn = await AuthService.isLoggedIn();
    if (defaultTargetPlatform == TargetPlatform.android
        ||defaultTargetPlatform == TargetPlatform.iOS) {
      if (isLoggedIn) {
        // Nếu đã đăng nhập, chuyển đến màn hình chính
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreenDesktop()),
        );
      } else {
        // Nếu chưa đăng nhập, chuyển đến màn hình đăng nhập
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else {
      if (isLoggedIn) {
        // Nếu đã đăng nhập, chuyển đến màn hình chính
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreenDesktop()),
        );
      } else {
      // Nếu chưa đăng nhập, chuyển đến màn hình đăng nhập
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.purple.shade200],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.book,
                  size: 80,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // App name
              const Text(
                "DICTIONARY",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 50),

              // Loading indicator
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}