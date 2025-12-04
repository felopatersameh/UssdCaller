import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_caller/utils/Services/call_entry.dart';

class HiveService {
  static const String _numbersBox = 'numbers';
  static const String _templateBox = 'template';
  static const String _templateKey = 'ussdTemplate';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CallEntryAdapter());
    await Hive.openBox<CallEntry>(_numbersBox);
    await Hive.openBox<String>(_templateBox);
  }

  static Box<CallEntry> get numbersBox => Hive.box<CallEntry>(_numbersBox);
  static Box<String> get templateBox => Hive.box<String>(_templateBox);

  static String getUssdTemplate() {
    return templateBox.get(_templateKey, defaultValue: "*9*{number}*50#")!;
  }

  static void setUssdTemplate(String template) {
    templateBox.put(_templateKey, template);
  }

  static void addNumber(String number) {
    numbersBox.add(CallEntry(number: number));
  }

  static void removeNumber(int index) {
    numbersBox.deleteAt(index);
  }

  static void clearAll() {
    numbersBox.clear();
  }

  static CallEntry? getNumberAt(int index) {
    if (index >= 0 && index < numbersBox.length) {
      return numbersBox.getAt(index);
    }
    return null;
  }

  static void updateCallEntryStatus(
    int index, {
    bool? isCalled,
    bool? shouldTryLater,
  }) {
    final entry = numbersBox.getAt(index);
    if (entry != null) {
      numbersBox.putAt(
        index,
        entry.copyWith(isCalled: isCalled, shouldTryLater: shouldTryLater),
      );
    }
  }

  static int get totalNumbers => numbersBox.length;

  static bool get hasNumbers => numbersBox.isNotEmpty;

  static List<CallEntry> getAllNumbers() {
    return numbersBox.values.toList();
  }
}
