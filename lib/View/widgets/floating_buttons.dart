import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_caller/utils/Services/hive_service.dart';
import 'package:auto_caller/utils/constants/app_colors.dart';
import 'package:auto_caller/utils/constants/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingButtons extends StatelessWidget {
  const FloatingButtons({
    super.key,
    required this.onAddNumber,
    required this.isProcessRunning,
    required this.onStartAll,
  });

  final VoidCallback onAddNumber;
  final bool isProcessRunning;
  final VoidCallback onStartAll;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.numbersBox.listenable(),
      builder: (context, box, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Add Number Button (Always visible)
            // Start All Button (Only when has numbers and not running)
            if (HiveService.hasNumbers && !isProcessRunning)
              FloatingActionButton.extended(
                onPressed: onStartAll,
                backgroundColor: AppColors.primaryColor,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  "Start All",
                  style: AppConstants.fabTextStyle.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                heroTag: "start",
              ),
            SizedBox(height: 10.h),

            FloatingActionButton.extended(
              onPressed: onAddNumber,
              backgroundColor: AppColors.accentColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                "Add Number",
                style: AppConstants.fabTextStyle.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
              heroTag: "add",
            ),
          ],
        );
      },
    );
  }
}
