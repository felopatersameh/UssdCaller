import 'package:flutter/material.dart';
import 'package:auto_caller/utils/constants/app_colors.dart';
import 'package:auto_caller/utils/constants/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.shade200,
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.code, color: Colors.white, size: 26.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  "USSD Template",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextFormField(
                inputFormatters: [
                  _ProtectPlaceholderFormatter()
                ],
                controller: templateController,
                onChanged: onChanged,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  // labelText: "USSD Code",
                  hintText: "*9*{number}*50#",
                  hintStyle: TextStyle(color: AppColors.hintTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.phone_callback,
                    color: AppColors.primaryColor,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                ),
                style: AppConstants.ussdTemplateTextStyle.copyWith(
                  fontSize: 14.sp,
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16.sp,
                    color: Colors.white70,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Use {number} as placeholder for phone numbers",
                      style: AppConstants.infoTextStyle.copyWith(
                        fontSize: 10.sp,
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
class _ProtectPlaceholderFormatter extends TextInputFormatter {
  static const String placeholder = '{number}';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // لو النص الجديد فاضي والقديم فيه {number}
    if (newValue.text.isEmpty && oldValue.text.contains(placeholder)) {
      return oldValue;
    }

    // لو {number} موجودة في القديم ومش موجودة في الجديد
    if (oldValue.text.contains(placeholder) && !newValue.text.contains(placeholder)) {
      return oldValue;
    }

    // لو المستخدم حاول يعدل جوا {number}
    if (oldValue.text.contains(placeholder)) {
      final oldPlaceholderStart = oldValue.text.indexOf(placeholder);
      final oldPlaceholderEnd = oldPlaceholderStart + placeholder.length;

      // لو الـ cursor جوا الـ placeholder
      if (oldValue.selection.start >= oldPlaceholderStart &&
          oldValue.selection.start <= oldPlaceholderEnd) {
        if (!newValue.text.contains(placeholder)) {
          return oldValue;
        }
      }
    }

    return newValue;
  }
}