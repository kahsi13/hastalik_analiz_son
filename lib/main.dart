import 'package:flutter/material.dart';
import 'package:hastalik_analiz/theme/app_theme.dart';
import 'package:hastalik_analiz/screens/home_screen.dart';
import 'package:hastalik_analiz/screens/tomato_analysis_screen.dart';
import 'package:hastalik_analiz/screens/library_screen.dart';
import 'package:hastalik_analiz/screens/bert_chat_screen.dart';

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
      theme: AppTheme.lightTheme, // 🔄 Temayı uyguluyoruz
      home: const MainNavigation(),
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
      bottomNavigationBar: NavigationBar(
        height: 65,
        selectedIndex: _selectedIndex,
        indicatorColor: Colors.green.withOpacity(0.1),
        surfaceTintColor: Colors.white,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Analiz'),
          NavigationDestination(icon: Icon(Icons.library_books), label: 'Kütüphane'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Sohbet'),
        ],
      ),
    );
  }
}
