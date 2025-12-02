// import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

class ReadingExcel {
  static Future<File?> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }

      return null;
    } catch (e) {
      // //log('Error picking Excel file: $e');
      rethrow;
    }
  }

  /// Read Excel file and convert to List of Maps
  /// Each map represents a row with column headers as keys
 static Future<List<String>> _readExcelFile(File file) async {
  try {
    final bytes = file.readAsBytesSync();
    final decoder = SpreadsheetDecoder.decodeBytes(bytes);
    final List<String> numbers = [];
    
    // Get the first sheet
    final tableName = decoder.tables.keys.first;
    final table = decoder.tables[tableName];
    
    if (table != null && table.rows.isNotEmpty) {
      // Skip header row (start from row 1) and get only first column
      for (int i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];
        
        // Get first column value only
        if (row.isNotEmpty) {
          final firstColumnValue = row[0]?.toString().trim() ?? '';
          
          // Add only if not empty
          if (firstColumnValue.isNotEmpty) {
            numbers.add(firstColumnValue);
          }
        }
      }
    }
    
    // log('Successfully loaded ${numbers.length} numbers from first column');
    return numbers;
    
  } catch (e) {
    // log('Error reading Excel file: $e');
    throw Exception('Failed to read Excel file: $e');
  }
}

  /// Pick and read Excel file in one step
  /// Returns List of Maps or empty list if cancelled/error
  static Future<List<String>> pickAndReadExcel() async {
    try {
      final file = await _pickExcelFile();

      if (file == null) {
        // //log('No file selected');
        return [];
      }

      return await _readExcelFile(file);
    } catch (e) {
      // //log('Error in pickAndReadExcel: $e');
      return [];
    }
  }

  
}
