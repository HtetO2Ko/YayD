import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/config/dataconfig.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/user_model.dart';
import 'package:yay_thant/pages/Tab/tabs_page.dart';
import 'package:yay_thant/pages/home/delivery_man_list_page.dart';
import 'package:yay_thant/pages/home/map_page.dart';
import 'package:yay_thant/pages/home/service/customers/add_and_edit_customer_page.dart';
import 'package:yay_thant/pages/home/service/customers/customer_list_page.dart';
import 'package:yay_thant/pages/home/service/retail_sale/retail_sale_list_page.dart';
import 'package:yay_thant/pages/home/service/water_transport/transport_page.dart';
import 'package:yay_thant/pages/home/service/water_transport/water_transport_list_page.dart';
import 'package:yay_thant/widgets/custom_avater.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var homepadding =
      const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12);
  TextStyle headerTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.black,
  );
  TextStyle titleTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF6B7280),
  );
  final _dataConfig = Dataconfig();
  final _provider = Functionprovider();

  //// userdata
  Map<String, dynamic> userData = {};

  //// Daily Overview
  String updatedTime = "";
  Map<String, dynamic> saleCount = {
    "totalCustomers": 0,
    "totalProductQty": 0,
    "totalReturnProductQty": 0,
    "totalProductAmount": 0,
  };

  //// service
  List servicecard = [
    {
      'name': 'map',
      'icon': "assets/icons/map.svg",
      'page': 'MapPage',
    },
    {
      'name': 'transport',
      'icon': "assets/icons/deliverytruck.svg",
      'page': 'TransportPage',
    },
    {
      'name': 'tran_route',
      'icon': "assets/icons/route.svg",
      'page': 'TranRoute()',
    },
    {
      'name': 'retail_sale',
      'icon': "assets/icons/retailsale.svg",
      'page': 'RetailSaleListPage()',
    },
    {
      'name': 'new_customer',
      'icon': "assets/icons/add-user.svg",
      'page': 'NewCustomer()',
    },
    {
      'name': 'customer_list',
      'icon': "assets/icons/user-list.svg",
      'page': 'CustomerList()',
    },
  ];

  //// bottledWaterDeliveryManListCount
  int bottledWaterDeliveryManListCount = 0;
  List<UserModel>? deliveryManList;

  //// apis
  getDeliveryManList() async {
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        deliveryManList = await API().getDeliveryManListByDay(
          provider.showDateAsYYYYMMDD(DateTime.now()),
        );
        bottledWaterDeliveryManListCount = deliveryManList!.length;
        setState(() {});
      }
    });
  }

  getSaleDateRangeCount() async {
    Map<String, dynamic> fromToDate = {
      "from": _provider.showDateAsYYYYMMDD(DateTime.now()),
      "to": _provider.showDateAsYYYYMMDD(DateTime.now()),
    };

    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        var result = await API().getSaleDateRangeCountandProList(fromToDate);
        saleCount = result["saleCount"];
        setState(() {});
      }
    });
  }

  //// function
  Widget _dailyCard(title, count) {
    return Text(
      "$count $title",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1D1F1F),
      ),
    );
  }

  Widget _daily(String title, String count) {
    return Expanded(
      child: Container(
        color: const Color(0xFFFAFAFA),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D1F1F),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              title.tr(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1D1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getServicePage(page) async {
    if (page == 'TransportPage') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => TransportPage()));
    } else if (page == "TranRoute()") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaterTransportListPage(),
        ),
      );
    } else if (page == "NewCustomer()") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddandEditCustPage(
            isUpdate: false,
          ),
        ),
      );
    } else if (page == "CustomerList()") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerListPage(),
        ),
      );
    } else if (page == "RetailSaleListPage()") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RetailSaleListPage(),
        ),
      );
    } else if (page == "MapPage") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(),
        ),
      );
    }
    setState(() {});
  }

  initData() {
    updatedTime = _provider.showDateAsDDMMYYYY(DateTime.now());
    userData = _dataConfig.getCurrentUserData();
    getDeliveryManList();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomAvater(
                imageURL: userData["avatar"] == "" ? null : userData["avatar"],
                name: userData["name"].toString(),
                radius: 40,
                fontSize: 18,
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TabsPage(
                              currentIndex: 4,
                              tabsList: tabsListForMgr,
                            ),
                          ),
                        );
                      });
                    },
                    child: Text(
                      "Welcome ${userData["name"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    filterUserRole(userData["role"]),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //// daily overview
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              padding: homepadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "daily_list".tr(),
                    style: headerTextStyle,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      _daily("cust", "${saleCount["totalCustomers"]}"),
                      SizedBox(
                        width: 10,
                      ),
                      _daily("delivery", "${saleCount["totalProductQty"]}"),
                      SizedBox(
                        width: 10,
                      ),
                      _daily("bottle", "${saleCount["totalReturnProductQty"]}"),
                    ],
                  ),
                ],
              ),
            ),
            //// service
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              padding: homepadding,
              margin: const EdgeInsets.only(top: 10),
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
                                ),
                              ],
                            )),
                      );
                    }),
                  ),
                ],
              ),
            ),
            //// bottled_water_delivery_man_list
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryManListPage(
                      deliveryManList: deliveryManList,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "bottled_water_delivery_man_list".tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: headerTextStyle,
                        ),
                        context.locale.toString() == "my"
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                color: Colors.transparent,
                                child: RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    text: 'ရေဗူးပို့သူ ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '$bottledWaterDeliveryManListCount',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1D1F1F),
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' ယောက်ရှိပါသည်။',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                color: Colors.transparent,
                                child: RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    text: 'There are ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '$bottledWaterDeliveryManListCount',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1D1F1F),
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' people bottled water delivery man.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {});
                      },
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // space
            SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
