import 'package:eng_dictionary/screens_phone/authentic_phone/login_screen_phone.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

enum Step { emailEntry, pinVerification, newPassword, success }

class ForgotpasswordScreenPhone extends StatefulWidget {
  const ForgotpasswordScreenPhone({super.key});

  @override
  State<ForgotpasswordScreenPhone> createState() =>
      _ForgotpasswordScreenPhoneState();
}

class _ForgotpasswordScreenPhoneState extends State<ForgotpasswordScreenPhone> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obsecurePassword = true;

  Step _currentStep = Step.emailEntry;

  String? _generatedPin;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Giả lập mã pin giả
  String generatedPin() {
    return "123456";
  }

  void _sendResetPin() {
    if (_formKey.currentState!.validate()) {
      _generatedPin = generatedPin();

      print('PIN sent to ${_emailController.text}: $_generatedPin');

      setState(() {
        _currentStep = Step.pinVerification;
        _errorMessage = null;
      });
    }
  }

  void _verifyPin() {
    if (_formKey.currentState!.validate()) {
      if (_pinController.text == _generatedPin) {
        setState(() {
          _currentStep = Step.newPassword;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Mã PIN không đúng. Vui lòng thử lại.';
        });
      }
    }
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep = Step.success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.purple.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 60,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "QUÊN MẬT KHẨU",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 10,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: _buildCurrentStep(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case Step.emailEntry:
        return _buildEmailForm();
      case Step.pinVerification:
        return _buildPinVerficationForm();
      case Step.newPassword:
        return _buildNewPasswordForm();
      case Step.success:
        return _buildSuccessMessage();
      default:
        return _buildEmailForm(); // Default case to satisfy non-nullable return type
    }
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            'Đặt lại mật khẩu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Nhập email của bạn để lấy lại mật khẩu",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),

          //email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "Nhập email của bạn",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _sendResetPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'XÁC NHẬN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinVerficationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'XÁC THỰC MÃ PIN',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Text(
            'Chúng tôi đã gửi mã pin có 6 chữ số tới ${_emailController.text}. Vui lòng nhập mã để tiếp tục',
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 16),
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _pinController,
            keyboardType: TextInputType.number,
            autoFocus: true,
            animationType: AnimationType.fade,
            textInputAction: TextInputAction.done,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(10),
              fieldHeight: 50,
              fieldWidth: 40,
              activeFillColor: Colors.white,
              inactiveColor: Colors.grey.shade300,
              selectedColor: Colors.blue.shade700,
              activeColor: Colors.blue.shade700,
              selectedFillColor: Colors.white,
              inactiveFillColor: Colors.white,
            ),
            animationDuration: const Duration(milliseconds: 300),
            enableActiveFill: true,
            onChanged: (value) {
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mã PIN';
              }
              if (value.length != 6) {
                return 'Mã PIN phải có 6 số';
              }
              if (_errorMessage != null) {
                return _errorMessage;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Verify PIN button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _verifyPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                'XÁC THỰC',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Resend PIN
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không nhận được mã?'),
              TextButton(
                onPressed: _sendResetPin,
                child: Text(
                  'Gửi lại',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            'ĐẶT MẬT KHẨU MỚI',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hãy đặt mật khẩu mới cho tài khoản của bạn',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obsecurePassword,
            decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                hintText: 'Nhập mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obsecurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obsecurePassword = !_obsecurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blue.shade700, width: 2))),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 8) {
                return 'Mật khẩu phải ít nhất 8 kí tự';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                hintText: 'Nhập lại mật khẩu mới',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blue.shade700, width: 2))),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (value != _newPasswordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                child: const Text(
                  'XÁC NHẬN',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                )),
          )
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Colors.green.shade600,
        ),
        const SizedBox(height: 24),
        const Text(
          'Đặt lại mật khẩu thành công!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Mật khẩu của bạn đã được đặt lại thành công. Bây giờ bạn có thể đăng nhập bằng mật khẩu mới.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreenPhone()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child: const Text(
              'QUAY LẠI ĐĂNG NHẬP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
