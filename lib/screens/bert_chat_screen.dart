import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class BertChatScreen extends StatefulWidget {
  const BertChatScreen({Key? key}) : super(key: key);

  @override
  State<BertChatScreen> createState() => _BertChatScreenState();
}

class _BertChatScreenState extends State<BertChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool isLoading = false;
  bool _isTyping = false;

  List<Map<String, dynamic>> allDiseases = [];

  final Map<String, String> imageFolderMap = {
    "Geç Yaprak Yanıklığı (Phytophthora infestans)": "Late_blight",
    "Erken Yaprak Yanıklığı (Alternaria solani)": "Early_blight",
    "Septoria Yaprak Lekesi": "Septoria_leaf_spot",
    "Cladosporium Yaprak Küfü": "Leaf_Mold",
    "Alternaria Meyve Lekesi": "Target_Spot",
    "Bakteriyel Leke (Xanthomonas spp.)": "Bacterial_spot",
    "Domates Mozaik Virüsü (ToMV)": "Tomato_mosaic_virus",
    "Domates Sarı Yaprak Kıvırcıklık Virüsü (TYLCV)": "Tomato_Yellow_Leaf_Curl_Virus",
    "Kırmızı Örümcek (Tetranychus urticae)": "Spider_mites Two-spotted_spider_mite",
    "Sağlıklı": "Healthy",
  };

  final List<String> _greetingKeywords = ['selam', 'merhaba', 'sa', 'slm', 'hi', 'hello'];

  @override
  void initState() {
    super.initState();
    _loadDiseaseLibrary();
  }

  Future<void> _loadDiseaseLibrary() async {
    final String response = await rootBundle.loadString(
      'assets/data/domates_hastaliklari_professional_final.json',
    );
    final List<dynamic> data = json.decode(response);
    setState(() {
      allDiseases = data.cast<Map<String, dynamic>>();
    });
  }

  bool _isHowAreYou(String text) => text.toLowerCase().contains('nasılsınız');
  bool _isGreeting(String text) => _greetingKeywords.contains(text.toLowerCase());
  bool _isInputTooShort(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    return text.trim().length < 10 || words.length < 2;
  }

  Future<void> _addBotMessage(dynamic content, {int delayMs = 1000}) async {
    setState(() => _isTyping = true);
    await Future.delayed(Duration(milliseconds: delayMs));
    setState(() {
      _isTyping = false;
      _messages.add({'text': content, 'isUser': false});
    });
  }

  Future<void> _replyGreeting() async {
    await _addBotMessage('Hoş geldiniz.', delayMs: 500);
    await _addBotMessage('Nasıl yardımcı olabilirim?', delayMs: 800);
    await _addBotMessage('Domates yaprağındaki semptomları bana yazarsanız yardımcı olabilirim.', delayMs: 800);
    await _addBotMessage('Buyrun sizi dinliyorum.', delayMs: 800);
  }

  Future<void> _replyHowAreYou() async {
    await _addBotMessage('Sağolun iyiyim, nasıl yardımcı olabilirim?', delayMs: 600);
  }

  Future<void> _replyInsufficient() async {
    await _addBotMessage(
      'Lütfen yardımcı olabilmem için görülen semptomları daha detaylı analiz edin.',
      delayMs: 600,
    );
  }

  Future<void> _predictDisease(String text) async {
    setState(() => isLoading = true);

    await _addBotMessage(
      '🕒 Sorgunuz işleniyor, bu işlem 10-30 saniye sürebilir. Sabırlı davrandığınız için teşekkür ederiz.',
      delayMs: 500,
    );

    final url = Uri.parse('https://tomato-disease-bert-10.onrender.com/predict');
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );
      if (resp.statusCode == 200) {
        final data = json.decode(utf8.decode(resp.bodyBytes));
        final predictedLabel = data['label'];
        final diseaseInfo = allDiseases.firstWhere(
              (d) => d['name'] == predictedLabel,
          orElse: () => {},
        );

        await _addBotMessage('🧠 Tahmin: $predictedLabel', delayMs: 800);
        await _addBotMessage('📈 Güven Skoru: ${data['confidence'].toStringAsFixed(2)}', delayMs: 600);

        if (diseaseInfo.isEmpty) {
          await _addBotMessage('📋 Açıklama: Açıklama bulunamadı.', delayMs: 800);
        } else {
          await _addBotMessage('📋 Açıklama:\n${_formatDiseaseExplanation(diseaseInfo)}', delayMs: 800);

          final folder = imageFolderMap[diseaseInfo['name']];
          if (folder != null) {
            final List<String> basePaths = ['1', '2'];
            final List<String> extensions = ['jpg', 'JPG'];
            final List<String> imagePaths = [];

            for (var base in basePaths) {
              for (var ext in extensions) {
                imagePaths.add('assets/images/$folder/$base.$ext');
              }
            }

            await _addBotMessage(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: imagePaths.map((path) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      path,
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  );
                }).toList(),
              ),
              delayMs: 500,
            );
          }
        }

        if (data['warning'] != null) {
          await _addBotMessage('⚠️ Uyarı: ${data['warning']}', delayMs: 600);
        }
      } else {
        await _addBotMessage('Tahmin başarısız: ${resp.statusCode}', delayMs: 600);
      }
    } catch (e) {
      await _addBotMessage('Tahmin sırasında hata: $e', delayMs: 600);
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _formatDiseaseExplanation(Map<String, dynamic> d) {
    final buffer = StringBuffer();

    if (d['symptoms'] != null) buffer.writeln('🔍 Belirtiler: ${_joinList(d['symptoms'])}');
    if (d['cause'] != null) buffer.writeln('📌 Sebep: ${_joinList(d['cause'])}');
    if (d['treatment'] != null) buffer.writeln('🛠 Tedavi: ${_joinList(d['treatment'])}');
    if (d['recommended_drug'] != null) buffer.writeln('💊 İlaç: ${_joinList(d['recommended_drug'])}');
    if (d['usage_instructions'] != null) buffer.writeln('📋 Uygulama: ${_joinList(d['usage_instructions'])}');

    return buffer.toString().trim();
  }

  String _joinList(dynamic item) {
    if (item is List) return item.join(', ');
    return item.toString();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _messages.add({'text': text, 'isUser': true}));
    _controller.clear();

    if (_isHowAreYou(text)) {
      _replyHowAreYou();
    } else if (_isGreeting(text)) {
      _replyGreeting();
    } else if (_isInputTooShort(text)) {
      _replyInsufficient();
    } else {
      _predictDisease(text);
    }
  }

  Widget _buildMessageBubble(dynamic content, bool isUser) {
    if (content is String) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? Colors.green[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(content, style: const TextStyle(fontSize: 15)),
        ),
      );
    } else if (content is Widget) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: content,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BERT Chat Teşhis Asistanı')),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/wallpaper/arka_bert.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.hourglass_top, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tahmin yapılıyor... Bu işlem 10-30 saniye sürebilir. Lütfen bekleyiniz.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_isTyping && i == _messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('...', style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }
                    final msg = _messages[i];
                    return _buildMessageBubble(msg['text'], msg['isUser']);
                  },
                ),
              ),
              if (isLoading) const LinearProgressIndicator(),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  children: ['Selam', 'Merhaba', 'Nasılsınız?', 'Yardım']
                      .map((q) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: () => _sendMessage(q),
                      child: Text(q),
                    ),
                  ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Belirtileri yazın...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(_controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
