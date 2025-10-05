// ignore_for_file: library_private_types_in_public_api

// ignore: unnecessary_library_name
library offline_translator;

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

/// ------------------
/// Offline Translator Core
/// ------------------
class OfflineTranslator {
  static final OfflineTranslator instance = OfflineTranslator._internal();

  OnDeviceTranslator? _translator;
  late String _currentLang;
  Box<dynamic>? _cache;
  bool _initialized = false;

  OfflineTranslator._internal();

  /// Initialize translator, download models, and optionally preload texts
  static Future<void> init({
    String defaultLang = 'fr',
    List<String>? langs,
    List<String>? preloadTexts,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    instance._cache ??= await Hive.openBox('translations');

    final targetLangs = langs ?? ['en', 'fr', 'es', 'ur', 'ar', 'zh'];
    final modelManager = OnDeviceTranslatorModelManager();

    // Ensure English source model
    const sourceLang = TranslateLanguage.english;
    if (!await modelManager.isModelDownloaded(sourceLang.bcpCode)) {
      await modelManager.downloadModel(sourceLang.bcpCode);
    }

    // Ensure all target models
    for (final lang in targetLangs) {
      final mapped = _mapLang(lang);
      final code = mapped.bcpCode;
      final downloadedKey = "model_$code";
      if (instance._cache!.get(downloadedKey) != true) {
        if (!await modelManager.isModelDownloaded(code)) {
          await modelManager.downloadModel(code);
        }
        await instance._cache!.put(downloadedKey, true);
      }
    }

    // Prepare initial translator
    instance._currentLang = defaultLang;
    await instance._prepareTranslator(defaultLang);
    instance._initialized = true;

    // Preload any provided texts
    if (preloadTexts != null) {
      for (var text in preloadTexts) {
        instance.translateText(text);
      }
    }
  }

  /// Prepare translator for a target language
  Future<void> _prepareTranslator(String lang) async {
    final sourceLang = TranslateLanguage.english;
    final targetLang = _mapLang(lang);

    _translator?.close();
    _translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );

    _currentLang = lang;
  }

  /// Change target language
  static Future<void> changeLanguage(String lang) async {
    await instance._prepareTranslator(lang);
  }

  /// Async translation with caching
  Future<String> translateText(String text) async {
    if (!_initialized) throw Exception('OfflineTranslator not initialized.');
    if (text.trim().isEmpty) return '';

    final cacheKey = "${text}_$_currentLang";
    if (_cache!.containsKey(cacheKey)) return _cache!.get(cacheKey) as String;

    try {
      final result = await _translator!.translateText(text);
      await _cache!.put(cacheKey, result);
      return result;
    } catch (_) {
      return text; // fallback to original
    }
  }

  /// Synchronous translation from cache
  /// Returns original text if translation not cached
  String translateSync(String text) {
    final cacheKey = "${text}_$_currentLang";
    if (_cache!.containsKey(cacheKey)) return _cache!.get(cacheKey) as String;
    return text;
  }

  /// Dispose translator
  void dispose() => _translator?.close();

  /// Map language code → ML Kit TranslateLanguage
  static TranslateLanguage _mapLang(String lang) {
    switch (lang) {
      case 'fr':
        return TranslateLanguage.french;
      case 'es':
        return TranslateLanguage.spanish;
      case 'ur':
        return TranslateLanguage.urdu;
      case 'ar':
        return TranslateLanguage.arabic;
      case 'zh':
        return TranslateLanguage.chinese;
      case 'en':
      default:
        return TranslateLanguage.english;
    }
  }
}

/// ------------------
/// Provider for dynamic UI updates
/// ------------------
class TranslationProvider extends ChangeNotifier {
  String _currentLang;
  final List<String> _supportedLangs;

  TranslationProvider({
    required String defaultLang,
    required List<String> supportedLangs,
  }) : _currentLang = defaultLang,
       _supportedLangs = supportedLangs {
    OfflineTranslator.changeLanguage(defaultLang);
  }

  String get currentLang => _currentLang;
  List<String> get supportedLangs => _supportedLangs;

  /// Change language and update UI
  Future<void> setLanguage(String lang) async {
    _currentLang = lang;
    await OfflineTranslator.changeLanguage(lang);
    notifyListeners();
  }

  /// Synchronous translation
  String translateSync(String text) =>
      OfflineTranslator.instance.translateSync(text);

  /// Async translation
  Future<String> translate(String text) =>
      OfflineTranslator.instance.translateText(text);
}

/// ------------------
/// TranslatedText Widget
/// ------------------
class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  _TranslatedTextState createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String? _translated;

  @override
  void initState() {
    super.initState();
    _translate();
  }

  void _translate() async {
    final provider = Provider.of<TranslationProvider>(context, listen: false);

    final result = await provider.translate(widget.text);
    if (mounted) setState(() => _translated = result);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<TranslationProvider>(context);
    provider.addListener(() {
      if (!mounted) return;
      _translate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _translated ?? widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
