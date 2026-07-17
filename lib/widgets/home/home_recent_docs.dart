import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/document.dart';
import 'document_card.dart';

class HomeRecentDocs extends StatelessWidget {
  final List<Document> documents;

  const HomeRecentDocs({super.key, required this.documents});


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
          child: Text('RECENT DOCUMENTS',
              style: AppTextStyles.sectionLabel),
        ),
        ...documents.asMap().entries.map((e) => DocumentCard(
              document: e.value,
              isActive: e.key == 0,
          onTap: () {},

            )),
      ],
    );
  }
}