class Document {
  final String id;
  final String name;
  final String subject;
  final String meta;      // e.g. "24 pages · 1.2 MB"
  final DateTime uploadedAt;

  const Document({
    required this.id,
    required this.name,
    required this.subject,
    required this.meta,
    required this.uploadedAt,
  });

   String get timeAgo {
    final diff = DateTime.now().difference(uploadedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}




// Dummy data for UI testing — replace with Supabase later
final List<Document> dummyDocuments = [
  Document(
    id: '1',
    name: 'DBMS Unit 3 Notes',
    subject: 'DBMS',
    meta: '24 pages · 1.2 MB',
    uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Document(
    id: '2',
    name: 'OS Lecture 7',
    subject: 'OS',
    meta: '18 pages · 890 KB',
    uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Document(
    id: '3',
    name: 'Maths — Integration',
    subject: 'Maths',
    meta: '11 pages · 540 KB',
    uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];