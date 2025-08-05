import 'package:flutter/cupertino.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/textstyle.dart';

class CustomSwitch extends StatelessWidget {
  final bool switchValue;
  final String labelText;
  final void Function(bool) onChanged;
  const CustomSwitch({
    super.key,
    required this.switchValue,
    required this.labelText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, top: 5, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            labelText,
            style: labelTextStyle,
          ),
          CupertinoSwitch(
            value: switchValue,
            activeColor: primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
