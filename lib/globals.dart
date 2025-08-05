import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/main.dart';
import 'package:yay_thant/models/deviceInfo_model.dart';

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<DeviceInfoModel?> getDeviceInfo() async {
  DeviceInfoModel? deviceData;
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String appVersion = await getAppVersion();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceData = DeviceInfoModel(
          deviceId: androidInfo.id,
          model: androidInfo.name,
          appVersion: appVersion,
          os: "Android",
          osVersion: androidInfo.version.release);
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData = DeviceInfoModel(
        deviceId: iosInfo.identifierForVendor,
        model: iosInfo.name,
        appVersion: appVersion,
        os: "iOS",
        osVersion: iosInfo.systemVersion,
      );
    }
    return deviceData;
  } catch (error) {
    debugPrint("error>> $error");
    return deviceData;
  }
}

showLoadingDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.transparent,
            ),
            child: Center(
              child: SpinKitRing(
                color: primaryColor,
                size: 40,
                lineWidth: 5,
              ),
            ),
          ),
        ),
      );
    },
  );
}

String filterUserRole(int role) {
  String roleName = "";
  if (role == 0) {
    roleName = "Delivery Man";
  } else if (role == 1) {
    roleName = "Manager";
  } else if (role == 2) {
    roleName = "Admin";
  }
  return roleName;
}

CalendarDatePicker2WithActionButtonsConfig buildCalendarDialogConfig() {
  const dayTextStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400);
  const weekendTextStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400);
  final anniversaryTextStyle = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.w700,
  );

  return CalendarDatePicker2WithActionButtonsConfig(
    calendarViewScrollPhysics: const NeverScrollableScrollPhysics(),
    dayTextStyle: dayTextStyle,
    calendarType: CalendarDatePicker2Type.range,
    selectedDayHighlightColor: primaryColor,
    closeDialogOnCancelTapped: true,
    firstDayOfWeek: 1,
    weekdayLabelTextStyle: const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
    controlsTextStyle: const TextStyle(
      color: Colors.black,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
    centerAlignModePicker: true,
    customModePickerIcon: const SizedBox(),
    selectedDayTextStyle: dayTextStyle.copyWith(color: Colors.white),
    dayTextStylePredicate: ({required date}) {
      TextStyle? textStyle;
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        textStyle = weekendTextStyle;
      }
      if (DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day) {
        textStyle = anniversaryTextStyle;
      }
      return textStyle;
    },
    dayBuilder: ({
      required date,
      textStyle,
      decoration,
      isSelected,
      isDisabled,
      isToday,
    }) {
      return null;
    },
    yearBuilder: ({
      required year,
      decoration,
      isCurrentYear,
      isDisabled,
      isSelected,
      textStyle,
    }) {
      return Center(
        child: Container(
          decoration: decoration,
          height: 36,
          width: 72,
          child: Center(
            child: Semantics(
              selected: isSelected,
              button: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    year.toString(),
                    style: textStyle,
                  ),
                  if (isCurrentYear == true)
                    Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(left: 5),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// snack bar

void showSnackBar(msg, isSuccess) {
  FToast fToast = FToast();
  fToast = fToast.init(navigatorKey.currentContext!);
  if (isSuccess == null) {
    return fToast.showToast(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.black,
        ),
        child: Text(
          msg.toString().tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child) {
        return Positioned(
          left: 50.0,
          right: 50.0,
          bottom: 60.0,
          child: child,
        );
      },
    );
  } else if (isSuccess == true) {
    return fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: const Color.fromRGBO(43, 198, 22, 50),
        ),
        child: Text(
          msg.toString().tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
      positionedToastBuilder: (context, child) {
        return Positioned(
          left: 50.0,
          right: 50.0,
          bottom: 60.0,
          child: child,
        );
      },
    );
  } else if (isSuccess == false) {
    return fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.red,
        ),
        child: Text(
          msg.toString().tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
      positionedToastBuilder: (context, child) {
        return Positioned(
          left: 50.0,
          right: 50.0,
          bottom: 60.0,
          child: child,
        );
      },
    );
  } else {
    return fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.black,
        ),
        child: Text(
          msg.toString().tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
      positionedToastBuilder: (context, child) {
        return Positioned(
          left: 50.0,
          right: 50.0,
          bottom: 60.0,
          child: child,
        );
      },
    );
  }
}

void showRequiredMsg(String massage) {
  showSnackBar(massage.tr() + "req".tr(), false);
}

void showChooseMsg(
  String massage,
  BuildContext context,
) {
  final localeString = context.locale.toString();
  if (localeString == 'my') {
    showSnackBar("${massage.tr()} ${"choose".tr()}", false);
  } else {
    showSnackBar("choose".tr() + massage.tr(), false);
  }
}

void showCreateSuccessMsg(String message) {
  showSnackBar(message.tr() + "create_success".tr(), true);
}

void showUpdateSuccessMsg(String message) {
  showSnackBar(message.tr() + "update_success".tr(), true);
}

void showDeleteSuccessMsg(String message) {
  showSnackBar(message.tr() + "delete_success".tr(), true);
}

// location
Future<bool> handleLocationPermission() async {
  print(">>>>>> 2");
  bool serviceEnabled;
  LocationPermission permission;
  print(">>>>>> 3");
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  print(">>>>>> 4");
  if (!serviceEnabled) {
    showSnackBar(
        "Location services are disabled. Please enable the services", false);
    return false;
  }
  print(">>>>>> 5");
  permission = await Geolocator.checkPermission();
  print(">>>>>> 6");
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      showSnackBar("Location permissions are denied", false);
      return false;
    }
  } else if (permission == LocationPermission.deniedForever) {
    showSnackBar(
        "Location permissions are permanently denied, we cannot request permissions.",
        false);
    return false;
  }
  print(">>>>>> 7");
  return true;
}

Future<Position> getCurrentLocation() async {
  Position currentLocation;
  try {
    print(">>>>>> 1");
    final hasPermission = await handleLocationPermission();
    currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    print(">>>> hasPermission$hasPermission");
  } catch (e) {
    print(">>>>>>> eror $e");
    currentLocation = Position(
        longitude: 0.0,
        timestamp: DateTime.now(),
        latitude: 0.0,
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 1,
        headingAccuracy: 0);
  }
  return currentLocation;
}

// address name
Future<String> getAddressNameWithLatLong(
    double latitude, double longitude) async {
  String address = "";
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      address = '${place.street}, ${place.subLocality}, ${place.locality}';
    }
  } catch (e) {
    address = "";
  }
  return address;
}
