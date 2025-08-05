import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/enum/app_enum.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/tran_model.dart';
import 'package:yay_thant/pages/home/service/water_transport/add_and_edit_water_tran_page.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';

class WaterTransportListPage extends StatefulWidget {
  const WaterTransportListPage({super.key});

  @override
  State<WaterTransportListPage> createState() => _WaterTransportListPageState();
}

class _WaterTransportListPageState extends State<WaterTransportListPage> {
  bool isFilterOpen = true;
  bool _loading = false;
  final _provider = Functionprovider();
  // filter date
  FilterDateEnum dateFilterValue = FilterDateEnum.today;
  String dateFilterValueText = FilterDateEnum.today.name;
  List<TranModel> allWaterTranList = [];
  List<TranModel> waterTranList = [];

  getAllTransports() async {
    setState(() {
      _loading = true;
    });
    await _provider.checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllTran().then((trans) {
          response(trans);
        });
      }
    });
    setState(() {
      _loading = false;
    });
  }

  getTransportsByDate(String date) async {
    setState(() {
      _loading = true;
    });
    await _provider.checkInternetConnection().then((result) async {
      if (result) {
        await API().getTranByDate(date).then((trans) {
          response(trans);
        });
      }
    });
    setState(() {
      _loading = false;
    });
  }

  getTransportsByDateRange(String fromDate, String toDate) async {
    setState(() {
      _loading = true;
    });
    await _provider.checkInternetConnection().then((result) async {
      if (result) {
        await API().getTranByDateRange(fromDate, toDate).then((trans) {
          response(trans);
        });
      }
    });
    setState(() {
      _loading = false;
    });
  }

  response(trans) {
    allWaterTranList = List.from(trans);
    waterTranList = List.from(trans);
  }

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
      final fromDate = _provider.showDateAsDDMMYYYY(dateRange.start);
      final toDate = _provider.showDateAsDDMMYYYY(dateRange.end);
      if (fromDate == toDate) {
        dateFilterValueText = fromDate;
      } else {
        dateFilterValueText = "$fromDate - $toDate";
      }
      final fromDateAPI = _provider.showDateAsYYYYMMDD(dateRange.start);
      final toDateAPI = _provider.showDateAsYYYYMMDD(dateRange.end);
      getTransportsByDateRange(fromDateAPI, toDateAPI);
    } else {
      dateFilterValueText = _provider.showDateAsDDMMYYYY(DateTime.now());
      getTransportsByDate(_provider.showDateAsYYYYMMDD(DateTime.now()));
    }
    setState(() {});
  }

  initData() {
    getTransportsByDate(_provider.showDateAsYYYYMMDD(DateTime.now()));
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
        title: "tran_route",
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
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       isFilterOpen = !isFilterOpen;
        //       setState(() {});
        //     },
        //     child: Center(
        //       child: Padding(
        //         padding: const EdgeInsets.only(right: 15),
        //         child: Icon(
        //           Icons.filter_list,
        //           color: primaryColor,
        //           size: 25,
        //         ),
        //       ),
        //     ),
        //   )
        // ],
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
                      getTransportsByDate(
                          _provider.showDateAsYYYYMMDD(DateTime.now()));
                    } else if (dateFilterValue.value == 1) {
                      getTransportsByDate(_provider.showDateAsYYYYMMDD(
                          DateTime.now().subtract(Duration(days: 1))));
                    } else if (dateFilterValue.value == 2) {
                      _showDateRangePicker();
                    } else if (dateFilterValue.value == 3) {
                      getAllTransports();
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
        child: _loading
            ? Center(
                child: SpinKitRing(
                  color: primaryColor,
                  lineWidth: 5,
                  size: 40,
                ),
              )
            : waterTranList.isEmpty
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
                            itemCount: waterTranList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  final isSuccess = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddAndEditWaterTranPage(
                                        title: "update_water_tran",
                                        editTranData: waterTranList[index],
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    if (isSuccess != null && isSuccess) {
                                      if (dateFilterValue.value == 0) {
                                        getTransportsByDate(
                                            _provider.showDateAsYYYYMMDD(
                                                DateTime.now()));
                                      } else if (dateFilterValue.value == 1) {
                                        getTransportsByDate(_provider
                                            .showDateAsYYYYMMDD(DateTime.now()
                                                .subtract(Duration(days: 1))));
                                      } else if (dateFilterValue.value == 2) {
                                        _showDateRangePicker();
                                      } else if (dateFilterValue.value == 3) {
                                        getAllTransports();
                                      }
                                    }
                                  });
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
                                              "Delivery Man: ${waterTranList[index].deliveryMan!.name}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              "Route: ${waterTranList[index].route!.title}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF374151),
                                              ),
                                            ),
                                            Text(
                                              "Date: ${_provider.showDateAsDDMMYYYY(waterTranList[index].createdAt!)}",
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
      floatingActionButton: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: primaryColor),
        child: GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAndEditWaterTranPage(
                  title: "create_water_tran",
                ),
              ),
            );
            setState(() {
              if (result == true) {
                if (dateFilterValue.value == 0) {
                  getTransportsByDate(
                      _provider.showDateAsYYYYMMDD(DateTime.now()));
                } else if (dateFilterValue.value == 1) {
                  getTransportsByDate(_provider.showDateAsYYYYMMDD(
                      DateTime.now().subtract(Duration(days: 1))));
                } else if (dateFilterValue.value == 2) {
                  _showDateRangePicker();
                } else if (dateFilterValue.value == 3) {
                  getAllTransports();
                }
              }
            });
          },
          child: Center(
              child: Icon(
            Icons.add,
            size: 25,
            color: Colors.white,
          )),
        ),
      ),
    );
  }
}
