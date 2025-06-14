import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BertChatScreen extends StatefulWidget {
  const BertChatScreen({super.key});

  @override
  State<BertChatScreen> createState() => _BertChatScreenState();
}

class _BertChatScreenState extends State<BertChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool isLoading = false;

  Future<void> predictDisease(String text) async {
    setState(() => isLoading = true);

    final url = Uri.parse("https://tomato-disease-bert-10.onrender.com/predict");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"text": text}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final label = decoded["label"];
        final confidence = decoded["confidence"];
        final description = decoded["description"] ?? "Açıklama bulunamadı.";
        final warning = decoded["warning"];

        setState(() {
          _messages.add({"text": text, "isUser": true});
          _messages.add({
            "text": "🧠 Tahmin: $label"
                "\n📈 Güven Skoru: ${confidence.toStringAsFixed(2)}"
                "\n📋 Açıklama: $description"
                "${warning != null ? "\n⚠️ Uyarı: $warning" : ""}",
            "isUser": false,
          });
        });
      } else {
        setState(() {
          _messages.add({"text": "Tahmin başarısız: ${response.statusCode}", "isUser": false});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"text": "Tahmin sırasında hata oluştu: $e", "isUser": false});
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BERT Chat Teşhis Asistanı")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg['text'], msg['isUser']);
              },
            ),
          ),
          if (isLoading) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Belirtileri yazın...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final input = _controller.text.trim();
                    if (input.isNotEmpty) {
                      predictDisease(input);
                      _controller.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Colors.green,
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
