import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String baseUrl;
  final String token;

  // Store conversation history
  final List<Map<String, String>> _conversationHistory = [];

  AIService({required this.baseUrl, required this.token});

  /// Send a message to the AI and get a response
  Future<AIResponse> sendMessage(String message) async {
    try {
      // Add user message to history
      _conversationHistory.add({'role': 'user', 'content': message});

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final aiContent = data['data']['content'] ?? '';

          // Add AI response to history
          _conversationHistory.add({'role': 'bot', 'content': aiContent});

          return AIResponse(
            success: true,
            content: aiContent,
            sender: data['data']['sender'] ?? 'bot',
          );
        } else {
          return AIResponse(
            success: false,
            content: 'Failed to get response',
            error: data['message'] ?? 'Unknown error',
          );
        }
      } else {
        return AIResponse(
          success: false,
          content: 'Server error',
          error: 'Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AIResponse(
        success: false,
        content: 'Connection error',
        error: e.toString(),
      );
    }
  }

  /// Get conversation history
  List<Map<String, String>> getHistory() {
    return List.unmodifiable(_conversationHistory);
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }

  /// Get conversation history count
  int getHistoryCount() {
    return _conversationHistory.length;
  }
}

/// AI Response provider
class AIResponse {
  final bool success;
  final String content;
  final String? sender;
  final String? error;

  AIResponse({
    required this.success,
    required this.content,
    this.sender,
    this.error,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      success: json['success'] ?? false,
      content: json['data']?['content'] ?? '',
      sender: json['data']?['sender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'content': content,
      'sender': sender,
      'error': error,
    };
  }
}
