// 🔁 Düzenlenmiş TomatoAnalysisScreen.dart (Kütüphane ile aynı resim sistemi)
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:hastalik_analiz/screens/diagnosis_history_screen.dart';
import 'package:hastalik_analiz/data/diagnosis_database.dart';
import 'package:hastalik_analiz/models/diagnosis_model.dart';

class Disease {
  final String name;
  final List<dynamic> symptoms;
  final String cause;
  final List<dynamic> reasons;
  final List<dynamic> effects;
  final List<dynamic> treatment;
  final String period;
  final String category;
  final List<dynamic> medicine;
  final List<dynamic> brand;
  final List<dynamic> usage;
  final List<dynamic> timing;

  Disease({
    required this.name,
    required this.symptoms,
    required this.cause,
    required this.reasons,
    required this.effects,
    required this.treatment,
    required this.period,
    required this.category,
    required this.medicine,
    required this.brand,
    required this.usage,
    required this.timing,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['name'],
      symptoms: json['symptoms'],
      cause: json['cause'],
      reasons: json['reasons'],
      effects: json['effects'],
      treatment: json['treatment'],
      period: json['period'],
      category: json['category'],
      medicine: json['recommended_drug'] ?? [],
      brand: json['recommended_brand'] ?? [],
      usage: json['usage_instructions'] ?? [],
      timing: json['application_timing'] ?? [],
    );
  }
}

final Map<String, String> labelToJsonName = {
  "Bakteriyel Leke (Xanthomonas spp.)": "Bakteriyel Leke (Xanthomonas spp.)",
  "Fusarium Solgunluğu": "Fusarium Solgunluğu",
  "Geç Yaprak Yanıklığı (Phytophthora infestans)": "Geç Yaprak Yanıklığı (Phytophthora infestans)",
  "Cladosporium Yaprak Küfü": "Cladosporium Yaprak Küfü",
  "Septoria Yaprak Lekesi": "Septoria Yaprak Lekesi",
  "Kırmızı Örümcek (Tetranychus urticae)": "Kırmızı Örümcek (Tetranychus urticae)",
  "Alternaria Meyve Lekesi": "Alternaria Meyve Lekesi",
  "Domates Sarı Yaprak Kıvırcıklık Virüsü (TYLCV)": "Domates Sarı Yaprak Kıvırcıklık Virüsü (TYLCV)",
  "Domates Mozaik Virüsü (ToMV)": "Domates Mozaik Virüsü (ToMV)",
  "Sağlıklı": "Sağlıklı",
};

final Map<String, String> imageFolderMap = {
  "Geç Yaprak Yanıklığı (Phytophthora infestans)": "Late_blight",
  "Erken Yaprak Yanıklığı (Alternaria solani)": "Early_blight",
  "Fusarium Solgunluğu": "Early_blight",
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

Future<Disease?> fetchDiseaseDetails(String label) async {
  final mappedName = labelToJsonName[label];
  if (mappedName == null) return null;

  final data = await rootBundle.loadString('assets/data/domates_hastaliklari_professional_final.json');
  final List<dynamic> jsonList = json.decode(data);

  for (var item in jsonList) {
    if (item['name'].toString().toLowerCase() == mappedName.toLowerCase()) {
      return Disease.fromJson(item);
    }
  }

  return null;
}

class TomatoAnalysisScreen extends StatefulWidget {
  const TomatoAnalysisScreen({super.key});

  @override
  State<TomatoAnalysisScreen> createState() => _TomatoAnalysisScreenState();
}

class _TomatoAnalysisScreenState extends State<TomatoAnalysisScreen> {
  File? _imageFile;
  Interpreter? _model;
  Interpreter? _leafModel;
  String? _result;
  double? _confidence;
  Disease? _disease;
  bool _isLeaf = false;
  bool _leafChecked = false;

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  Future<void> loadModels() async {
    _model = await Interpreter.fromAsset("assets/tomato_analysis.tflite");
    _leafModel = await Interpreter.fromAsset("assets/leafgate_model.tflite");
  }

  void _reset() {
    setState(() {
      _result = null;
      _confidence = null;
      _disease = null;
      _leafChecked = false;
      _isLeaf = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      _imageFile = File(picked.path);
      _reset();
      await _checkLeaf(_imageFile!);
    }
  }

  Future<void> _checkLeaf(File file) async {
    final image = img.decodeImage(await file.readAsBytes());
    final resized = img.copyResize(image!, width: 224, height: 224);
    final input = List.generate(1, (_) => List.generate(224, (y) => List.generate(224, (x) {
      final pixel = resized.getPixel(x, y);
      return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
    })));
    final output = List.filled(1, 0.0).reshape([1, 1]);
    _leafModel?.run(input, output);
    setState(() {
      _isLeaf = output[0][0] < 0.5;
      _leafChecked = true;
    });
  }

  Future<void> _analyse() async {
    if (_imageFile == null) return;
    final image = img.decodeImage(await _imageFile!.readAsBytes());
    final resized = img.copyResize(image!, width: 224, height: 224);
    final input = List.generate(1, (_) => List.generate(224, (y) => List.generate(224, (x) {
      final pixel = resized.getPixel(x, y);
      return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
    })));
    final output = [List.filled(10, 0.0)];
    _model?.run(input, output);
    final scores = output[0];
    final maxIndex = scores.indexWhere((e) => e == scores.reduce((a, b) => a > b ? a : b));
    final label = labelToJsonName.keys.toList()[maxIndex];

    setState(() {
      _result = label;
      _confidence = scores[maxIndex];
    });

    _disease = await fetchDiseaseDetails(label);
    await _saveToDatabase(label);
  }

  Future<void> _saveToDatabase(String label) async {
    if (_imageFile == null) return;
    final bytes = await _imageFile!.readAsBytes();
    final encodedImage = base64Encode(bytes);
    final diagnosis = Diagnosis(
      label: label,
      confidence: _confidence ?? 0,
      timestamp: DateTime.now().toIso8601String(),
      imageBase64: encodedImage,
    );
    await DiagnosisDatabase.instance.insertDiagnosis(diagnosis);
  }

  Widget _buildInfoSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...items.map((e) => Text("• $e", style: const TextStyle(fontSize: 14))),
        const SizedBox(height: 12),
      ],
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

  Widget _buildDiagnosisSummary() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🧠 Tahmin Edilen Hastalık:", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              _result ?? "Bilinmiyor",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            if (_confidence != null)
              LinearProgressIndicator(
                value: _confidence!.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                color: _confidence! >= 0.7 ? Colors.green : Colors.red,
                minHeight: 8,
              ),
            const SizedBox(height: 6),
            if (_confidence != null)
              Text("Güven Skoru: %${(_confidence! * 100).toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/images/wallpaper/arka_analiz.jpg", fit: BoxFit.cover)),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: const Text("Domates Analiz")),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
                    )
                  else
                    const Text("Bir fotoğraf seçiniz."),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: () => _pickImage(ImageSource.camera), child: const Text("📷 Fotoğraf Çek")),
                      const SizedBox(width: 12),
                      ElevatedButton(onPressed: () => _pickImage(ImageSource.gallery), child: const Text("🖼️ Galeriden Seç")),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_imageFile != null && _leafChecked && _isLeaf)
                    ElevatedButton(onPressed: _analyse, child: const Text("🔍 Analiz Et")),
                  if (_imageFile != null && _leafChecked && !_isLeaf)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Text(
                        "⚠️ Yüklenen görsel domates yaprağına benzemiyor.",
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_result != null && _disease != null) ...[
                    _buildDiagnosisSummary(),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.green.shade50,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageGrid(_result!),
                            _buildInfoSection("🔍 Belirtiler", _disease!.symptoms),
                            _buildInfoSection("📌 Sebep", [_disease!.cause]),
                            _buildInfoSection("🚫 Nedenleri", _disease!.reasons),
                            _buildInfoSection("⚠️ Etkiler", _disease!.effects),
                            _buildInfoSection("🛠 Tedavi", _disease!.treatment),
                            _buildInfoSection("📅 Görülme Dönemi", [_disease!.period]),
                            _buildInfoSection("💊 İlaç", _disease!.medicine),
                            _buildInfoSection("🏷 Marka", _disease!.brand),
                            _buildInfoSection("🔄 Uygulama", _disease!.usage),
                            _buildInfoSection("⏰ Zamanlama", _disease!.timing),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.history),
                label: const Text("Teşhis Geçmişini Görüntüle"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosisHistoryScreen()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
