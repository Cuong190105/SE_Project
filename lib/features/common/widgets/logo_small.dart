import 'package:flutter/material.dart';
import 'package:eng_dictionary/features/desktop/home/home_screen.dart';

class LogoSmall extends StatelessWidget {
  const LogoSmall({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool isHoveringIcon = false;
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'DICTIONARY',
              softWrap: false,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
                letterSpacing: 2,
              ),
            ),
          ),

          StatefulBuilder(
            builder: (context, setState) {

              return MouseRegion(
                onEnter: (_) => setState(() => isHoveringIcon = true),
                onExit: (_) => setState(() => isHoveringIcon = false),
                child: InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreenDesktop()),
                          (route) => false, 
                    );
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isHoveringIcon ? Colors.grey.shade300 : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 2,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.book,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
  }
}