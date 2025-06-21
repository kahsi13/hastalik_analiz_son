import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allDiseases = [];
  String _searchQuery = "";
  Set<int> _expandedIndexes = {};

  final Map<String, String> imageFolderMap = {
    "Geç Yaprak Yanıklığı (Phytophthora infestans)": "Late_blight",
    "Erken Yaprak Yanıklığı (Alternaria solani)": "Early_blight",
    "Fusarium Solgunluğu": "Fusarium",
    "Verticillium Solgunluğu": "Verticillium",
    "Septoria Yaprak Lekesi": "Septoria_leaf_spot",
    "Cladosporium Yaprak Küfü": "Leaf_Mold",
    "Alternaria Meyve Lekesi": "Target_Spot",
    "Bakteriyel Leke (Xanthomonas spp.)": "Bacterial_spot",
    "Domates Mozaik Virüsü (ToMV)": "Tomato_mosaic_virus",
    "Domates Sarı Yaprak Kıvırcıklık Virüsü (TYLCV)": "Tomato_Yellow_Leaf_Curl_Virus",
    "Kırmızı Örümcek (Tetranychus urticae)": "Spider_mites_Two_spotted_spider_mite",
    "Sağlıklı": "Healthy",
  };

  @override
  void initState() {
    super.initState();
    _loadDiseaseData();
  }

  Future<void> _loadDiseaseData() async {
    final String response = await rootBundle.loadString(
        'assets/data/domates_hastaliklari_professional_final.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      allDiseases = data.cast<Map<String, dynamic>>();
    });
  }

  List<Map<String, dynamic>> get _filteredDiseases {
    final lowerQuery = _searchQuery.toLowerCase();
    return allDiseases.where((disease) {
      return disease['name'].toString().toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Map<String, dynamic>> _getDiseasesByCategory(String category) {
    return _filteredDiseases.where((d) => d['category'] == category).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Mantar Hastalıkları":
        return Colors.green.shade100;
      case "Bakteriyel Hastalıklar":
        return Colors.red.shade100;
      case "Viral Hastalıklar":
        return Colors.yellow.shade100;
      case "Fizyolojik Bozukluklar":
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
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
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/wallpaper/arka_kutuphane.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Hastalık adı girin',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
              isExpanded
                  ? _expandedIndexes.remove(index)
                  : _expandedIndexes.add(index);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(d['category']),
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
                Text(
                  d['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildImageGrid(d['name']),
                      _buildMarkdownSection("🔍 Belirtiler", d['symptoms']),
                      _buildMarkdownSection("📌 Sebep", d['cause']),
                      _buildMarkdownSection("🚫 Nedenleri", d['reasons']),
                      _buildMarkdownSection("⚠️ Etkiler", d['effects']),
                      _buildMarkdownSection("💪 Tedavi", d['treatment']),
                      _buildMarkdownSection("🗕 Görülme Dönemi", d['period']),
                      _buildMarkdownSection("💊 İlaç", d['recommended_drug']),
                      _buildMarkdownSection("🏷 Marka", d['recommended_brand']),
                      _buildMarkdownSection("🔄 Uygulama", d['usage_instructions']),
                      _buildMarkdownSection("⏰ Zamanlama", d['application_timing']),
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(String name) {
    final folder = imageFolderMap[name];
    if (folder == null) return const SizedBox.shrink();

    final List<String> extensions = ['jpg', 'JPG'];
    final List<String> imagePaths = [
      for (var ext in extensions) 'assets/images/$folder/1.$ext',
      for (var ext in extensions) 'assets/images/$folder/2.$ext',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: imagePaths.map((path) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              path,
              width: MediaQuery.of(context).size.width * 0.42,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMarkdownSection(String title, dynamic content) {
    final List<String> items = content is List
        ? List<String>.from(content)
        : [content.toString()];

    if (items.every((e) => e.trim().toLowerCase() == "n/a")) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...items.map((e) => MarkdownBody(data: "- $e")),
        ],
      ),
    );
  }
}
