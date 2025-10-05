# 🈳 Offline Translator

**A Flutter package for completely offline translation** — no internet, no external files, fully self-contained.  

![Flutter](https://img.shields.io/badge/Flutter-3.0-blue) ![Dart](https://img.shields.io/badge/Dart-2.19-blue) ![Platforms](https://img.shields.io/badge/iOS-16+-orange)  



## 🚀 Features

- **Offline translations**: Works without internet.  
- **Multiple languages supported**: English, French, Spanish, Urdu, Arabic, Chinese (`en`, `fr`, `es`, `ur`, `ar`, `zh`).  
- **No extra files required**: JSON/ARB-free.  
- **Easy integration**: Works like Flutter’s `Text()` widget.  
- Lightweight, fast, and reliable.  



## 🎯 Getting Started

### 1️⃣ Add Dependency

dependencies:
  offline_translator: ^0.0.1

### 2️⃣ Initialize Translator


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await OfflineTranslator.init(
    defaultLang: 'en',
    langs: ['en', 'fr', 'es', 'ur', 'ar', 'zh'],
  );

  runApp(const MyApp());
  }




### 3️⃣ Wrap App with Provider


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TranslationProvider(
        defaultLang: 'en',
        supportedLangs: ['en','fr','es','ur','ar','zh'],
      ),
      child: const MaterialApp(home: HomePage()),
    );
  }
}

# usage dynamically
 Translated TranslatedText("Offline Translator Package"),



## 💡 Key Advantages

* **Dynamic placeholders**: Easily replace text like `"Welcome {name}"`.
* **Offline-first**: Ideal for apps with no internet connectivity.
* **android & iOS: Works on android & iOS 16+ and all Flutter-supported platforms.



## 📌 Example Usage


// Translate dynamically with parameters
TranslatedText("Welcome {name}", params: {"name": "Ahmed"});

# default langauge at run time 
provider.setLanguage('en'); // UI automatically updates




## 🏆 Why Choose Offline Translator?

✅ No network dependency
✅ Multi-language support
✅ Fast, lightweight, and simple API
✅ Perfect for mobile apps requiring offline capabilities



**Supported Languages:**

**Supported Languages:**  

 English   en    🇺🇸 
 French    fr    🇫🇷 
 Spanish   es    🇪🇸 
 Urdu      ur    🇵🇰 
 Arabic    ar    🇸🇦 
 Chinese   zh    🇨🇳 


Note: we are adding more languages and working on performance and enhancement


Made with ❤️ by Ahmed Khushal Khan

