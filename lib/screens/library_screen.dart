// 🧾 Geliştirilmiş LibraryScreen.dart (Kategori, Arama, Estetik Kartlar)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allDiseases = [];
  String _searchQuery = "";
  Set<int> _expandedIndexes = {}; // Expanded card indices

  @override
  void initState() {
    super.initState();
    _loadDiseaseData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiseaseData() async {
    final String response = await rootBundle.loadString('assets/data/domates_hastaliklari_detayli.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      allDiseases = data.cast<Map<String, dynamic>>();
    });
  }

  List<Map<String, dynamic>> get _filteredDiseases {
    return allDiseases.where((disease) {
      return disease['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> _getDiseasesByCategory(String category) {
    return _filteredDiseases.where((d) => d['category'] == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Domates Hastalık Kütüphanesi"),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Mantar Hastalıkları"),
              Tab(text: "Bakteriyel Hastalıklar"),
              Tab(text: "Viral Hastalıklar"),
              Tab(text: "Fizyolojik Bozukluklar"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Hastalık ismi girin...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDiseaseList(_getDiseasesByCategory("Mantar Hastalıkları")),
                  _buildDiseaseList(_getDiseasesByCategory("Bakteriyel Hastalıklar")),
                  _buildDiseaseList(_getDiseasesByCategory("Viral Hastalıklar")),
                  _buildDiseaseList(_getDiseasesByCategory("Fizyolojik Bozukluklar")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseList(List<Map<String, dynamic>> diseases) {
    return ListView.builder(
      itemCount: diseases.length,
      itemBuilder: (context, index) {
        final d = diseases[index];
        final isExpanded = _expandedIndexes.contains(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedIndexes.remove(index);
              } else {
                _expandedIndexes.add(index);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildInfoSection("🔍 Belirtiler", d['symptoms']),
                      _buildInfoSection("📌 Sebep", d['cause']),
                      _buildInfoSection("🚫 Nedenleri", d['reasons']),
                      _buildInfoSection("⚠️ Etkileri", d['effects']),
                      _buildInfoSection("🛠 Tedavi", d['treatment']),
                      _buildInfoSection("📅 Görülme Dönemi", d['period']),
                    ],
                  ),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, dynamic content) {
    final List<String> items = content is List ? List<String>.from(content) : [content.toString()];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...items.map((e) => Text("• $e", style: const TextStyle(fontSize: 14))).toList(),
        ],
      ),
    );
  }
}