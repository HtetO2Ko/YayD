import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yay_thant/constants/textstyle.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final void Function(String) onChanged;
  final void Function(String) onSubmitted;
  final EdgeInsetsGeometry? margin;
  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.obscureText,
    required this.onChanged,
    required this.onSubmitted,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      height: 40,
      alignment: Alignment.center,
      margin: margin ?? const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: TextField(
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        obscureText: obscureText,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          hintText: hintText!.tr(),
          hintStyle: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
        ),
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}

class CustomTextfieldWithLabel extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final void Function(String) onChanged;
  final void Function(String) onSubmitted;
  final EdgeInsetsGeometry? margin;
  final String? label;
  final EdgeInsetsGeometry? labelMargin;
  final int? maxLine;
  final double? textFieldHeight;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatter;
  final bool? enabled;
  final Function()? onTap;
  const CustomTextfieldWithLabel({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.obscureText,
    required this.onChanged,
    required this.onSubmitted,
    this.margin,
    required this.label,
    this.labelMargin,
    this.maxLine,
    this.textFieldHeight,
    this.keyboardType,
    this.inputFormatter,
    this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: labelMargin ?? const EdgeInsets.only(left: 10, bottom: 5),
          child: Text(
            label!.tr(),
            style: labelTextStyle,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          height: textFieldHeight ?? 40,
          alignment: Alignment.center,
          margin:
              margin ?? const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: GestureDetector(
            onTap: onTap,
            child: TextField(
              controller: controller,
              textAlignVertical: TextAlignVertical.center,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatter,
              autofocus: false,
              enabled: enabled ?? true,
              maxLines: maxLine ?? 1,
              decoration: InputDecoration(
                suffixIcon: suffixIcon,
                prefixIcon: prefixIcon,
                hintText: hintText!.tr(),
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ),
      ],
    );
  }
}
