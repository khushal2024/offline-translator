import 'package:flutter/material.dart';
import 'package:offline_translator/offline_translator.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await OfflineTranslator.init(
    defaultLang: 'en',
    langs: ['en', 'fr', 'es', 'ur', 'ar', 'zh'],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TranslationProvider(
        defaultLang: 'en',
        supportedLangs: ['en', 'fr', 'es', 'ur', 'ar', 'zh'],
      ),
      child: const MaterialApp(home: HomePage()),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: TranslatedText("Offline Translator Demo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selection dropdown
            Row(
              children: [
                TranslatedText(
                  "Select Language: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: provider.currentLang,
                  items: provider.supportedLangs
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) provider.setLanguage(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Multiple translated texts
            const TranslatedText("Hello World"),
            const TranslatedText("Flutter is amazing"),
            const TranslatedText("Welcome {name}"),
            const TranslatedText("You have 5 new messages"),
            const TranslatedText("this is what we call a flutter package"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
