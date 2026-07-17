import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';

import '../widgets/home/home_header.dart';
import '../widgets/home/home_stats_row.dart';
import '../widgets/home/home_recent_docs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final docs = context.watch<DocumentProvider>().docs;
    final chats = context.watch<DocumentProvider>().chatsCount;
    final cards = context.watch<DocumentProvider>().cardsCount;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F0), // ← add this
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              HomeStatsRow(
                subjects: docs.map((d) => d.subject).toSet().length,
                docs: docs.length,
                chats: chats,
                cards: cards,
              ),
              HomeRecentDocs(documents: docs.take(3).toList()),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      
    );
  }
}