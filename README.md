
# 🍅 Domates Yaprağı Hastalık Teşhis Uygulaması

Bu proje, **tarımda yapay zeka tabanlı hastalık teşhisi** yapabilen mobil bir uygulamadır. Hem görüntü analizi hem de doğal dil işleme (NLP) teknolojilerini birleştirerek çiftçilere, mühendislik ekiplerine ve araştırmacılara pratik bir çözüm sunar.

---

## 👤 Hakkımda

Ben lise mezunu bir geliştirici olarak yazılım ve yapay zeka alanında kendimi dış kaynaklarla eğittim. Bu projeyi bir diploma yerine geçebilecek düzeyde profesyonel olarak geliştirerek **iş bulma ve portföy oluşturma amacıyla** hazırladım.

---

## 🎯 Projenin Amacı

- Tarım alanında yapay zekanın gücünü göstermek
- Görsel ve metin tabanlı teşhis sistemlerini bir araya getirmek
- Model gömme, API entegrasyonu ve mobil uygulama geliştirme yetkinliğini kanıtlamak

---

## 📱 Uygulama Özellikleri

| Özellik                       | Açıklama                                                                 |
|------------------------------|--------------------------------------------------------------------------|
| 📷 Görüntü ile Teşhis        | Yaprak fotoğrafını yükleyerek hastalığı tahmin eder                      |
| 🌿 Yaprak / Değil Kontrolü   | Görselin gerçekten bir domates yaprağı olup olmadığını kontrol eder      |
| 💬 Chatbot ile Teşhis        | Kullanıcının yazdığı belirti cümlesinden hastalık tahmini yapar (BERT)   |
| 📚 Kütüphane Ekranı          | Tüm hastalıklar için açıklamalar, tedaviler, ilaçlar ve görseller        |
| 🕘 Teşhis Geçmişi            | Önceki analizleri ve sonuçları listeler                                  |

---

## 🧠 Yapay Zeka Modelleri

### 1. Görüntü Tabanlı Hastalık Teşhisi
- 📦 Model: `DenseNet121`
- 🔍 Eğitim veri seti: [Kaggle - Tomato Leaf Dataset](https://www.kaggle.com/datasets/kaustubhb999/tomatoleaf)
- 🔧 Teknikler:
  - Transfer Learning (ImageNet ağırlıkları)
  - Data Augmentation
  - Class Weight Balancing
- 🎯 Sınıflar:
  - 10 hastalık + Sağlıklı (11 sınıf)
- 📊 Accuracy: 90%+ (sınıf bazlı confusion matrix ile detaylandırıldı)

### 2. Yaprak / Değil Kontrolü
- 📦 Model: `MobileNetV2`
- 🧪 Sınıflar: `leaf`, `notleaf`
- 🔍 Amaç: Hatalı görsellerle yapılan teşhisleri engellemek
- 📊 Performans: 10 epoch sonrası yüksek doğruluk

### 3. Chatbot ile Teşhis (BERT)
- 📦 Model: `tomato-bert-10` – Türkçe BERT tabanlı sınıflandırıcı
- 🔧 Eğitim: Her hastalık için örnek semptom cümleleri ile
- 🌐 API:  
  - 🤖 Model: [Hugging Face](https://huggingface.co/Kahsi13/tomato-bert-10)  
  - ⚙️ Render API: [https://tomato-disease-bert-10.onrender.com](https://tomato-disease-bert-10.onrender.com)  
  - 💻 Kaynak Kodu: [GitHub](https://github.com/kahsi13/tomato-disease-bert-10)
- 📊 Örnek F1-Skorları:
  - Erken Yaprak Yanıklığı: **0.96**
  - TYLCV: **0.96**
  - Bakteriyel Leke: **0.64**

---

## 📁 Proje Yapısı & Kılavuz

```
hastalik_analiz/
├── lib/
│   ├── main.dart                       # Uygulamanın giriş noktası
│   ├── data/                           # Veri yönetimi
│   ├── models/                         # Model sınıfları
│   ├── screens/
│   │   ├── home_screen.dart            # Ana sayfa
│   │   ├── tomato_analysis_screen.dart# Görsel analiz
│   │   ├── bert_chat_screen.dart       # Chatbot ekranı
│   │   ├── library_screen.dart         # Hastalık kütüphanesi
│   │   ├── diagnosis_history_screen.dart# Geçmiş analizler
│   │   ├── welcome_screen.dart         # Hoşgeldiniz
│   │   └── bert_screen.dart            # (Eski sayfa/test)
│   └── theme/                          # Renk ve tema
├── assets/
│   ├── images/                         # Hastalık görselleri
│   └── data/
│       └── domates_hastaliklari_professional_final.json
├── notebooks/
│   ├── 01-densenet-train.ipynb         # DenseNet121 eğitimi
│   ├── 02-leafgate-train.ipynb         # Leaf / NotLeaf modeli
│   └── 03-bert-train.py                # BERT eğitimi
├── pubspec.yaml                        # Flutter bağımlılıkları
└── README.md                           # Proje dokümanı
```

---

## 🔗 Bağlantılar

| Kaynak             | Link |
|--------------------|------|
| Proje Repo         | [hastalik_analiz_son](https://github.com/kahsi13/hastalik_analiz_son) |
| BERT Modeli        | [tomato-bert-10](https://huggingface.co/Kahsi13/tomato-bert-10) |
| BERT API Kodu      | [tomato-disease-bert-10](https://github.com/kahsi13/tomato-disease-bert-10) |
| BERT API (Render)  | [API Link](https://tomato-disease-bert-10.onrender.com) |

---

## 🧪 Sonuç ve Kazanımlar

- ✅ Flutter ile tam fonksiyonel mobil uygulama
- ✅ Görüntü + metin tabanlı 3 yapay zeka modeli
- ✅ API bağlantısı + model gömme örnekleri
- ✅ Detaylı teşhis, tedavi ve görsel destek

---

## ✨ Teşekkür

Bu proje boyunca yapay zekayı gerçek dünyada kullanmanın tüm zorluklarını ve güzelliklerini deneyimledim. Umarım hem teknik hem de görsel anlamda ilham verici olur.

---

## 📝 Lisans

Bu proje [MIT Lisansı](LICENSE) ile lisanslanmıştır.
