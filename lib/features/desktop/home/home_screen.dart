import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/common/widgets/streak_count.dart';
import 'package:eng_dictionary/features/common/widgets/setting_button.dart';
import 'package:eng_dictionary/features/common/widgets/search.dart';
import 'package:eng_dictionary/features/common/widgets/logo_big.dart';
import 'package:eng_dictionary/features/desktop/home/widgets/buildIcon_grid.dart';
class HomeScreenDesktop extends StatefulWidget {
  const HomeScreenDesktop({super.key});

  @override
  _HomeScreenDesktopState createState() => _HomeScreenDesktopState();
}
class _HomeScreenDesktopState extends State<HomeScreenDesktop> {

  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int streakCount = 5; // Đợi database
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade300,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: StreakCount(streakCount: streakCount),
          ),
         SettingButton(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
            stops: const [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 25),
                LogoBig(),
                const SizedBox(height: 30),
                Search(controller: _controller),
                const SizedBox(height: 24),
                BuildIconGrid(controller: _controller,),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
