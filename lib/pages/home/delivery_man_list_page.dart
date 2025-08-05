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
import 'package:yay_thant/models/user_model.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/month_picker.dart';

class DeliveryManListPage extends StatefulWidget {
  final List<UserModel>? deliveryManList;
  final String? fromPage;
  const DeliveryManListPage({
    super.key,
    required this.deliveryManList,
    this.fromPage,
  });

  @override
  State<DeliveryManListPage> createState() => _DeliveryManListPageState();
}

class _DeliveryManListPageState extends State<DeliveryManListPage> {
  bool _loading = false;
  FilterDateEnum dateFilterValue = FilterDateEnum.today;
  String dateFilterValueText = FilterDateEnum.today.name;
  String fromPage = "";
  // apis data
  List<UserModel> deliveryManList = [];

  // apis
  getDeliveryManList(day) async {
    setState(() {
      _loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        deliveryManList = await API().getDeliveryManListByDay(day);
      }
    });
    setState(() {
      _loading = false;
    });
  }

  getDeliveryManListByMonth(month) async {
    setState(() {
      _loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        deliveryManList = await API().getDeliveryManListByMonth(month);
      }
    });
    setState(() {
      _loading = false;
    });
  }

  getDeliveryManListByDateRange(fromDate, toDate) async {
    setState(() {
      _loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        deliveryManList =
            await API().getDeliveryManListByDateRange(fromDate, toDate);
      }
    });
    setState(() {
      _loading = false;
    });
  }

  getAllDeliveryManList() async {
    setState(() {
      _loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        deliveryManList = await API().getAllDeliveryManList();
      }
    });
    setState(() {
      _loading = false;
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
      getDeliveryManListByDateRange(fromDateAPI, toDateAPI);
    } else {
      dateFilterValueText = provider.showDateAsDDMMYYYY(DateTime.now());
      getDeliveryManList(
        provider.showDateAsYYYYMMDD(DateTime.now()),
      );
    }
    setState(() {});
  }

  Future<void> _showMonthPicker() async {
    final DateTime? pickedDate = await showDialog(
      context: context,
      builder: (context) => MonthPickerDialog(),
    );

    if (pickedDate != null) {
      getDeliveryManListByMonth(pickedDate.month);
      dateFilterValueText = DateFormat("MMMM").format(pickedDate);
    }
    setState(() {});
  }

  initData() {
    if (widget.fromPage != null) {
      fromPage = widget.fromPage!;
    }
    if (widget.deliveryManList == null) {
      getDeliveryManList(provider.showDateAsYYYYMMDD(DateTime.now()));
    } else {
      deliveryManList = widget.deliveryManList!;
    }
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
        title: "bottled_water_delivery_man_list",
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
        bottom: fromPage == ""
            ? null
            : PreferredSize(
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
                          value: FilterDateEnum.month,
                          child: Text(
                            FilterDateEnum.month.name,
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
                            getDeliveryManList(
                              provider.showDateAsYYYYMMDD(DateTime.now()),
                            );
                          } else if (dateFilterValue.value == 1) {
                            getDeliveryManList(
                              provider.showDateAsYYYYMMDD(
                                DateTime.now().subtract(
                                  Duration(days: 1),
                                ),
                              ),
                            );
                          } else if (dateFilterValue.value == 2) {
                            _showDateRangePicker();
                          } else if (dateFilterValue.value == 3) {
                            getAllDeliveryManList();
                          } else if (dateFilterValue.value == 4) {
                            // getDeliveryManListByMonth();
                            _showMonthPicker();
                          }
                        });
                      },
                      child: Container(
                        margin:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
        child: _loading
            ? Center(
                child: SpinKitRing(
                  color: primaryColor,
                  lineWidth: 5,
                  size: 40,
                ),
              )
            : deliveryManList.isEmpty
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
                        //// tran list
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: deliveryManList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {},
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
                                              deliveryManList[index].name!,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            if (deliveryManList[index].phone !=
                                                    null ||
                                                deliveryManList[index].phone !=
                                                    "")
                                              Text(
                                                "Phone Number: ${deliveryManList[index].phone}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      const Color(0xFF374151),
                                                ),
                                              ),
                                            if (deliveryManList[index].email !=
                                                    null ||
                                                deliveryManList[index].email !=
                                                    "")
                                              Text(
                                                "Email: ${deliveryManList[index].email}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      const Color(0xFF374151),
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
}
