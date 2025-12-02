import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class USSDService {
  static String generateUSSD(String template, String number) {
    return template.replaceAll("{number}", number);
  }
  
  static bool isValidTemplate(String template) {
    return template.isNotEmpty && template.contains("{number}");
  }
  
  static Future<bool> callUSSD(String ussdCode) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(ussdCode);
      return true;
    } catch (e) {
      // print("Error calling USSD: $e");
      return false;
    }
  }
  
  static Future<bool> callUSSDWithTemplate(String template, String number) async {
    if (!isValidTemplate(template)) {
      // print("Invalid template");
      return false;
    }
    
    final ussdCode = generateUSSD(template, number);
    return await callUSSD(ussdCode);
  }
}
