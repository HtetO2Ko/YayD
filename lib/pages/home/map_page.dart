import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/common_key.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/localstr.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/customer_location.dart';
import 'package:yay_thant/storage_util.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';

class MapPage extends StatefulWidget {
  final bool? isFromTab;
  const MapPage({
    super.key,
    this.isFromTab,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> locations = [];
  List<CustomerLocation> customerWithLocations = [];
  LatLng? centerLocation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initData();
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      _loading = true;
    });
    if (await Geolocator.isLocationServiceEnabled()) {
      LocationPermission  permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return showSnackBar('Location permissions are denied', false);
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return showSnackBar('Location permissions are permanently denied, we cannot request permissions.', false);
      } 
      Position currentLocation = await Geolocator.getCurrentPosition();
      if (locations.isNotEmpty && locations[0]["type"] == 1) {
        locations.removeAt(0);
      }
      locations.insert(0, {
        "loc": LatLng(currentLocation.latitude, currentLocation.longitude),
        "type": 1
      });
    } else {
      Geolocator.openLocationSettings();
    }

    if (widget.isFromTab != null && widget.isFromTab!) {
      await getCustomerByRouteLocations();
    } else {
      await getAllCustomerLocations();
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> getCustomerByRouteLocations() async {
    List<CustomerLocation> customerLocations =
        StorageUtils.getCustomerLocations(customerLocationsKey);
    if (customerLocations.isNotEmpty) {
      for (int i = 0; i < customerLocations.length; i++) {
        if (customerLocations[i].location!.lat != "" &&
            customerLocations[i].location!.lon != "") {
          locations.add({
            "loc": LatLng(double.parse(customerLocations[i].location!.lat),
                double.parse(customerLocations[i].location!.lon)),
            "type": 0,
            "customer": customerLocations[i],
          });
        }
      }
    }
  }

  Future<void> getAllCustomerLocations() async {
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllCustomers(1, sameLocation: null).then((customers) {
          if (customers.isNotEmpty) {
            for (int i = 0; i < customers.length; i++) {
              if (customers[i].location!.lat != "" &&
                  customers[i].location!.lon != "") {
                // customerWithLocations
                //     .add(CustomerLocation.fromJson(customers[i].toJson()));
                locations.add({
                  "loc": LatLng(double.parse(customers[i].location!.lat),
                      double.parse(customers[i].location!.lon)),    
                  "customer": customers[i],
                  "type": 0
                });
              }
            }
          }
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print("onResume");
      getCurrentLocation();
    }
  }

  initData() {
    getCurrentLocation();
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFromTab != null && widget.isFromTab!
          ? customAppBar(title: "Map", titlePadding: EdgeInsets.only(left: 10))
          : customAppBar(
              title: "Map",
              titlePadding: EdgeInsets.only(left: 10),
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
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                      initialZoom: 17.0,
                      minZoom: 7.0,
                      initialCenter:
                          locations[0]["loc"] ?? LatLng(21.9588, 96.0891),
                      maxZoom: 20.0),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?view=Unified&key=$tomTomMapKey',
                    ),
                    MarkerLayer(
                      markers: List.generate(locations.length, (index) {
                        return Marker(
                          point: locations[index]["loc"],
                          child: locations[index]["type"] == 1
                              ? Icon(
                                  Icons.navigation_sharp,
                                  size: 35,
                                  color: primaryColor,
                                  shadows: const [
                                    Shadow(
                                        blurRadius: 4.0,
                                        color: Colors.black45,
                                        offset: Offset(3, 3)),
                                  ],
                                )
                              : Tooltip(
                                  richMessage: TextSpan(children: [
                                    TextSpan(
                                        text:
                                            "${locations[index]["customer"].name}\n"),
                                    TextSpan(
                                        text:
                                            "${locations[index]["customer"].phone}\n"),
                                    TextSpan(
                                        text:
                                            "${locations[index]["customer"].address}"),
                                  ]),
                                  showDuration: Duration(seconds: 5),
                                  triggerMode: TooltipTriggerMode.tap,
                                  child: Icon(
                                    Icons.location_on,
                                    size: 30.0,
                                    color: Colors.red,
                                  ),
                                ),
                        );
                      }),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
