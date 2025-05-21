import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {

final String content;
final Color? color;
const CustomBackButton({this.color,super.key, required this.content});

  @override
  Widget build(BuildContext context) {

    bool _isHovering = false; // Hover effect flag

  return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Material(
            color: _isHovering ? Colors.grey.shade300 : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.blue.withOpacity(0.2),
              highlightColor: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 300), // Set your max width
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buttonBack(context),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            content,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: color ?? Colors.blue.shade700,
                              letterSpacing: 1,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            ),
          ),
        );
      },
   
  );
}

   // Nút quay lại
  Widget buttonBack(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 30, color: Colors.blue.shade700),

        onPressed: () {
          Navigator.pop(context);
        },

        hoverColor: Colors.grey.shade300.withOpacity(0),   
      ),
    );
  }
}

class CustomBackButton_ extends StatelessWidget {

  final String content;
  final Color color;
  const CustomBackButton_({super.key, required this.content, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {

    bool _isHovering = false; // Hover effect flag

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Material(
            color: _isHovering ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(30),
              splashColor: color.withOpacity(0.2),
              highlightColor: color.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child:Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buttonBack(context),
                    const SizedBox(width: 8),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },

    );
  }

  // Nút quay lại
  Widget buttonBack(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),

        onPressed: () {
          Navigator.pop(context);
        },

        hoverColor: color.withOpacity(0),
      ),
    );
  }
}