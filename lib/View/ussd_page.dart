import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/Services/hive_service.dart';
import '../utils/Services/reading_excel.dart';
import '../utils/Services/u_s_s_d_service.dart';
import '../utils/constants/app_colors.dart';
import 'widgets/floating_buttons.dart';
import 'widgets/loading_overlay.dart';
import 'widgets/numbers_list.dart';
import 'widgets/numbers_list_header.dart';
import 'widgets/template_card.dart';

class UssdCallerPage extends StatefulWidget {
  const UssdCallerPage({super.key});

  @override
  State<UssdCallerPage> createState() => _UssdCallerPageState();
}

class _UssdCallerPageState extends State<UssdCallerPage> {
  final TextEditingController templateController = TextEditingController();

  int currentIndex = 0;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  bool isProcessRunning = false;

  @override
  void initState() {
    super.initState();
    templateController.text = HiveService.getUssdTemplate();
    templateController.addListener(_saveTemplate);
  }

  void _saveTemplate() {
    HiveService.setUssdTemplate(templateController.text);
  }

  void _startProcessFromSpecificIndex(int index) {
    startProcessFromIndex(index);
  }

  @override
  void dispose() {
    isLoading.dispose();
    templateController.removeListener(_saveTemplate);
    templateController.dispose();
    super.dispose();
  }

  String generateUSSD(String number) {
    return USSDService.generateUSSD(templateController.text, number);
  }

  void removeNumber(int index) {
    HiveService.removeNumber(index);
    _showSnackBar("Number deleted");
  }

  void clearAllNumbers() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warningColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text("Confirm Delete"),
          ],
        ),
        content: Text(
          "Are you sure you want to delete all numbers (${HiveService.totalNumbers})?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              HiveService.clearAll();
              Navigator.pop(context);
              _showSnackBar("All numbers deleted");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete All"),
          ),
        ],
      ),
    );
  }

  void _showAddNumberDialog() async {
    final List<String> numbers = await ReadingExcel.pickAndReadExcel();
    for (var element in numbers) {
      HiveService.addNumber(element);
    }

    // await startProcessFromIndex(0);
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.grey.shade800,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> callSingleNumber(int index) async {
    final number = HiveService.getNumberAt(index);
    if (number == null) return;

    if (!USSDService.isValidTemplate(templateController.text)) {
      _showSnackBar(
        "Invalid template! Must contain {number}",
        backgroundColor: AppColors.errorColor,
      );
      return;
    }

    isLoading.value = true;

    final success = await USSDService.callUSSDWithTemplate(
      templateController.text,
      number,
    );

    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      isLoading.value = false;

      if (success) {
        _showSnackBar("Call initiated", backgroundColor: AppColors.accentColor);
      } else {
        _showSnackBar("Call failed", backgroundColor: AppColors.errorColor);
      }
    }
  }

  Future<void> startProcessFromIndex(int index) async {
    if (!HiveService.hasNumbers) {
      _showSnackBar(
        "Please add numbers first",
        backgroundColor: AppColors.errorColor,
      );
      return;
    }

    if (!USSDService.isValidTemplate(templateController.text)) {
      _showSnackBar(
        "Invalid template! Must contain {number}",
        backgroundColor: AppColors.errorColor,
      );
      return;
    }

    isProcessRunning = true;
    currentIndex = index;
    setState(() {});

    while (currentIndex < HiveService.totalNumbers && isProcessRunning) {
      isLoading.value = true;

      final number = HiveService.getNumberAt(currentIndex);
      if (number != null) {
        await USSDService.callUSSDWithTemplate(templateController.text, number);
      }

      await Future.delayed(const Duration(seconds: 5));

      if (mounted && isProcessRunning) {
        isLoading.value = false;
        setState(() => currentIndex++);
      }
    }

    if (mounted && isProcessRunning) {
      isProcessRunning = false;
      setState(() {});
      _showSnackBar(
        "Process completed!",
        backgroundColor: AppColors.accentColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isProcessRunning,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _showSnackBar(
            "Cannot exit while process is running.",
            backgroundColor: AppColors.warningColor,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          title: Text(
            "USSD Auto Caller",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          toolbarHeight: 56.h, // Default AppBar height or a responsive value
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TemplateCard(
                    templateController: templateController,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 24.h),
                  NumbersListHeader(onClearAll: clearAllNumbers),
                  SizedBox(height: 12.h),
                  NumbersList(
                    currentIndex: currentIndex,
                    isProcessRunning: isProcessRunning,
                    generateUSSD: generateUSSD,
                    callSingleNumber: callSingleNumber,
                    removeNumber: removeNumber,
                    isLoading: isLoading,
                    onStartFromIndex: _startProcessFromSpecificIndex,
                  ),
                  SizedBox(height: 80.h), // Space for FAB
                ],
              ),
            ),
            LoadingOverlay(isLoading: isLoading, currentIndex: currentIndex),
          ],
        ),
        floatingActionButton: FloatingButtons(
          onAddNumber: _showAddNumberDialog,
          isProcessRunning: isProcessRunning,
          onStartAll: () => startProcessFromIndex(0),
        ),
      ),
    );
  }
}
