import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yay_thant/pages/administration/overdue/overdue_list_page.dart';
import 'package:yay_thant/pages/home/delivery_man_list_page.dart';
import 'package:yay_thant/pages/home/service/customers/customer_list_page.dart';
import 'package:yay_thant/pages/home/service/customers/deleted_customer_page.dart';
import 'package:yay_thant/pages/administration/items/item_list_page.dart';
import 'package:yay_thant/pages/administration/route/route_list_page.dart';
import 'package:yay_thant/pages/home/service/daily_sale/sale_history.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/pages/administration/user/user_list_page.dart';

class AdministrationPage extends StatefulWidget {
  const AdministrationPage({super.key});

  @override
  State<AdministrationPage> createState() => _AdministrationPageState();
}

class _AdministrationPageState extends State<AdministrationPage> {
  var homepadding =
      const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12);
  TextStyle headerTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.black,
  );

  // summary card
  List summaryCard = [
    {
      'name': 'deliver_water_list',
      'icon': "assets/icons/water-summary.svg",
      'page': 'DeliverWaterListPage',
    },
    {
      'name': 'debt_list',
      'icon': "assets/icons/overdue.svg",
      'page': 'DebtListPage',
    },
    {
      'name': 'without_loc_cuslist',
      'icon': "assets/icons/without-loc.svg",
      'page': 'WithoutLocCusListPage',
    },
    {
      'name': 'same_loc_cuslist',
      'icon': "assets/icons/add-location.svg",
      'page': 'SameLocCusListPage',
    },
  ];

  //// service
  List servicecard = [
    {
      'name': 'stock_type',
      'icon': "assets/icons/stock.svg",
      'page': 'StockTypePage',
    },
    {
      'name': 'users',
      'icon': "assets/icons/add-user.svg",
      'page': 'AddNewUserPage',
    },
    {
      'name': 'add_new_route',
      'icon': "assets/icons/route.svg",
      'page': 'AddNewRoutePage',
    },
    {
      'name': 'deleted_customer_list',
      'icon': "assets/icons/user-list.svg",
      'page': 'DeletedCustomerListPage',
    },
  ];

  //// function
  getSummaryPage(page) {
    // CustomerListPage
    if (page == 'DebtListPage') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OverdueListPage(),
        ),
      );
    } else if (page == 'DeliverWaterListPage') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SaleHistoryPage(),
        ),
      );
    } else if (page == 'WithoutLocCusListPage') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerListPage(
            fromPage: 'without',
          ),
        ),
      );
    } else if (page == 'SameLocCusListPage') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerListPage(
            fromPage: 'same',
          ),
        ),
      );
    } else {
      print("Can't find the page");
    }
  }

  getServicePage(page) {
    if (page == 'StockTypePage') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ItemListPage()));
    } else if (page == 'AddNewUserPage') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserListPage()));
    } else if (page == 'AddNewRoutePage') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RouteListPage()));
    } else if (page == 'DeletedCustomerListPage') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DeletedCustomerListPage()));
    } else {
      print("Can't find the page");
    }
  }

  initData() {
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
        title: "administration",
        titleStyle: TextStyle(
          color: const Color(0xFF1D1F1F),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titlePadding: const EdgeInsets.only(left: 18, top: 10),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ////
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryManListPage(
                      deliveryManList: null,
                      fromPage: "admin",
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "bottled_water_delivery_man_list".tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: headerTextStyle,
                    ),
                    Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //// summary
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              padding: homepadding,
              margin: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('summary'.tr(), style: headerTextStyle),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    padding: const EdgeInsets.only(top: 13),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: List.generate(summaryCard.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            getSummaryPage(summaryCard[index]["page"]);
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  summaryCard[index]['icon'],
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${summaryCard[index]['name']}'.tr(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )),
                      );
                    }),
                  ),
                ],
              ),
            ),
            //// service
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              padding: homepadding,
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('services'.tr(), style: headerTextStyle),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    padding: const EdgeInsets.only(top: 13),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: List.generate(servicecard.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            getServicePage(servicecard[index]['page']);
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  servicecard[index]['icon'],
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${servicecard[index]['name']}'.tr(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // space
            SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
