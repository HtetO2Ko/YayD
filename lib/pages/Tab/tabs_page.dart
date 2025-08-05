import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/pages/administration/administration_page.dart';
import 'package:yay_thant/pages/home/deliveryman_home_page.dart';
import 'package:yay_thant/pages/home/home_page.dart';
import 'package:yay_thant/pages/home/map_page.dart';
import 'package:yay_thant/pages/home/service/daily_sale/sale_history.dart';
import 'package:yay_thant/pages/home/service/retail_sale/retail_sale_list_page.dart';
import 'package:yay_thant/pages/more/morepage.dart';
import 'package:yay_thant/pages/tab/summary_report_page.dart';

class TabsPage extends StatefulWidget {
  final int currentIndex;
  final List tabsList;
  const TabsPage({
    super.key,
    required this.currentIndex,
    required this.tabsList,
  });

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int selectedIndex = 1;

  _page() {
    if (selectedIndex == 1) {
      return const HomePage();
    } else if (selectedIndex == 2) {
      return SummaryReportPage();
    } else if (selectedIndex == 3) {
      return const AdministrationPage();
    } else if (selectedIndex == 4) {
      return const MorePage();
    }
  }

  _delimanpage() {
    if (selectedIndex == 1) {
      return const DeliveryManHomePage();
    } else if (selectedIndex == 2) {
      return MapPage(isFromTab: true,);
    } else if (selectedIndex == 3) {
      return const SaleHistoryPage();
    } else if (selectedIndex == 4) {
      return RetailSaleListPage();
    } else if (selectedIndex == 5) {
      return const MorePage();
    }
  }

  @override
  void initState() {
    setState(() {
      selectedIndex = int.parse(widget.currentIndex.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: isDeliveryMan ? _delimanpage() : _page(),
        bottomSheet: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.tabsList.length,
            (index) {
              return Expanded(
                child: Container(
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: () {
                      selectedIndex = widget.tabsList[index]["id"];
                      setState(() {});
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      margin: 
                      Platform.isIOS
                          ? const EdgeInsets.only(bottom: 20)
                          : 
                          const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                (selectedIndex == widget.tabsList[index]['id'])
                                    ? primaryColor
                                    : const Color(0xFF607B8B),
                            width:
                                (selectedIndex == widget.tabsList[index]['id'])
                                    ? 2
                                    : 0.3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            widget.tabsList[index]["icon"],
                            width: widget.tabsList[index]['id'] == 1 ? 18 : 20,
                            height: widget.tabsList[index]['id'] == 1 ? 18 : 20,
                            colorFilter: ColorFilter.mode(
                                (selectedIndex == widget.tabsList[index]['id'])
                                    ? primaryColor
                                    : const Color(0xFF607B8B),
                                BlendMode.srcIn),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            "${widget.tabsList[index]["name"]}".tr(),
                            style: TextStyle(
                              color: (selectedIndex ==
                                      widget.tabsList[index]['id'])
                                  ? primaryColor
                                  : const Color(0xFF607B8B),
                              fontSize: 10,
                              fontWeight: (selectedIndex ==
                                      widget.tabsList[index]['id'])
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
