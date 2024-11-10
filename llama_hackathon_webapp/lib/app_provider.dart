import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

// Packages
import 'package:web_socket_channel/web_socket_channel.dart';

// Models
import 'package:llama_hackathon_webapp/models.dart';

// Utilities
import 'api_controller.dart';

class AppProvider extends ChangeNotifier {
  // Variables
  late WebSocketChannel _channel;

  // Document Data
  DocumentModel document = DocumentModel.empty();

  // Message Data
  ConversationModel? conversation;
  List<MessageModel> messages = [
    MessageModel.empty(
      sender: 'system',
      message:
          'Hola! Soy Llamar, tu asistente académico virtual. \n\nPuedes preguntarme cualquier cosa sobre el CNB, o incluso pedirme que valide un documento academico.',
    ),
  ];

  // Initialize WebSocket
  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        // Uri.parse('ws://0.0.0.0/channel/'),
        Uri.parse('wss://sea-turtle-app-3zj6d.ondigitalocean.app/channel/'),
      );

      _channel.stream.listen(
        (payload) {
          _handleWebSocketMessage(payload);
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  // Generate Document
  Future<void> generateDocument(
      {required String instruction, String? image}) async {
    _connectWebSocket();
    Map<String, dynamic> body = {
      'action': 'generate_document',
      'instruction': instruction,
      'image': image,
    };
    _channel.sink.add(json.encode(body));
  }

  // Send Message
  Future<void> sendMessage({
    required Map context,
    required String workspaceId,
    required String message,
    String? fileText,
  }) async {
    if (conversation == null) {
      await _createConversation(workspace: workspaceId);
    }

    Map userMessage = await _createMessage(body: {
      'conversation': conversation!.id,
      'sender': 'User',
      'message': message
    });
    await _addMessage(messageData: userMessage);

    await _askQuestion(
      workspaceId: workspaceId,
      query: message,
      context: context,
      fileText: fileText,
    );
  }

  // Private Methods

  void _handleWebSocketMessage(String payload) async {
    Map<String, dynamic> data = json.decode(payload);

    if (data['action'] == 'generate_document') {
      _handleDocumentMessage(data);
    } else if (data['action'] == 'ask_question') {
      await _handleAskMessage(data);
    }

    notifyListeners();
  }

  void _handleDocumentMessage(Map<String, dynamic> data) {
    if (data['status'] == 'END_OF_RESPONSE') {
      _channel.sink.close();
    } else {
      document.content += data['content'] ?? '';
    }
  }

  Future<void> _handleAskMessage(Map<String, dynamic> data) async {
    MessageModel currentMessage = messages.last;
    if (currentMessage.sender == 'User') {
      await _addMessage(messageData: {
        'conversation': conversation!.id,
        'sender': 'Agent',
        'message': '',
      });
    } else {
      if (data['status'] == 'END_OF_RESPONSE') {
        await _createMessage(body: {
          'conversation': conversation!.id,
          'sender': 'Agent',
          'label': currentMessage.label,
          'message': currentMessage.message,
          'score': currentMessage.score,
          'reasoning': currentMessage.reasoning,
        });
      } else {
        currentMessage.raw += data['content'] ?? '';
        _parseMessageContent(currentMessage);
      }
    }
  }

  Future<void> _askQuestion({
    required String workspaceId,
    required String query,
    required Map context,
    String? fileText,
  }) async {
    List<String> filteredMessages = messages
        .where((message) => message.sender != 'system')
        .map((message) => message.message)
        .toList();

    List<String> history = filteredMessages.reversed.take(6).toList();
    if (history.isNotEmpty) {
      history.removeAt(0);
    }

    Map<String, dynamic> body = {
      'action': 'ask_question',
      'workspace': workspaceId,
      'history': history,
      'query': query,
      'context': context,
      'document_text': fileText,
    };

    _connectWebSocket();
    _channel.sink.add(json.encode(body));
  }

  void _parseMessageContent(MessageModel currentMessage) {
    // Parsing Function
    String rawContent = currentMessage.raw;

    String? extractedAnswer = _extractBetweenTags(rawContent, 'ANSWER');
    if (extractedAnswer != null) {
      currentMessage.message = extractedAnswer;
    }
    String? extractedLabel = _extractBetweenTags(rawContent, 'LABEL');
    if (extractedLabel != null) {
      currentMessage.label = extractedLabel;
    }
    String? extractedScore = _extractBetweenTags(rawContent, 'ANSWER_SCORE');
    if (extractedScore != null) {
      currentMessage.score = double.tryParse(extractedScore) ?? 0.0;
    }
    String? extractedReasoning =
        _extractBetweenTags(rawContent, 'ANSWER_SCORE_REASONING');
    if (extractedReasoning != null) {
      currentMessage.reasoning = extractedReasoning;
    }
    List<String> followUpQuestions =
        _extractAllBetweenTags(rawContent, 'FOLLOW_UP_QUESTION');
    if (followUpQuestions.isNotEmpty) {
      currentMessage.followupQuestions = followUpQuestions;
    }
  }

  Future<void> _addMessage({required Map messageData}) async {
    MessageModel message = MessageModel.load(data: messageData);
    messages.add(message);
  }

  Future<void> _createConversation({required String workspace}) async {
    conversation = ConversationModel.empty(workspace: workspace);
    Map<String, dynamic> body = conversation!.serialize();
    try {
      Map conversationData = await ApiService.post('conversations/',
          service: 'api', body: body, responseCode: 201);
      if (conversationData.isNotEmpty) {
        conversation = ConversationModel.load(data: conversationData);
      } else {
        conversation = null;
      }
    } catch (error) {
      print('Error: $error');
      conversation = null;
    }
  }

  Future<Map> _createMessage({required Map<String, dynamic> body}) async {
    try {
      Map messageData = await ApiService.post('messages/',
          service: 'api', body: body, responseCode: 201);
      if (messageData.isNotEmpty) {
        return messageData;
      }
    } catch (error) {
      print('Error: $error');
    }
    return {};
  }

  String? _extractBetweenTags(String text, String tag) {
    RegExp regex;
    if (tag == 'ANSWER') {
      regex = RegExp('<$tag>(.*?)</$tag>', dotAll: true);
      if (!regex.hasMatch(text)) {
        regex = RegExp('<$tag>(.*)', dotAll: true);
      }
    } else {
      regex = RegExp('<$tag>(.*?)</$tag>', dotAll: true);
    }
    final match = regex.firstMatch(text);
    return match?.group(1);
  }

  List<String> _extractAllBetweenTags(String text, String tag) {
    final regex = RegExp('<$tag>(.*?)</$tag>', dotAll: true);
    return regex.allMatches(text).map((match) => match.group(1)!).toList();
  }
}
