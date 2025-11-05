import 'package:flutter/material.dart';

class SocialSigningRowButton extends StatelessWidget {
  final String title;
  final double width;
  final TextStyle? titleStyle;
  final IconData icon;
  final Color iconColor = Colors.black;
  final Color rowBackgroundColor = Colors.white;
  final VoidCallback? onPressed;
  const SocialSigningRowButton({
    super.key,
    required this.title,
    required this.width,
    this.titleStyle,
    required this.icon,
    this.onPressed,
    required MaterialColor iconColor,
    required MaterialColor rowBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: rowBackgroundColor,
        onPressed: onPressed,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Icon(icon, color: iconColor),
            ),
            SizedBox(width: width),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: titleStyle),
            ),
          ],
        ),
      ),
    );
  }
}
