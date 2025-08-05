import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/enum/app_enum.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/overdue_model.dart';
import 'package:yay_thant/models/overdue_update_model.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class OverdueListPage extends StatefulWidget {
  const OverdueListPage({super.key});

  @override
  State<OverdueListPage> createState() => _OverdueListPageState();
}

class _OverdueListPageState extends State<OverdueListPage> {
  //
  bool loading = false;
  // data
  FilterDateEnum dateFilterValue = FilterDateEnum.today;
  String dateFilterValueText = FilterDateEnum.today.name;
  List<OverDueModel> overDueList = [];
  final TextEditingController _updatePaidAmountCtrl = TextEditingController();

  // apis
  Future<void> getOverDueList() async {
    setState(() {
      loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllOverDue().then((overDues) {
          if (overDues.isNotEmpty) {
            overDueList = overDues;
          }
        });
      }
    });
    setState(() {
      print(">>>> overdue list $overDueList");
      loading = false;
    });
  }

  Future<void> getOverDueListByDateRange(fromDate, toDate) async {
    setState(() {
      loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllOverDueByDateRange(fromDate, toDate).then((overDues) {
          if (overDues.isNotEmpty) {
            overDueList = overDues;
          }
        });
      }
    });
    setState(() {
      print(">>>> overdue list $overDueList");
      loading = false;
    });
  }

  //
  Future<void> _showDateRangePicker() async {
    final result = await showCalendarDatePicker2Dialog(
      context: context,
      config: buildCalendarDialogConfig(),
      dialogSize: const Size(325, 370),
      borderRadius: BorderRadius.circular(15),
      value: [DateTime.now(), DateTime.now()],
      dialogBackgroundColor: Colors.white,
    );
    if (result != null) {
      final startDate = result[0];
      final endDate = result.length > 1 ? result[1] : startDate;
      final dateRange = DateTimeRange(start: startDate!, end: endDate!);
      final fromDate = provider.showDateAsDDMMYYYY(dateRange.start);
      final toDate = provider.showDateAsDDMMYYYY(dateRange.end);
      if (fromDate == toDate) {
        dateFilterValueText = fromDate;
      } else {
        dateFilterValueText = "$fromDate - $toDate";
      }
      final fromDateAPI = provider.showDateAsYYYYMMDD(dateRange.start);
      final toDateAPI = provider.showDateAsYYYYMMDD(dateRange.end);
      getOverDueListByDateRange(fromDateAPI, toDateAPI);
    } else {
      dateFilterValueText = provider.showDateAsDDMMYYYY(DateTime.now());
      getOverDueListByDateRange(provider.showDateAsYYYYMMDD(DateTime.now()),
          provider.showDateAsYYYYMMDD(DateTime.now()));
    }
    setState(() {});
  }

  initData() {
    getOverDueListByDateRange(provider.showDateAsYYYYMMDD(DateTime.now()),
        provider.showDateAsYYYYMMDD(DateTime.now()));
    setState(() {});
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "debt_list",
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 20,
            color: Color(0xFF1D1F1F),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PopupMenuButton(
                color: Colors.white,
                position: PopupMenuPosition.under,
                initialValue: dateFilterValue,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: FilterDateEnum.today,
                    child: Text(
                      FilterDateEnum.today.name,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  PopupMenuItem(
                    value: FilterDateEnum.yesterday,
                    child: Text(
                      FilterDateEnum.yesterday.name,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  PopupMenuItem(
                    value: FilterDateEnum.custom,
                    child: Text(
                      FilterDateEnum.custom.name,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  PopupMenuItem(
                    value: FilterDateEnum.all,
                    child: Text(
                      FilterDateEnum.all.name,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
                onSelected: (value) {
                  dateFilterValue = value;
                  dateFilterValueText = dateFilterValue.name;
                  setState(() {
                    if (dateFilterValue.value == 0) {
                      getOverDueListByDateRange(
                          provider.showDateAsYYYYMMDD(DateTime.now()),
                          provider.showDateAsYYYYMMDD(DateTime.now()));
                    } else if (dateFilterValue.value == 1) {
                      getOverDueListByDateRange(
                        provider.showDateAsYYYYMMDD(
                          DateTime.now().subtract(
                            Duration(days: 1),
                          ),
                        ),
                        provider.showDateAsYYYYMMDD(
                          DateTime.now().subtract(
                            Duration(days: 1),
                          ),
                        ),
                      );
                    } else if (dateFilterValue.value == 2) {
                      _showDateRangePicker();
                    } else if (dateFilterValue.value == 3) {
                      getOverDueList();
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                  ),
                  width: null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${"date".tr()}: $dateFilterValueText"),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        child: loading
            ? Center(
                child: SpinKitRing(
                  color: primaryColor,
                  lineWidth: 5,
                  size: 40,
                ),
              )
            : overDueList.isEmpty
                ? Center(
                    child: Text(
                      "no_data".tr(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //// overdue list
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: overDueList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  updateOverdue(overDueList[index].id!);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      color: const Color(0xFFFFFFFF),
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 8, 16, 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Customer: ${overDueList[index].customer!.name}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              "Price: ${overDueList[index].totalAmount}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF374151),
                                              ),
                                            ),
                                            Text(
                                              "Overdue Price: ${overDueList[index].balanceDue!}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF374151),
                                              ),
                                            ),
                                            Text(
                                              "Delivery Man: ${overDueList[index].saleBy!.name!}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF374151),
                                              ),
                                            ),
                                            Text(
                                              "Date: ${provider.showDateAsDDMMYYYY(overDueList[index].createdAt!)}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF374151),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Future updateOverdue(String id) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "update_overdue".tr(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomTextfieldWithLabel(
                    label: "enter_amt",
                    controller: _updatePaidAmountCtrl,
                    prefixIcon: null,
                    suffixIcon: null,
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {},
                    onSubmitted: (value) {},
                    hintText: '',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.5, color: Colors.grey),
                              borderRadius: BorderRadius.circular(5)),
                          alignment: Alignment.center,
                          child: Text("cancel".tr(),
                              style: TextStyle(color: primaryColor)),
                        ),
                        onTap: () {
                          _updatePaidAmountCtrl.clear();
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: primaryColor),
                          alignment: Alignment.center,
                          child: Text(
                            "update".tr(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () async {
                          showLoadingDialog(context);
                          await Functionprovider()
                              .checkInternetConnection()
                              .then((result) async {
                            if (result) {
                              var param = json.encode({
                                "updatedAmount":
                                    int.parse(_updatePaidAmountCtrl.text),
                              });
                              await API()
                                  .updateOverDue(id, param)
                                  .then((value) {
                                if (value != null) {
                                  OverDueUpdateModel overdueUpdate = value;
                                  print(">>>>> overdueUpdate ${overdueUpdate.balanceDue}");
                                  for (var overdue in overDueList) {
                                    if (overdue.id == overdueUpdate.id) {
                                      if (overdueUpdate.balanceDue != 0) {
                                        overdue.balanceDue =
                                            overdueUpdate.balanceDue;
                                      } else {
                                        overDueList
                                            .removeWhere((od) => od.id == overdue.id);
                                      }
                                      break;
                                    }
                                  }
                                  _updatePaidAmountCtrl.clear();
                                  setState(() {});
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pop(context);
                                }
                              });
                            }
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
