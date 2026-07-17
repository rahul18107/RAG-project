import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/chat_screen.dart';
import 'widgets/home/bottom_navigation_bar.dart';
import 'screens/flashcards_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'package:provider/provider.dart';
import 'providers/document_provider.dart';


  


class StudyMindApp extends StatelessWidget {
  const StudyMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}

// shows LoginScreen when logged out, the app when logged in
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.onAuthStateChange,
      builder: (context, snapshot) {
        if (AuthService.isLoggedIn) {
  return ChangeNotifierProvider(
    create: (_) => DocumentProvider()..loadDocs(),
    child: const MainShell(),
  );
}
return const LoginScreen();

      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    UploadScreen(),
    ChatScreen(),
    FlashcardsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseKey,
  );
  runApp(const StudyMindApp());

}