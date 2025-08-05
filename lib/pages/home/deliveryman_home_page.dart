import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/constants/localstr.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/customer_location.dart';
import 'package:yay_thant/models/customerbyroute_model.dart';
import 'package:yay_thant/models/route_model.dart';
import 'package:yay_thant/pages/home/service/customers/add_and_edit_customer_page.dart';
import 'package:yay_thant/pages/home/service/daily_sale/add_new_sale.dart';
import 'package:yay_thant/storage_util.dart';
import 'package:yay_thant/widgets/custom_avater.dart';

class DeliveryManHomePage extends StatefulWidget {
  const DeliveryManHomePage({super.key});

  @override
  State<DeliveryManHomePage> createState() => _DeliveryManHomePageState();
}

class _DeliveryManHomePageState extends State<DeliveryManHomePage> {
  final _provider = Functionprovider();
  Map<String, dynamic> userData = {};
  List<CustomerByRouteModel> customerList = [];
  List<RouteModel> routeList = [];
  List<String> transIdList = [];
  bool _loading = true;
  bool _isCustomerLoading = false;
  String _selectedRoute = "";
  String _selectedRouteID = "";

  var homepadding = const EdgeInsets.symmetric(horizontal: 10);
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
                    onTap: () {},
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
        actions: [
          GestureDetector(
            onTap: () async {
              setState(() {
                _loading = true;
              });
              await getDailyTransportData();
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.refresh,
                color: primaryColor,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? SpinKitRing(
              color: primaryColor,
              lineWidth: 5,
              size: 40,
            )
          : SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: GestureDetector(
                        onTap: () => _showFullWidthMenu(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black),
                            color: Colors.white,
                          ),
                          width: null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_selectedRoute),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "customer_list".tr(),
                          style: headerTextStyle,
                        ),
                        GestureDetector(
                            onTap: () {
                              if (_selectedRoute != "" &&
                                  _selectedRouteID != "") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddandEditCustPage(
                                      isUpdate: false,
                                      routeID: _selectedRouteID,
                                    ),
                                  ),
                                );
                              } else {
                                showSnackBar("No route selected yet!", false);
                              }
                            },
                            child: Icon(Icons.add, size: 30))
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 0.5,
                    color: Colors.black,
                  ),
                  _isCustomerLoading
                      ? Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          color: Colors.white,
                          child: Center(
                              child: SpinKitRing(
                            color: primaryColor,
                            lineWidth: 5,
                            size: 40,
                          )),
                        )
                      : customerList.isNotEmpty
                          ? SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.685,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: customerList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: customerList[index].status! == 1
                                            ? () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddNewSalePage(
                                                              customer:
                                                                  customerList[
                                                                      index],
                                                            )));
                                              }
                                            : () {},
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              color: Colors.white),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${index + 1}. ${customerList[index].name}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    customerList[index]
                                                                .status! ==
                                                            1
                                                        ? "active"
                                                        : "inactive",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 13,
                                                      color: const Color(
                                                          0xFF6B7280),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Icon(
                                                    Icons.circle,
                                                    color: customerList[index]
                                                                .status! ==
                                                            1
                                                        ? Colors.green
                                                        : Colors.red,
                                                    size: 10,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 0.5,
                                        color: Colors.grey,
                                      )
                                    ],
                                  );
                                },
                              ),
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  "no_data".tr(),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                ],
              ),
            ),
    );
  }

  initData() {
    userData = dataconfig.getCurrentUserData();
    setState(() {
      getDailyTransportData();
    });
  }

  Future<void> getDailyTransportData() async {
    var today = _provider.showDateAsYYYYMMDD(DateTime.now());
    routeList.clear();
    transIdList.clear();

    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API()
            .getTranByDateAndDeliveryMan(today, userData["_id"])
            .then((result) {
          if (result != []) {
            routeList = result.map((transport) => transport.route!).toList();
            transIdList = result.map((transport) => transport.id!).toList();
          }
        });

        if (routeList.isNotEmpty) {
          String chosenTransport = StorageUtils.getString(chosenTranId);
          if (chosenTransport != "") {
            for (int i = 0; i < transIdList.length; i++) {
              if (transIdList[i] == chosenTransport) {
                await getCustomersByRoute(routeList[i].id!);
                _selectedRoute = routeList[i].title!;
                _selectedRouteID = routeList[i].id!;
              }
            }
            if (_selectedRoute == "") {
              StorageUtils.putString(chosenTranId, transIdList[0]);
              await getCustomersByRoute(routeList[0].id!);
              _selectedRoute = routeList[0].title!;
              _selectedRouteID = routeList[0].id!;
            }
          } else {
            StorageUtils.putString(chosenTranId, transIdList[0]);
            await getCustomersByRoute(routeList[0].id!);
            _selectedRoute = routeList[0].title!;
            _selectedRouteID = routeList[0].id!;
          }
        } else {
          routeList.add(RouteModel(id: "0", title: ""));
        }
      }
    });

    setState(() {
      _loading = false;
    });
  }

  Future<void> getCustomersByRoute(String routeId) async {
    customerList.clear();
    await API().getCustomersByRoute(routeId).then((customers) {
      if (customers.isNotEmpty) {
        customerList = customers;
        List<CustomerLocation> customerLocations = customers
            .map((customer) => CustomerLocation.fromJson(customer.toJson()))
            .toList();
        // print("customer location >> ${customerLocations[0].location!.lat}");
        StorageUtils.putCustomerLocations(
            customerLocationsKey, customerLocations);
        print(
            "customer location >> ${StorageUtils.getCustomerLocations(customerLocationsKey)}");
      }
    });
  }

  void _showFullWidthMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.topLeft(Offset(0, 154)),
            ancestor: overlay), // Bottom left of the button
        button.localToGlobal(button.size.topRight(Offset(0, 154)),
            ancestor: overlay), // Bottom right of the button
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu(
        context: context,
        position: position,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        items: [
          for (RouteModel route in routeList)
            PopupMenuItem(
              value: route,
              child: Text(route.title!),
            ),
        ]);

    if (selected != null) {
      setState(() {
        _isCustomerLoading = true;
      });
      if (selected.title! != _selectedRoute) {
        for (var i = 0; i < routeList.length; i++) {
          if (routeList[i].title == selected.title) {
            StorageUtils.putString(chosenTranId, transIdList[i]);
            await getCustomersByRoute(routeList[i].id!);
          }
        }
      }
      setState(() {
        _selectedRoute = selected.title!;
        _selectedRouteID = selected.id!;
        _isCustomerLoading = false;
      });
    }
  }
}
