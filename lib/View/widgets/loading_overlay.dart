import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_caller/utils/Services/hive_service.dart';
import 'package:auto_caller/utils/constants/app_colors.dart';
import 'package:auto_caller/utils/constants/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.currentIndex,
  });

  final ValueNotifier<bool> isLoading;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, loading, _) {
        if (!loading) return const SizedBox.shrink();

        return Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(30.w),
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80.w,
                        height: 80.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 6.w,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor.shade400,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.phone_in_talk,
                        size: 35.sp,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Calling...",
                    style: AppConstants.loadingOverlayTitleTextStyle.copyWith(
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ValueListenableBuilder(
                    valueListenable: HiveService.numbersBox.listenable(),
                    builder: (context, box, _) {
                      final number = HiveService.getNumberAt(currentIndex);
                      if (number != null) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            number.toString(),
                            style: AppConstants.loadingOverlayNumberTextStyle
                                .copyWith(
                                  color: AppColors.primaryColor.shade700,
                                  fontSize: 16.sp,
                                ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
