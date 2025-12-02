class PhoneValidator {
  // Egyptian phone number validation
  static bool isValidEgyptianNumber(String phone) {
    final cleaned = phone.trim();
    final regex = RegExp(r'^(010|011|012|015)\d{8}$');
    return regex.hasMatch(cleaned);
  }
  
  static bool isValidNumber(String phone) {
    final cleaned = phone.trim();
    return cleaned.isNotEmpty && cleaned.length >= 10;
  }
  
  static String cleanPhoneNumber(String phone) {
    return phone.trim().replaceAll(RegExp(r'\s+'), '');
  }
  
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'من فضلك أدخل رقم الهاتف';
    }
    
    final cleaned = cleanPhoneNumber(phone);
    
    if (!isValidEgyptianNumber(cleaned)) {
      return 'رقم غير صحيح (يجب أن يبدأ بـ 010/011/012/015)';
    }
    
    return null;
  }
}
