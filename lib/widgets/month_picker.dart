import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yay_thant/constants/colors.dart';

class MonthPickerDialog extends StatefulWidget {
  const MonthPickerDialog({super.key});

  @override
  _MonthPickerDialogState createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  int selectedMonth = DateTime.now().month;
  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  void _submitSelection() {
    Navigator.pop(context, DateTime(DateTime.now().year, selectedMonth));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Select Month",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: primaryColor,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.only(left: 15, right: 15),
        width: MediaQuery.of(context).size.width,
        child: DropdownButton<int>(
          value: selectedMonth,
          items: List.generate(months.length, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text(
                months[index],
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            );
          }),
          isExpanded: true,
          underline: Container(),
          onChanged: (value) {
            setState(() {
              selectedMonth = value!;
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, DateTime(selectedMonth)),
          child: Text(
            "cancel".tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ),
        TextButton(
          onPressed: _submitSelection,
          child: Text(
            "OK",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
