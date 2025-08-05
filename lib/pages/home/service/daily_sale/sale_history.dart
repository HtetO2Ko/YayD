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
import 'package:yay_thant/models/sale_response_model.dart';
import 'package:yay_thant/pages/home/service/daily_sale/sale_detail.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';

class SaleHistoryPage extends StatefulWidget {
  const SaleHistoryPage({super.key});

  @override
  State<SaleHistoryPage> createState() => _SaleHistoryPageState();
}

class _SaleHistoryPageState extends State<SaleHistoryPage> {
  final _provider = Functionprovider();
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();
  FilterDateEnum dateFilterValue = FilterDateEnum.today;
  String dateFilterValueText = FilterDateEnum.today.name;
  List<SaleModel> allSaleList = [];
  List<SaleModel> saleList = [];
  Map<String, dynamic> userData = {};
  String? deliManId;

  //// api calling
  getAllSale() async {
    setState(() {
      _loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllSale().then((trans) {
          response(trans);
        });
      }
    });
    setState(() {
      _loading = false;
      filterItemList();
    });
  }

  getSaleByDate(String date) async {
    setState(() {
      _loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getSaleByDate(date, deliManId).then((trans) {
          response(trans);
        });
      }
    });
    setState(() {
      _loading = false;
      filterItemList();
    });
  }

  getSaleByDateRange(String fromDate, String toDate) async {
    setState(() {
      _loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getSaleByDateRange(fromDate, toDate).then((trans) {
          response(trans);
        });
      }
    });
    setState(() {
      _loading = false;
      filterItemList();
    });
  }

  response(List trans) {
    if(trans.isNotEmpty){
      allSaleList = List.from(trans);
      saleList = List.from(trans);
    }
  }

  void filterItemList() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      saleList = allSaleList
          .where((item) => item.customer!.name!.toLowerCase().contains(query))
          .toList();
    });
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
      getSaleByDateRange(fromDateAPI, toDateAPI);
    } else {
      dateFilterValueText = _provider.showDateAsDDMMYYYY(DateTime.now());
      getSaleByDate(_provider.showDateAsYYYYMMDD(DateTime.now()));
    }
    setState(() {});
  }

  initData() {
    userData = dataconfig.getCurrentUserData();
    if (userData["role"] == 0) {
      deliManId = userData["_id"];
      getSaleByDate(_provider.showDateAsYYYYMMDD(DateTime.now()));
    } else {
      getSaleByDate(_provider.showDateAsYYYYMMDD(DateTime.now()));
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
      appBar: userData["role"] == 0 ? deliManAppBar() : adminAppBar(),
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
            : saleList.isEmpty
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
                        //// retail sale list
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: saleList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SaleDetailPage(
                                                saleData: saleList[index],
                                              )));
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
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${saleList[index].customer!.name}",
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                saleList[index].saleBy == null
                                                    ? Container()
                                                    : Text(
                                                        "Delivery Man: ${saleList[index].saleBy!.name}",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                              0xFF374151),
                                                        ),
                                                      ),
                                                Text(
                                                  "Route: ${saleList[index].customer!.route!.title}",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        const Color(0xFF374151),
                                                  ),
                                                ),
                                                // Text(
                                                //   "Date: ${_provider.showDateAsDDMMYYYY(saleList[index].createdAt!)}",
                                                //   style: TextStyle(
                                                //     fontSize: 13,
                                                //     fontWeight: FontWeight.w400,
                                                //     color:
                                                //         const Color(0xFF374151),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                            // Text(
                                            //   "${saleList[index].totalAmount}",
                                            //   style: TextStyle(
                                            //     fontWeight: FontWeight.w400,
                                            //     fontSize: 13,
                                            //     color: const Color(0xFF6B7280),
                                            //   ),
                                            // ),
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
                        userData["role"] == 0
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                              )
                            : SizedBox(
                                height: 30,
                              ),
                      ],
                    ),
                  ),
      ),
    );
  }

  PreferredSizeWidget? adminAppBar() {
    return customAppBar(
      titleSpacing: 10,
      title: "sale_history",
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
        preferredSize: Size.fromHeight(50),
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
                    getSaleByDate(_provider.showDateAsYYYYMMDD(DateTime.now()));
                  } else if (dateFilterValue.value == 1) {
                    getSaleByDate(_provider.showDateAsYYYYMMDD(
                        DateTime.now().subtract(Duration(days: 1))));
                  } else if (dateFilterValue.value == 2) {
                    _showDateRangePicker();
                  } else if (dateFilterValue.value == 3) {
                    getAllSale();
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
    );
  }

  PreferredSizeWidget? deliManAppBar() {
    return customAppBar(
      titleSpacing: 10,
      title: "sale_history",
    );
  }
}
