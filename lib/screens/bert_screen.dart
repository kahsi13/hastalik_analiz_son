/// Domates hastalık analizi için kullanıcıdan alınan metni
/// uzak bir FastAPI sunucusuna göndererek tahmin sonucunu gösteren ekran.
/// API yanıtı olarak gelen 'prediction' verisi gösterilir.
/// Bu ekran internet üzerinden .onnx modeline erişir, cihazda çalışmaz.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BertScreen extends StatefulWidget {
  const BertScreen({Key? key}) : super(key: key);

  @override
  State<BertScreen> createState() => _BertScreenState();
}

class _BertScreenState extends State<BertScreen> {
  final TextEditingController _controller = TextEditingController();
  String _sonuc = '';
  bool _isLoading = false;

  Future<void> _tahminYap() async {
    final String metin = _controller.text.trim();
    if (metin.isEmpty) return;

    setState(() {
      _isLoading = true;
      _sonuc = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://web-production-7579.up.railway.app/predict'), // 🌐 FastAPI URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': metin}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _sonuc = json['prediction'].toString(); // ✅ Her zaman string olacak şekilde dönüştürüldü
        });
      } else {
        setState(() {
          _sonuc = 'Sunucu hatası: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _sonuc = 'İstek hatası: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Domates Hastalık Tahmini (API)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "Hastalık belirtisi yazın"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _tahminYap,
              child: const Text("Tahmin Yap"),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
              _sonuc,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
