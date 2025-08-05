import 'dart:convert';
import 'package:yay_thant/constants/localstr.dart';
import 'package:yay_thant/storage_util.dart';

class Dataconfig {
  String getToken() {
    String token = "";
    token = StorageUtils.getString(lappToken);
    return token;
  }

  Map<String, dynamic> getCurrentUserData() {
    Map<String, dynamic> userData = {};
    userData = StorageUtils.getString(luserData) == ""
        ? {}
        : jsonDecode(StorageUtils.getString(luserData));
    return userData;
  }

  List getLocalRouteForDeli() {
    List routeList = [];
    print(jsonDecode(StorageUtils.getString(routelist)));
    routeList = StorageUtils.getString(routelist) == ""
        ? []
        : jsonDecode(StorageUtils.getString(routelist));
    return routeList;
  }
}
