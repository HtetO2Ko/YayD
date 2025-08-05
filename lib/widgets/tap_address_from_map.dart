import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:yay_thant/common_key.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_button.dart';

class TapAddressPage extends StatefulWidget {
  final LatLng? selectedLocation;
  const TapAddressPage({
    super.key,
    this.selectedLocation,
  });

  @override
  State<TapAddressPage> createState() => _TapAddressPageState();
}

class _TapAddressPageState extends State<TapAddressPage> {
  LatLng? selectedLocation;

  _getCurrentLatLong() async {
    selectedLocation = widget.selectedLocation;
    if (selectedLocation == null) {
      if (await Geolocator.isLocationServiceEnabled()) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return showSnackBar('Location permissions are denied', false);
          }
        }

        if (permission == LocationPermission.deniedForever) {
          return showSnackBar(
              'Location permissions are permanently denied, we cannot request permissions.',
              false);
        }
        Position latLon = await getCurrentLocation();
        selectedLocation = LatLng(latLon.latitude, latLon.longitude);
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    _getCurrentLatLong();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "map",
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
      body: Stack(
        children: [
          selectedLocation == null ||
                  selectedLocation!.latitude == 0.0 &&
                      selectedLocation!.longitude == 0.0
              ? SizedBox()
              : FlutterMap(
                  options: MapOptions(
                    onTap: (tapPosition, point) {
                      selectedLocation = point;
                      setState(() {});
                    },
                    initialZoom: 17.0,
                    minZoom: 7.0,
                    maxZoom: 20.0,
                    initialCenter: LatLng(
                      selectedLocation!.latitude,
                      selectedLocation!.longitude,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?view=Unified&key=$tomTomMapKey',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 30.0,
                          height: 30.0,
                          point: LatLng(selectedLocation!.latitude,
                              selectedLocation!.longitude),
                          child: GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.location_on,
                              size: 30.0,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
        child: CustomButton(
          buttonText: "save".tr(),
          isLoading: false,
          onTap: () {
            setState(() {
              Navigator.pop(
                context,
                selectedLocation,
              );
            });
          },
        ),
      ),
    );
  }
}
