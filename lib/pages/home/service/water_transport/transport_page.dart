import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/models/route_model.dart';
import 'package:yay_thant/pages/home/service/water_transport/transport_detail_page.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({super.key});

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  bool _loading = false;
  List<RouteModel> routeList = [];

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() {
    setState(() {
      _loading = true;
      getRoutes();
    });
  }

  Future<void> getRoutes() async {
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllRoute().then((routes) {
          if (routes.isNotEmpty) {
            routeList = routes;
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
          title: "transport",
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
            : routeList.isEmpty
                ? Center(
                    child: Text(
                      "No Route",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : TransportWidget(routes: routeList),
      ),
    );
  }
}

class TransportWidget extends StatelessWidget {
  final List<RouteModel> routes;
  const TransportWidget({super.key, required this.routes});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: routes.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TransportDetailPage(
                                  routeName: routes[index],
                                )));
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 15,
                    ),
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: Colors.white),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      routes[index].title!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
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
