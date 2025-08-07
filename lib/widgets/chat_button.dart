import 'package:flutter/material.dart';

/// Floating action button that opens the chat screen.
class ChatButton extends StatelessWidget {
  const ChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/chat'),
      child: const Icon(Icons.chat),
    );
  }
}
