import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final bool isLoading;
  final void Function() onTap;
  final EdgeInsetsGeometry? margin;
  final Color? buttonColor;
  const CustomButton({
    super.key,
    required this.buttonText,
    required this.isLoading,
    required this.onTap,
    this.margin,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: buttonColor ?? primaryColor,
          borderRadius: BorderRadius.circular(5),
        ),
        margin: margin ?? const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Center(
          child: isLoading
              ? const SpinKitRing(
                  color: Colors.white,
                  size: 20,
                  lineWidth: 3,
                )
              : Text(
                  buttonText.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
