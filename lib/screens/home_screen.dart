import 'package:flutter/material.dart';
import 'package:hastalik_analiz/screens/tomato_analysis_screen.dart';
import 'package:hastalik_analiz/screens/bert_chat_screen.dart';
import 'package:hastalik_analiz/screens/library_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Domates Teşhis Paneli'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuCard(
              context,
              icon: Icons.camera_alt,
              label: '🍅 Domates Analiz',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TomatoAnalysisScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.chat,
              label: '💬 BERT Chat Teşhis',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BertChatScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.menu_book,
              label: '📚 Hastalık Kütüphanesi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LibraryScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.green),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
