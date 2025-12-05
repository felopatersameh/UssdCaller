import 'package:auto_caller/View/widgets/modern_dialog.dart';
import 'package:auto_caller/View/widgets/ussd_page.dart';
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

enum ConfirmationDialogResult {
  successAndContinue,
  failAndTryLaterAndContinue,
  successAndStopAll,
  failAndStopAll,
  cancel,
}

enum AlreadyCalledDialogResult { callAgain, skip, stopAll, cancel }

class _UssdCallerPageState extends State<UssdCallerPage> {
  final TextEditingController templateController = TextEditingController();

  int currentIndex = 0;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> isProcessRunning = ValueNotifier<bool>(false);

  void _resetCallStatusesOnTemplateChange() {
    final currentTemplateText = templateController.text.trim();
    final savedTemplateText = HiveService.getUssdTemplate().trim();

    if (currentTemplateText != savedTemplateText) {
      HiveService.setUssdTemplate(currentTemplateText);
      for (int i = 0; i < HiveService.totalNumbers; i++) {
        HiveService.updateCallEntryStatus(
          i,
          isCalled: false,
          shouldTryLater: false,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    templateController.text = HiveService.getUssdTemplate();
    if (!templateController.text.contains('{number}')) {
      templateController.text = '*9*{number}*50#';
    }
    templateController.addListener(_resetCallStatusesOnTemplateChange);
  }

  void _startProcessFromSpecificIndex(int index) {
    startProcessFromIndex(index);
  }

  @override
  void dispose() {
    isLoading.dispose();
    templateController.removeListener(_resetCallStatusesOnTemplateChange);
    templateController.dispose();
    super.dispose();
  }

  String generateUSSD(String number) {
    return USSDService.generateUSSD(templateController.text, number);
  }

  void removeNumber(int index) {
    HiveService.removeNumber(index);
    _showSnackBar("Number deleted", icon: Icons.delete_outline);
  }

  void clearAllNumbers() {
    showDialog(
      context: context,
      builder: (_) => ModernDialog(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.warningColor,
        title: "Confirm Delete",
        content:
            "Are you sure you want to delete all numbers (${HiveService.totalNumbers})?",
        actions: [
          DialogButton(
            label: "Cancel",
            onPressed: () => Navigator.pop(context, false),
            isOutlined: true,
          ),
          DialogButton(
            label: "Delete All",
            onPressed: () {
              HiveService.clearAll();
              Navigator.pop(context, true);
            },
            color: AppColors.errorColor,
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
  }

  void _showSnackBar(String message, {Color? backgroundColor, IconData? icon}) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Row(
    //       children: [
    //         if (icon != null) ...[
    //           Icon(icon, color: Colors.white, size: 20.sp),
    //           SizedBox(width: 12.w),
    //         ],
    //         Text(message),
    //       ],
    //     ),
    //     backgroundColor: backgroundColor ?? AppColors.primaryColor.shade700,
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(12.r),
    //     ),
    //     // margin: EdgeInsets.all(16),
    //     //  elevation: 8,
    //     // duration: const Duration(seconds: 3),
    //   ),
    // );
  }

  Future<AlreadyCalledDialogResult?> _showAlreadyCalledDialog(
    String number,
  ) async {
    return showDialog<AlreadyCalledDialogResult?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModernDialog(
        icon: Icons.check_circle_outline,
        iconColor: AppColors.accentColor,
        title: "Already Called",
        content: "Number $number has already been successfully called.",
        actions: [
          DialogButton(
            label: "Call Again",
            onPressed: () =>
                Navigator.pop(context, AlreadyCalledDialogResult.callAgain),
          ),
          DialogButton(
            label: "Skip",
            onPressed: () =>
                Navigator.pop(context, AlreadyCalledDialogResult.skip),
            isOutlined: true,
          ),
          DialogButton(
            label: "Cancel",
            onPressed: () =>
                Navigator.pop(context, AlreadyCalledDialogResult.cancel),
            color: AppColors.errorColor,
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Future<ConfirmationDialogResult?> _showConfirmationDialog(
    String number,
  ) async {
    return showDialog<ConfirmationDialogResult?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModernDialog(
        icon: Icons.phone_in_talk,
        iconColor: AppColors.primaryColor,
        title: "Confirm Call",
        content: "Number: $number\n\nDid the call succeed?",
        actions: [
          DialogButton(
            label: "✓ Success, Continue",
            onPressed: () => Navigator.pop(
              context,
              ConfirmationDialogResult.successAndContinue,
            ),
            color: AppColors.accentColor,
          ),
          DialogButton(
            label: "⟳ Try Later, Continue",
            onPressed: () => Navigator.pop(
              context,
              ConfirmationDialogResult.failAndTryLaterAndContinue,
            ),
            color: AppColors.warningColor,
          ),
          DialogButton(
            label: "✓ Success, Stop",
            onPressed: () => Navigator.pop(
              context,
              ConfirmationDialogResult.successAndStopAll,
            ),
            isOutlined: true,
          ),
          DialogButton(
            label: "✗ Failed, Stop",
            onPressed: () =>
                Navigator.pop(context, ConfirmationDialogResult.failAndStopAll),
            color: AppColors.errorColor,
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Future<void> callSingleNumber(int index) async {
    final callEntry = HiveService.getNumberAt(index);
    if (callEntry == null) return;

    if (!USSDService.isValidTemplate(templateController.text)) {
      _showSnackBar(
        "Invalid template! Must contain {number}",
        backgroundColor: AppColors.errorColor,
        icon: Icons.error_outline,
      );
      return;
    }

    isLoading.value = true;
    isProcessRunning.value = true;
    final success = await USSDService.callUSSDWithTemplate(
      templateController.text,
      callEntry.number,
    );

    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      isLoading.value = false;
    isProcessRunning.value = false;
      HiveService.updateCallEntryStatus(index, isCalled: success);

      if (success) {
        _showSnackBar(
          "Call initiated",
          backgroundColor: AppColors.accentColor,
          icon: Icons.check_circle,
        );
      } else {
        _showSnackBar(
          "Call failed",
          backgroundColor: AppColors.errorColor,
          icon: Icons.error,
        );
      }
    }
  }

  Future<void> startProcessFromIndex(int index) async {
    if (!HiveService.hasNumbers) {
      _showSnackBar(
        "Please add numbers first",
        backgroundColor: AppColors.errorColor,
        icon: Icons.error_outline,
      );
      return;
    }

    if (!USSDService.isValidTemplate(templateController.text)) {
      _showSnackBar(
        "Invalid template! Must contain {number}",
        backgroundColor: AppColors.errorColor,
        icon: Icons.error_outline,
      );
      return;
    }

    isProcessRunning.value = true;
    currentIndex = index;
    setState(() {});

    while (currentIndex < HiveService.totalNumbers && isProcessRunning.value) {
      final callEntry = HiveService.getNumberAt(currentIndex);
      if (callEntry != null) {
        if (callEntry.isCalled) {
          final alreadyCalledResult = await _showAlreadyCalledDialog(
            callEntry.number,
          );

          switch (alreadyCalledResult) {
            case AlreadyCalledDialogResult.callAgain:
              break;
            case AlreadyCalledDialogResult.skip:
              setState(() => currentIndex++);
              continue;
            case AlreadyCalledDialogResult.stopAll:
            case null:
              isProcessRunning.value = false;
              if (mounted) setState(() {});
              _showSnackBar(
                "Process stopped",
                backgroundColor: AppColors.warningColor,
                icon: Icons.stop_circle,
              );
              return;
            case AlreadyCalledDialogResult.cancel:
              return;
          }
        }

        isLoading.value = true;
        final callSuccess = await USSDService.callUSSDWithTemplate(
          templateController.text,
          callEntry.number,
        );
        await Future.delayed(const Duration(seconds: 5));

        if (mounted && isProcessRunning.value) {
          isLoading.value = false;
          final dialogResult = await _showConfirmationDialog(callEntry.number);

          switch (dialogResult) {
            case ConfirmationDialogResult.successAndContinue:
              HiveService.updateCallEntryStatus(
                currentIndex,
                isCalled: callSuccess,
                shouldTryLater: false,
              );
              setState(() => currentIndex++);
              break;
            case ConfirmationDialogResult.failAndTryLaterAndContinue:
              HiveService.updateCallEntryStatus(
                currentIndex,
                isCalled: false,
                shouldTryLater: true,
              );
              setState(() => currentIndex++);
              break;
            case ConfirmationDialogResult.successAndStopAll:
              HiveService.updateCallEntryStatus(
                currentIndex,
                isCalled: callSuccess,
                shouldTryLater: false,
              );
              isProcessRunning.value = false;
              _showSnackBar(
                "Process completed",
                backgroundColor: AppColors.accentColor,
                icon: Icons.check_circle,
              );
              return;
            case ConfirmationDialogResult.failAndStopAll:
              HiveService.updateCallEntryStatus(
                currentIndex,
                isCalled: false,
                shouldTryLater: false,
              );
              isProcessRunning.value = false;
              _showSnackBar(
                "Process stopped",
                backgroundColor: AppColors.errorColor,
                icon: Icons.error,
              );
              return;
            case ConfirmationDialogResult.cancel:
            case null:
              isProcessRunning.value = false;
              _showSnackBar(
                "Process cancelled",
                backgroundColor: AppColors.warningColor,
                icon: Icons.cancel,
              );
              return;
          }
        } else {
          break;
        }
      } else {
        setState(() => currentIndex++);
      }
    }

    if (mounted) {
      isProcessRunning.value = false;
      if (currentIndex == HiveService.totalNumbers) {
        _showSnackBar(
          "All done!",
          backgroundColor: AppColors.accentColor,
          icon: Icons.celebration,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isProcessRunning.value,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _showSnackBar(
            "Cannot exit while process is running",
            backgroundColor: AppColors.warningColor,
            icon: Icons.block,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Modern AppBar
                SliverAppBar(
                  expandedHeight: 120.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "USSD Auto Caller",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.shade400,
                            AppColors.primaryColor.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
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
                      SizedBox(height: 100.h),
                    ]),
                  ),
                ),
              ],
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
