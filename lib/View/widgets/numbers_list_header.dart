import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_caller/utils/Services/hive_service.dart';
import 'package:auto_caller/utils/constants/app_colors.dart';
import 'package:auto_caller/utils/constants/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NumbersListHeader extends StatelessWidget {
  const NumbersListHeader({super.key, required this.onClearAll});

  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.numbersBox.listenable(),
      builder: (context, box, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    color: AppColors.primaryColor.shade700,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  "Phone Numbers (${HiveService.totalNumbers})",
                  style: AppConstants.numberListTitleTextStyle.copyWith(
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
            if (HiveService.hasNumbers)
              TextButton.icon(
                onPressed: onClearAll,
                icon: Icon(Icons.delete_sweep, size: 18.sp),
                label: Text("Clear All", style: TextStyle(fontSize: 14.sp)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
