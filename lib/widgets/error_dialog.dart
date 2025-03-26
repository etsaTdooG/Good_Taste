import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String content;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: AppTheme.subheadingStyle.copyWith(color: AppTheme.errorColor),
      ),
      content: Text(
        content,
        style: AppTheme.bodyTextStyle,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
} 