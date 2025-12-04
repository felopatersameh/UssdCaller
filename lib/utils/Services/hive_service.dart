import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _numbersBox = 'numbers';
  static const String _templateBox = 'template';
  static const String _templateKey = 'ussdTemplate';
  static const String _settingsBox = 'settings';
  static const String _ussdDelayKey = 'ussdDelay';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_numbersBox);
    await Hive.openBox<String>(_templateBox);
    await Hive.openBox<int>(_settingsBox);
  }

  static Box<String> get numbersBox => Hive.box<String>(_numbersBox);
  static Box<String> get templateBox => Hive.box<String>(_templateBox);
  static Box<int> get settingsBox => Hive.box<int>(_settingsBox);

  static String getUssdTemplate() {
    return templateBox.get(_templateKey, defaultValue: "*9*{number}*50#")!;
  }

  static void setUssdTemplate(String template) {
    templateBox.put(_templateKey, template);
  }

  static int getUssdDelay() {
    return settingsBox.get(_ussdDelayKey, defaultValue: 15)!;
  }

  static void setUssdDelay(int delay) {
    settingsBox.put(_ussdDelayKey, delay);
  }

  static void addNumber(String number) {
    numbersBox.add(number);
  }

  static void removeNumber(int index) {
    numbersBox.deleteAt(index);
  }

  static void clearAll() {
    numbersBox.clear();
  }

  static String? getNumberAt(int index) {
    if (index >= 0 && index < numbersBox.length) {
      return numbersBox.getAt(index);
    }
    return null;
  }

  static int get totalNumbers => numbersBox.length;

  static bool get hasNumbers => numbersBox.isNotEmpty;

  static List<String> getAllNumbers() {
    return numbersBox.values.toList();
  }
}
