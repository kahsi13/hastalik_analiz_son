import 'package:flutter/material.dart';
import 'package:hastalik_analiz/theme/app_theme.dart';
import 'package:hastalik_analiz/screens/home_screen.dart';
import 'package:hastalik_analiz/screens/tomato_analysis_screen.dart';
import 'package:hastalik_analiz/screens/library_screen.dart';
import 'package:hastalik_analiz/screens/bert_chat_screen.dart';
import 'package:hastalik_analiz/screens/welcome_screen.dart'; // 👈 yeni ekran import edildi

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hastalık Analiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(), // 👈 başlangıçta WelcomeScreen açılır
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TomatoAnalysisScreen(),
    LibraryScreen(),
    BertChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
    );
  }
}
