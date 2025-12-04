import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/app_colors.dart';

class TemplateCard extends StatelessWidget {
  const TemplateCard({
    super.key,
    required this.templateController,
    required this.onChanged,
  });

  final TextEditingController templateController;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.shade400,
            AppColors.primaryColor.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.shade200.withValues(alpha: 0.4),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.code_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "USSD Template",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Configure your USSD code",
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Input Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: TextFormField(
                controller: templateController,
                onChanged: onChanged,
                textInputAction: TextInputAction.done,
                inputFormatters: [ProtectPlaceholderFormatter()],
                decoration: InputDecoration(
                  hintText: "*9*{number}*50#",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Container(
                    margin: EdgeInsets.all(10.w),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.phone_in_talk_rounded,
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor.shade900,
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            SizedBox(height: 16.h),

            // Info Box
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Use {number} as placeholder for phone numbers",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProtectPlaceholderFormatter extends TextInputFormatter {
  static const String placeholder = '{number}';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty && oldValue.text.contains(placeholder)) {
      return oldValue;
    }

    if (oldValue.text.contains(placeholder) &&
        !newValue.text.contains(placeholder)) {
      return oldValue;
    }

    if (oldValue.text.contains(placeholder) && newValue.text.contains('{') ||
        newValue.text.contains('}')) {
      int oldPlaceholderStart = oldValue.text.indexOf(placeholder);
      int oldPlaceholderEnd = oldPlaceholderStart + placeholder.length;

      if (oldValue.selection.start >= oldPlaceholderStart &&
          oldValue.selection.start <= oldPlaceholderEnd) {
        // نتأكد إن {number} لسه موجودة كاملة
        if (!newValue.text.contains(placeholder)) {
          return oldValue;
        }
      }
    }

    return newValue;
  }
}
