import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/models/summary_sale_count_model.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';

class SummaryReportPage extends StatefulWidget {
  const SummaryReportPage({super.key});

  @override
  State<SummaryReportPage> createState() => _SummaryReportPageState();
}

class _SummaryReportPageState extends State<SummaryReportPage> {
  // data
  Map<String, dynamic> fromToDate = {};
  Map<String, dynamic> saleCount = {
    "totalCustomers": 0,
    "totalProductQty": 0,
    "totalReturnProductQty": 0,
    "totalProductAmount": 0,
  };
  List productList = [];
  // apis
  bool chartLoading = false;
  List<SummarySaleCountModel> chartSaleList = [];
  int maxChartSaleListCount = 0;

  getChartSaleCount() async {
    setState(() {
      chartLoading = true;
    });

    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getChartSaleCount(fromToDate).then((chartSale) {
          chartSaleList = chartSale;
          for (SummarySaleCountModel chartSale in chartSaleList) {
            if (chartSale.saleCount! > maxChartSaleListCount) {
              maxChartSaleListCount = chartSale.saleCount!;
            }
          }
        });
      }
    });
    setState(() {
      chartLoading = false;
    });
  }

  getSaleDateRangeCount() async {
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        var result = await API().getSaleDateRangeCountandProList(fromToDate);
        saleCount = result["saleCount"];
        productList = result["productList"];
        setState(() {});
      }
    });
  }

  fromToDateFun(String fromToTxt) {
    String fromTo = "";
    if (fromToTxt == "from") {
      fromTo = provider.showDateAsDDMMYYYY(DateTime.parse(fromToDate["from"]));
    } else {
      fromTo = provider.showDateAsDDMMYYYY(DateTime.parse(fromToDate["to"]));
    }
    return fromTo;
  }

  getPrice() {
    return provider.showPriceAsThousandSeparator(
      int.parse(saleCount["totalProductAmount"].toString()),
    );
  }

  initData() {
    fromToDate = provider.getLastSixDaysFromTo();
    getChartSaleCount();
    getSaleDateRangeCount();
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
        title: "summary",
        titleStyle: TextStyle(
          color: const Color(0xFF1D1F1F),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titlePadding: const EdgeInsets.only(left: 18, top: 10),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 10, bottom: 10),
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "From ${fromToDateFun('from')} To ${fromToDateFun('to')}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "${"stock_type".tr()} (${productList.length})",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                productList[index]["product"]["title"]
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                productList[index]["qty"].toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 350,
            color: Colors.white,
            // margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            child: chartLoading
                ? SpinKitRing(
                    color: primaryColor,
                    lineWidth: 4,
                    size: 30,
                  )
                : BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBorder: BorderSide(
                            color: primaryColor,
                            width: 0.5,
                          ),
                          getTooltipColor: (group) => Colors.white,
                        ),
                      ),
                      // backgroundColor: primaryColor,
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(width: 1),
                          bottom: BorderSide(width: 1),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            interval: maxChartSaleListCount < 10 ? 2 : null,
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            reservedSize: 50,
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < chartSaleList.length) {
                                return RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    provider.showDateAsddMMM(DateTime.parse(
                                        chartSaleList[index].date.toString())),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                      ),
                      barGroups: chartSaleList.asMap().entries.map((chart) {
                        int index = chart.key;
                        double value =
                            double.parse(chart.value.saleCount.toString());
                        // return BarChartGroupData(
                        //   x: index,
                        //   barRods: [
                        //     BarChartRodData(
                        //       toY: value,
                        //       color: Colors.blue,
                        //       width: 16,
                        //       borderRadius: BorderRadius.circular(4),
                        //     ),
                        //   ],
                        // );
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              // toY: index == 0 ? 10.0 : value,
                              toY: value,
                              width: 30,
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ],
                        );
                      }).toList(),
                      // barGroups: [
                      //   BarChartGroupData(
                      //     x: 0,
                      //     barRods: [
                      //       BarChartRodData(
                      //         toY: 5,
                      //         width: 30,
                      //         color: Colors.blue,
                      //         borderRadius: BorderRadius.circular(0),
                      //       ),
                      //     ],
                      //   ),
                      //   BarChartGroupData(
                      //     x: 1,
                      //     barRods: [
                      //       BarChartRodData(
                      //         toY: 10,
                      //         width: 30,
                      //         color: Colors.blue,
                      //         borderRadius: BorderRadius.circular(0),
                      //       ),
                      //     ],
                      //   ),
                      //   BarChartGroupData(
                      //     x: 2,
                      //     barRods: [
                      //       BarChartRodData(
                      //         toY: 15,
                      //         width: 30,
                      //         color: Colors.blue,
                      //         borderRadius: BorderRadius.circular(0),
                      //       ),
                      //     ],
                      //   ),
                      //   BarChartGroupData(
                      //     x: 3,
                      //     barRods: [
                      //       BarChartRodData(
                      //         toY: 20,
                      //         width: 30,
                      //         color: Colors.blue,
                      //         borderRadius: BorderRadius.circular(0),
                      //       ),
                      //     ],
                      //   ),
                      //   BarChartGroupData(
                      //     x: 4,
                      //     barRods: [
                      //       BarChartRodData(
                      //         toY: 25,
                      //         width: 30,
                      //         color: Colors.blue,
                      //         borderRadius: BorderRadius.circular(0),
                      //       ),
                      //     ],
                      //   ),
                      //   BarChartGroupData(
                      //     x: 5,
                      //     barRods: [
                      //       BarChartRodData(
                      //         toY: 30,
                      //         width: 30,
                      //         color: Colors.blue,
                      //         borderRadius: BorderRadius.circular(0),
                      //       ),
                      //     ],
                      //   ),
                      //   BarChartGroupData(
                      //     x: 6,
                      //     barRods: [
                      //       BarChartRodData(
                      //         toY: 35,
                      //         width: 30,
                      //         color: Colors.blue,
                      //         borderRadius: BorderRadius.circular(0),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                    ),
                  ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
        ],
      ),
    );
  }
}
