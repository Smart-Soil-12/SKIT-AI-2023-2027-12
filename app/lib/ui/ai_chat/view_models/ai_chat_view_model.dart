import 'package:flutter/material.dart';
import '../../../core/services/ml_engine_service.dart';
import '../../../domain/models/soil_reading.dart';

class ChatMessage {
  final String sender; // 'user' or 'ai'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == 'user';
}

class AiChatViewModel extends ChangeNotifier {
  final MLEngineService _mlEngine;
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  AiChatViewModel({MLEngineService? mlEngine})
      : _mlEngine = mlEngine ?? MLEngineService() {
    _messages.add(
      ChatMessage(
        sender: 'ai',
        text: 'Hello! I am your Smart Soil AI Assistant. Ask me anything about crop diseases, soil fertility, or fertilizer schedules. / नमस्ते! मैं आपका स्मार्ट सॉइल एआई सहायक हूँ।',
      ),
    );
  }

  void sendMessage(String query, {SoilReading? currentSoil}) {
    if (query.trim().isEmpty) return;

    _messages.add(ChatMessage(sender: 'user', text: query));
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      final responseText = currentSoil != null
          ? _mlEngine.generateAgronomicAdvice(query: query, currentSoil: currentSoil)
          : 'Based on live Smart Soil telemetry, your soil conditions are being actively monitored. Maintain adequate irrigation and scheduled fertilization according to your crop calendar.';
      _messages.add(ChatMessage(sender: 'ai', text: responseText));
      notifyListeners();
    });
  }
}
