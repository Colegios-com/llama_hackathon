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
  late WebSocketChannel channel;

  // Document Stuff
  ConversationModel? conversation;
  List<MessageModel> messages = [
    MessageModel.empty(
      sender: 'system',
      message: 'Hello! How can I help you today?',
    ),
  ];

  Future scrapeData({required String url}) async {
    Map<String, dynamic> body = {'url': url};
    try {
      String data = await ApiService.post('scrape/',
          service: 'bot', body: body, responseCode: 200);
      if (data.isNotEmpty) {
        print('Data: $data');
        return data;
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future addMessage({required Map messageData}) async {
    MessageModel message = MessageModel.load(data: messageData);
    messages.add(message);

    notifyListeners();
  }

  Future createConversation({required String workspace}) async {
    conversation = ConversationModel.empty(workspace: workspace);
    Map<String, dynamic> body = conversation!.serialize();
    try {
      Map conversationData = await ApiService.post('conversations/',
          service: 'api', body: body, responseCode: 201);
      if (conversationData.isNotEmpty) {
        conversation = ConversationModel.load(data: conversationData);
        return true;
      }
    } catch (error) {
      print('Error: $error');
    }
    conversation = null;
    return false;
  }

  Future createMessage({required Map<String, dynamic> body}) async {
    try {
      Map messageData = await ApiService.post('messages/',
          service: 'api', body: body, responseCode: 201);
      if (messageData.isNotEmpty) {
        return messageData;
      }
    } catch (error) {
      print('Error: $error');
    }
    return false;
  }

  Future askQuestion({
    required String query,
    required Map context,
    required String workspaceId,
  }) async {
    List filteredMessages = messages
        .where((message) => message.sender != 'system')
        .map((message) => message.message)
        .toList();

    List history = filteredMessages.reversed.take(6).toList();
    if (history.isNotEmpty) {
      history.removeAt(0);
    }

    Map<String, dynamic> body = {
      'context': context,
      'workspace': workspaceId,
      'query': query,
      'history': history,
    };

    connectToWebSocket();
    channel.sink.add(json.encode(body));
  }

  Future sendMessage({
    required Map context,
    required String workspaceId,
    required String message,
  }) async {
    if (conversation == null) {
      await createConversation(workspace: workspaceId);
    }

    Map userMessage = await createMessage(body: {
      'conversation': conversation!.id,
      'sender': 'User',
      'message': message
    });
    await addMessage(messageData: userMessage);

    askQuestion(query: message, context: context, workspaceId: workspaceId);
  }

  void connectToWebSocket() {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://0.0.0.0/ask/'),
      );

      channel.stream.listen(
        (payload) {
          handleWebSocketMessage(payload);
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

  void handleWebSocketMessage(String payload) async {
    MessageModel currentMessage = messages.last;
    if (currentMessage.sender == 'User') {
      addMessage(messageData: {
        'conversation': conversation!.id,
        'sender': 'Agent',
        'message': '',
      });
    } else {
      if (payload.contains('END_OF_RESPONSE')) {
        await createMessage(body: {
          'conversation': conversation!.id,
          'sender': 'Agent',
          'label': currentMessage.label,
          'message': currentMessage.message,
          'score': currentMessage.score,
          'reasoning': currentMessage.reasoning,
        });
      } else {
        currentMessage.raw += payload;
        // Parsing Function
        String? extractedAnswer =
            extractBetweenTags(currentMessage.raw, 'ANSWER');
        if (extractedAnswer != null) {
          currentMessage.message = extractedAnswer;
        }
        String? extractedLabel =
            extractBetweenTags(currentMessage.raw, 'LABEL');
        if (extractedLabel != null) {
          currentMessage.label = extractedLabel;
        }
        String? extractedScore =
            extractBetweenTags(currentMessage.raw, 'ANSWER_SCORE');
        if (extractedScore != null) {
          currentMessage.score = double.parse(extractedScore);
        }
        String? extractedReasoning =
            extractBetweenTags(currentMessage.raw, 'ANSWER_SCORE_REASONING');
        if (extractedReasoning != null) {
          currentMessage.reasoning = extractedReasoning;
        }
        List followUpQuestions =
            extractAllBetweenTags(currentMessage.raw, 'FOLLOW_UP_QUESTION');
        if (followUpQuestions.isNotEmpty) {
          currentMessage.followupQuestions = followUpQuestions;
        }
      }
    }
    notifyListeners();
  }

  String? extractBetweenTags(String text, String tag) {
    RegExp regex;
    if (tag == 'ANSWER') {
      regex = RegExp('<$tag>(.*?)</$tag>', dotAll: true);
      if (!regex.hasMatch(text)) {
        regex = RegExp('<$tag>(.*)', dotAll: true);
      }
    } else {
      regex = RegExp('<$tag>(.*?)</$tag>', dotAll: true);
    }
    final Match? match = regex.firstMatch(text);
    return match?.group(1);
  }

  List<String> extractAllBetweenTags(String text, String tag) {
    final RegExp regex = RegExp('<$tag>(.*?)</$tag>', dotAll: true);
    return regex.allMatches(text).map((match) => match.group(1)!).toList();
  }
}
