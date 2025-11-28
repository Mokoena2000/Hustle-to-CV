import 'package:flutter/material.dart';

class QuickActionChip extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const QuickActionChip({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text),
      onPressed: onPressed,
      backgroundColor: Colors.green[100],
      labelStyle: TextStyle(color: Colors.green[800]),
    );
  }
}