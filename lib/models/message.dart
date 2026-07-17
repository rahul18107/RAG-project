class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime sentAt;
  final String? sourceRef; // e.g. "Unit 3, page 4"

  const Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.sentAt,
    this.sourceRef,
  });
}