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
  // content =
  //     '# Descubre Aldous: Tu Asistente Inteligente de Documentos\n\n## ¿Qué es Aldous?\n\nAldous es tu aliado digital que combina:\n- Un potente editor de documentos\n- Un asistente inteligente siempre listo para ayudarte\n\n## Saca el Máximo Provecho de Aldous\n\n### 1. Crea Documentos Poderosos\n\n- Sé Detallista: Cuanta más información, mejor te ayudará Aldous\n- Organiza con Inteligencia: Usa estructuras claras y encabezados\n- Mantén Todo Fresco: Actualiza regularmente, especialmente proyectos en curso\n- Diversifica: Incluye texto, tablas, listas y enlaces\n- Sé Tú Mismo: Escribe en tu estilo, Aldous se adapta\n\n### 2. Interactúa con Aldous\n\nPregunta a Aldous sobre cualquier cosa en tus documentos:\n\n- "Aldous, ¿cuáles fueron los puntos clave de la última reunión?"\n- "Resumen del informe financiero del Q2, por favor"\n- "¿Cómo se conecta nuestra estrategia de marketing con las ventas?"\n- "Explica el nuevo proceso de desarrollo de productos"\n\n## Beneficios Clave\n\n1. Ahorra Tiempo: Encuentra información al instante\n2. Obtén Claridad: Entiende mejor tus propios documentos\n3. Descubre Conexiones: Ve relaciones que podrías haber pasado por alto\n4. Toma Mejores Decisiones: Con toda la información a tu alcance\n\nConsejo Pro: Cuanto más escribas y actualices, más poderoso se vuelve Aldous. ¡Es como tener un asistente que mejora cada día!\n\n¿Listo para revolucionar tu forma de trabajar con documentos? ¡Empieza a usar Aldous hoy!';
}
