import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget? customAppBar({
  String? title,
  TextStyle? titleStyle,
  double? leadingWidth,
  bool? centerTitle,
  Widget? leading,
  List<Widget>? actions,
  EdgeInsetsGeometry? titlePadding,
  PreferredSizeWidget? bottom,
  double? titleSpacing,
}) {
  return AppBar(
    leadingWidth: leadingWidth ?? 40,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    foregroundColor: Colors.white,
    titleSpacing: titleSpacing ?? 0,
    leading: leading,
    automaticallyImplyLeading: false,
    centerTitle: centerTitle ?? false,
    title: Padding(
      padding: titlePadding ?? const EdgeInsets.all(0),
      child: Text(
        title?.tr() ?? "",
        style: titleStyle ??
            const TextStyle(
              color: Color(0xFF1D1F1F),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
      ),
    ),
    actions: actions,
    bottom: bottom,
  );
}
