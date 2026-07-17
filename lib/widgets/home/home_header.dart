import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/document_provider.dart';
import '../../screens/login_screen.dart';
import '../../screens/search_screen.dart';
import '../../services/auth_service.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  void _handleAccountTap() async {
    if (AuthService.isLoggedIn) {
      // already logged in — offer logout
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Log out?',
              style: AppTextStyles.cardTitle),
          content: Text(
            AuthService.currentUser?.email ?? '',
            style: AppTextStyles.cardMeta,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Log out',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (shouldLogout == true) {
        await AuthService.signOut();
        if (mounted) setState(() {});
      }
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (mounted) setState(() {});
    }
  }

  String get _userName {
    final user = AuthService.currentUser;
    return user?.userMetadata?['name'] ??
        user?.email?.split('@').first ??
        'there';
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.isLoggedIn;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello,',
                    style: AppTextStyles.greeting),
                const SizedBox(height: 4),
                Text('$_userName 👋',
                    style: AppTextStyles.screenTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final docs = context
                  .read<DocumentProvider>()
                  .docs;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      SearchScreen(documents: docs),
                ),
              );
            },
            child: Container(
              width: 46, height: 46,
              decoration: const BoxDecoration(
                color: AppColors.cardDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search,
                  color: AppColors.card, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleAccountTap,
            child: Container(
              width: 46, height: 46,
              decoration: const BoxDecoration(
                color: AppColors.cardDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLoggedIn ? Icons.person : Icons.login,
                color: AppColors.card, size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
