import 'package:material_ui/material_ui.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color? color;
  final String text;
  final double? height, width, borderRadius;
  const CustomButton({
    super.key,
    this.onPressed,
    this.color,
    required this.text,
    this.height = 60.0,
    this.width = double.infinity,
    this.borderRadius = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(width!, height!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}
