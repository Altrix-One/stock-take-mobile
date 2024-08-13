import 'package:flutter/material.dart';
import 'package:stock_count/constants/theme.dart';

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ErrorDialog(message: message);
    },
  );
}

class ErrorDialog extends StatefulWidget {
  final String message;
  const ErrorDialog({Key? key, required this.message}) : super(key: key);

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: whiteColor,
      title: Align(
        // Align widget used here for better control
        alignment: Alignment.center,
        child: ScaleTransition(
          scale: _animation,
          child: Icon(Icons.error, color: Colors.red, size: 30),
        ),
      ),
      content: Text(widget.message,
          style: medium14Black33, textAlign: TextAlign.center),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
