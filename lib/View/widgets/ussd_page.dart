import 'package:auto_caller/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DialogButton extends StatelessWidget {
  const DialogButton({super.key, 
    required this.label,
    required this.onPressed,
    this.color,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primaryColor;
    
    return isOutlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: buttonColor,
              side: BorderSide(color: buttonColor, width: 2),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          );
  }
}
