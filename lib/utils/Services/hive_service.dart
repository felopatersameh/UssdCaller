import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _numbersBox = 'numbers';
  static const String _templateBox = 'template';
  static const String _templateKey = 'ussdTemplate';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_numbersBox);
    await Hive.openBox<String>(_templateBox);
  }

  static Box<String> get numbersBox => Hive.box<String>(_numbersBox);
  static Box<String> get templateBox => Hive.box<String>(_templateBox);

  static String getUssdTemplate() {
    return templateBox.get(_templateKey, defaultValue: "*9*{number}*50#")!;
  }

  static void setUssdTemplate(String template) {
    templateBox.put(_templateKey, template);
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
