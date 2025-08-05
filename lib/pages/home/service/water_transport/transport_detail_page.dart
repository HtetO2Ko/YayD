import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/models/customerbyroute_model.dart';
import 'package:yay_thant/models/route_model.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';

class TransportDetailPage extends StatefulWidget {
  final RouteModel routeName;
  const TransportDetailPage({super.key, required this.routeName});

  @override
  State<TransportDetailPage> createState() => _TransportDetailPageState();
}

class _TransportDetailPageState extends State<TransportDetailPage> {
  bool _loading = false;
  List<CustomerByRouteModel> customerList = [];

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() {
    setState(() {
      _loading = true;
      getCustomersByRoute();
    });
  }

  Future<void> getCustomersByRoute() async {
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getCustomersByRoute(widget.routeName.id).then((customers) {
          if (customers.isNotEmpty) {
            customerList = customers;
          }
        });
      }
    });
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: customAppBar(
          title: widget.routeName.title,
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
        ),
        body: _loading
            ? SpinKitRing(
                color: primaryColor,
                lineWidth: 5,
                size: 40,
              )
            : customerList.isEmpty
                ? Center(
                    child: Text(
                      "no_data".tr(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : TransportRouteCustomerWidget(customers: customerList),
      ),
    );
  }
}

class TransportRouteCustomerWidget extends StatelessWidget {
  final List<CustomerByRouteModel> customers;
  const TransportRouteCustomerWidget({super.key, required this.customers});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: customers.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${index + 1}. ${customers[index].name}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            customers[index].status! == 1
                                ? "active"
                                : "inactive",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.circle,
                            color: customers[index].status! == 1
                                ? Colors.green
                                : Colors.red,
                            size: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 0.5,
                  color: Colors.grey,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
