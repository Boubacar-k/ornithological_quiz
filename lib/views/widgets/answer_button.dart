import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final bool isDisabled;
  final VoidCallback onPressed;

  const AnswerButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.isDisabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}