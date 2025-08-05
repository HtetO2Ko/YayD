import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/deviceInfo_model.dart';
import 'package:yay_thant/pages/Tab/tabs_page.dart';
import 'package:yay_thant/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isDeviceLimitExceeded = false;

  route() {
    if (hasToken == '') {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TabsPage(
            currentIndex: 1,
            tabsList: isDeliveryMan ? tabsListForDeli : tabsListForMgr,
          ),
        ),
      );
    }
  }

  Future<void> checkDeviceLimit() async {
    DeviceInfoModel? deviceData = await getDeviceInfo();
    if (deviceData != null) {
      API().checkDevice(deviceData.toJson()).then((value) {
        if (value == false) {
          setState(() {
            isDeviceLimitExceeded = false;
          });
        }
      });
    } else {
      showSnackBar("Can't get device model!", false);
    }
  }

  startTimer() async {
    // await checkDeviceLimit();
    // if (!isDeviceLimitExceeded) {
      if (hasToken != "") {
        currentUserData = dataconfig.getCurrentUserData();
        if (currentUserData["role"] == 0) {
          setState(() {
            isDeliveryMan = true;
          });
        } else {
          setState(() {
            isDeliveryMan = false;
          });
        }
      } else {
        setState(() {});
      }
      var duration = const Duration(seconds: 2);
      return Timer(duration, route);
    // }
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/images/YayD_logo.png",
              width: 250,
              height: 250,
            ),
          ),
          isDeviceLimitExceeded
            ? SizedBox(
                child: Text(
                  "Device Limition Has Been Reached!",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              )
            :
          CircularProgressIndicator(
              color: primaryColor,
          ),
      ]),
    );
  }
}
