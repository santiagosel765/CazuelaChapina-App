import 'package:flutter/foundation.dart';

enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String content;

  const ChatMessage({required this.role, required this.content});
}

