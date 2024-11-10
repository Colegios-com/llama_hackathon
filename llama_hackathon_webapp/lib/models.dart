import 'package:uuid/uuid.dart';

class ConversationModel {
  String? id;
  String workspace;
  String? user;
  List messages = [];
  bool active;
  String? timestamp;

  ConversationModel.empty({required this.workspace})
      : id = const Uuid().v8(),
        user = null,
        messages = [],
        active = true,
        timestamp = null;

  ConversationModel.load({required Map data})
      : id = data['id'],
        workspace = data['workspace'],
        messages = [],
        user = data['user'],
        active = true;

  Map<String, dynamic> serialize() {
    return {
      'id': id,
      'workspace': workspace,
      'user': user,
      'active': active,
      'timestamp': timestamp,
    };
  }
}

class MessageModel {
  String? id;
  String? conversation;
  String sender;
  String? label;
  String raw = '';
  String message = '';
  double? score;
  String? reasoning;
  List followupQuestions = [];

  bool active;
  String? timestamp;

  MessageModel.empty({required this.sender, required this.message})
      : id = const Uuid().v8(),
        score = null,
        reasoning = null,
        active = true,
        timestamp = null;

  MessageModel.load({required Map data})
      : id = data['id'],
        conversation = data['conversation'],
        sender = data['sender'],
        label = data['label'],
        message = data['message'],
        score = data['score'],
        reasoning = data['reasoning'],
        followupQuestions = data['followup_questions'] ?? [],
        active = true;

  Map<String, dynamic> serialize() {
    return {
      'id': id,
      'conversation': conversation,
      'sender': sender,
      'label': label,
      'message': message,
      'answer_score': score,
      'answer_score_reasoning': reasoning,
      'active': active,
      'timestamp': timestamp,
    };
  }
}

class DocumentModel {
  bool private = false;
  String? title;
  String content = '';
  bool synchronizing = false;

  bool editing = false;

  DocumentModel.empty() : title = 'New Document';
}
