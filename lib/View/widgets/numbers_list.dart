import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_caller/utils/Services/hive_service.dart';
import 'package:auto_caller/utils/constants/app_colors.dart';
import 'package:auto_caller/utils/constants/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NumbersList extends StatelessWidget {
  const NumbersList({
    super.key,
    required this.currentIndex,
    required this.isProcessRunning,
    required this.generateUSSD,
    required this.callSingleNumber,
    required this.removeNumber,
    required this.isLoading,
    required this.onStartFromIndex,
  });

  final int currentIndex;
  final bool isProcessRunning;
  final String Function(String) generateUSSD;
  final Future<void> Function(int) callSingleNumber;
  final void Function(int) removeNumber;
  final ValueNotifier<bool> isLoading;
  final void Function(int) onStartFromIndex;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.numbersBox.listenable(),
      builder: (context, box, _) {
        if (!HiveService.hasNumbers) {
          return Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dividerColor,
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.phone_android_outlined,
                    size: 80.sp,
                    color: AppColors.dividerColor,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "No Numbers Yet",
                    style: AppConstants.numberListEmptyTitleTextStyle.copyWith(
                      color: AppColors.textColor.withValues(alpha: 0.6),
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Tap the + button to add numbers",
                    style: AppConstants.numberListEmptySubtitleTextStyle
                        .copyWith(
                          color: AppColors.textColor.withValues(alpha: 0.5),
                          fontSize: 12.sp,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: HiveService.totalNumbers,
          itemBuilder: (context, index) {
            final callEntry = HiveService.getNumberAt(index)!;
            final isCurrent = index == currentIndex && isProcessRunning;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  width: 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCurrent
                        ? AppColors.primaryColor.shade100
                        : AppColors.dividerColor,
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                leading: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCurrent
                          ? [
                              AppColors.primaryColor.shade400,
                              AppColors.primaryColor.shade600,
                            ]
                          : [
                              AppColors.dividerColor.withValues(alpha: 0.3),
                              AppColors.dividerColor.withValues(alpha: 0.4),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: AppConstants.ussdTemplateTextStyle.copyWith(
                        color: isCurrent ? Colors.white : AppColors.textColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  callEntry
                      .number, // Access the actual string property from CallEntry
                  style: AppConstants.ussdTemplateTextStyle.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15.sp,
                    color: AppColors.textColor,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    generateUSSD(callEntry.number),
                    style: AppConstants.ussdTemplateTextStyle.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (callEntry.isCalled)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.accentColor,
                        size: 20.sp,
                      ),
                    SizedBox(width: callEntry.isCalled ? 8.w : 0),
                    // New "Start from here" button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.play_arrow,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                        onPressed: isLoading.value || isProcessRunning
                            ? null
                            : () => onStartFromIndex(index),
                        tooltip: "Start process from here",
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.accentColor.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.phone,
                          color: AppColors.accentColor,
                          size: 20.sp,
                        ),
                        onPressed: isLoading.value || isProcessRunning
                            ? null
                            : () => callSingleNumber(index),
                        tooltip: "Call this number",
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.errorColor.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.errorColor,
                          size: 20.sp,
                        ),
                        onPressed: () => removeNumber(index),
                        tooltip: "Delete",
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
