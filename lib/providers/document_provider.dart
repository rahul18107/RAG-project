import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/document_service.dart';

class DocumentProvider extends ChangeNotifier {
  List<Document> _docs = [];
  int _chatsCount=0;
  int _cardsCount = 0;

  List<Document> get docs => _docs;
  int get chatsCount => _chatsCount;
  int get cardsCount => _cardsCount;

  Future<void> loadDocs() async {
    final results = await Future.wait([
      DocumentService.fetchAll(),
      DocumentService.fetchChatsCount(),
      DocumentService.fetchFlashcardsCount(),
    ]);

    _docs = results[0] as List<Document>;
    _chatsCount = results[1] as int;
    _cardsCount = results[2] as int;
    notifyListeners();
  }

  Future<void> deleteDoc(String id) async {
    await DocumentService.delete(id);
    _docs.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Future<void> addDoc(Document doc) async {
    _docs.insert(0, doc);
    notifyListeners();
  }
}