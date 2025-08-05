import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yay_thant/config/dataconfig.dart';
import 'package:yay_thant/constants/localstr.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/customer_model.dart';
import 'package:yay_thant/models/customerbyroute_model.dart';
import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/models/overdue_model.dart';
import 'package:yay_thant/models/overdue_update_model.dart';
import 'package:yay_thant/models/retail_sale_model.dart';
import 'package:yay_thant/models/route_model.dart';
import 'package:yay_thant/models/summary_sale_count_model.dart';
import 'package:yay_thant/models/sale_response_model.dart';
import 'package:yay_thant/models/tran_model.dart';
import 'package:yay_thant/models/user_model.dart';
import 'package:yay_thant/storage_util.dart';
import 'package:yay_thant/common_key.dart';

class API {
  // cloud
  final _baseURL = apiBaseURL;
  // final _baseURL = "https://yayd.tastysoft.co/yay-thant/v1";
  // local
  // final _baseURL = "http://192.168.1.9:3000/yay-thant/v1";
  final _dataConfig = Dataconfig();
  final _provider = Functionprovider();
  final _timeoutSeconds = 60;

  /// Device
  Future<bool> checkDevice(body) async {
    final String url = "$_baseURL/check-deviceId";
    debugPrint(">>>>>>> check device url $url");
    debugPrint(">>>>>>> check device body $body");
    final response =
        await _provider.httpPostWithoutToken(url, body, _timeoutSeconds);

    if (response != null) {
      debugPrint(
          ">>>>>>>>>> check device response statuscode ${response.statusCode}");
      debugPrint(">>>>>>>>>> check device response body ${response.body}");
      var res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (res["success"] == true) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  //// user
  Future<bool> login(body) async {
    final String url = "$_baseURL/login";
    debugPrint(">>>>>>> login url $url");
    debugPrint(">>>>>>> login body $body");
    final response = await _provider.httpPostWithoutToken(
      url,
      body,
      _timeoutSeconds,
    );
    if (response != null) {
      debugPrint(">>>>>>>>>> login response statuscode ${response.statusCode}");
      debugPrint(">>>>>>>>>> login response body ${response.body}");
      var res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (res["success"] == true) {
          showSnackBar("login_success", true);
          await StorageUtils.putString(lappToken, res["accessToken"]);
          await StorageUtils.putString(luserData, jsonEncode(res["user"]));
        }
      }
      return res["success"] ?? false;
    } else {
      return false;
    }
  }

  // Future<String> refreshToken() async{
  //   String token = Dataconfig().getToken();
  //   var response = await _provider.httpGet("$_baseURL/me", token, _timeoutSeconds);
  //   if (response != null) {
  //     var res = jsonDecode(response.body);
  //     if (response.statusCode == 200) {
  //       if(res["success"] == true){
  //         return res["refreshToken"];
  //       }
  //     }
  //     return "";
  //   } else {
  //     return "";
  //   }
  // }

  Future<bool> changePassword(param) async {
    String token = Dataconfig().getToken();
    debugPrint(">>>. token2 $token");
    final String url = "$_baseURL/update-user-password";
    debugPrint(">>>>>>> update password url $url");
    debugPrint(">>>>>>> update password body $param");
    final response =
        await _provider.httpUpdate(url, param, token, _timeoutSeconds);

    var res;
    if (response != null) {
      debugPrint(
          ">>>>>>>>>> update password response statuscode ${response.statusCode}");
      debugPrint(">>>>>>>>>> update password response body ${response.body}");
      res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (res["success"] == true) {
          showSnackBar("update_pw_success", true);
          await StorageUtils.putString(
              luserData, jsonEncode(res["updatedUser"]));
        }
      }
      return res["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> createUser(param) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/create-user";

    debugPrint("create user req url --- > $url");
    debugPrint("create user req body --- > $param");

    final response =
        await _provider.httpPost(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      debugPrint("create user res statuscode ${response.statusCode}");
      debugPrint("create user res body ${response.body}");
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> updateUserData(param, id) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/update-user-info-by-admin/$id";

    debugPrint(">>>>>>>>>>>>> update user req url $url");
    debugPrint(">>>>>>>>>>>>> update user req body $param");

    final response =
        await _provider.httpUpdate(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      debugPrint(
          ">>>>>>>>>>>>> update user res statuscode ${response.statusCode}");
      debugPrint(">>>>>>>>>>>>> update user res body ${response.body}");
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> deleteUser(id) async {
    String token = _dataConfig.getToken();
    var result;
    final String url = "$_baseURL/delete-one-user/$id";
    final response = await _provider.httpDelete(url, token, _timeoutSeconds);
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<List<UserModel>> getAllUser() async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-users";
    debugPrint("get user req url --- > $url");
    List<UserModel> users = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List userList = result['users'];
          users = userList.map((user) => UserModel.fromJson(user)).toList();
        }
      }
    }
    debugPrint("get user res statuscode ${response?.statusCode}");
    debugPrint("get user res body ${response?.body}");
    debugPrint("userlist $users");

    return users;
  }

  //// item(product)/(stock)
  Future<bool> createItem(param) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/create-one-product";

    debugPrint(">>>>>>>>>>>>> create item req url $url");
    debugPrint(">>>>>>>>>>>>> create item req body $param");

    final response =
        await _provider.httpPost(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      debugPrint(
          ">>>>>>>>>>>>> create item res statuscode ${response.statusCode}");
      debugPrint(">>>>>>>>>>>>> create item res body ${response.body}");
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> updateItem(param, id) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/update-product/$id";

    debugPrint(">>>>>>>>>>>>> update item req url $url");
    debugPrint(">>>>>>>>>>>>> update item req body $param");

    final response =
        await _provider.httpUpdate(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      debugPrint(
          ">>>>>>>>>>>>> update item res statuscode ${response.statusCode}");
      debugPrint(">>>>>>>>>>>>> update item res body ${response.body}");
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> deleteItem(id) async {
    String token = _dataConfig.getToken();
    var result;
    final String url = "$_baseURL/delete-one-product/$id";
    final response = await _provider.httpDelete(url, token, _timeoutSeconds);
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<List<ItemModel>> getAllItem() async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-products";
    List<ItemModel> items = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List itemList = result['products'];
          items = itemList.map((item) => ItemModel.fromJson(item)).toList();
        }
      }
    }
    return items;
  }

  Future<List<ProductElement>> getAvailableItem(String id) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-one-transport/$id";
    List<ProductElement> items = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List itemList = result['transport']['products'];
          items =
              itemList.map((item) => ProductElement.fromJson(item)).toList();
        }
      }
    }
    return items;
  }

  //// route
  Future<dynamic> createRoute(body) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/create-route";
    final response =
        await _provider.httpPost(url, body, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      return result['success'] ?? false;
    } else {
      return false;
    }
  }

  Future<dynamic> updateRoute(body, id) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/update-route/$id";
    final response =
        await _provider.httpUpdate(url, body, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      return result['success'] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> deleteRoute(id) async {
    String token = _dataConfig.getToken();
    var result;
    print("route id >> $id");
    final String url = "$_baseURL/delete-one-route/$id";
    final response = await _provider.httpDelete(url, token, _timeoutSeconds);
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<List<RouteModel>> getAllRoute() async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-routes";
    List<RouteModel> routes = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List routeList = result['routes'];
          routes =
              routeList.map((route) => RouteModel.fromJson(route)).toList();
        }
      }
    }
    return routes;
  }

  Future<List<CustomerByRouteModel>> getCustomersByRoute(id) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-customers-by-routeId/$id";
    List<CustomerByRouteModel> data = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    debugPrint("$response");
    if (response != null) {
      var result = jsonDecode(response.body);
      print(result);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List customerList = result['customers']['results'];
          data = customerList
              .map((customer) => CustomerByRouteModel.fromJson(customer))
              .toList();
        }
      }
    }
    return data;
  }

  //// transport
  Future<bool> createWaterTran(param) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/create-one-transport";
    final response =
        await _provider.httpPost(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      print(">>>>> create tran res body ${response.body}");
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> updateWaterTran(param, id) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/update-transport/$id";

    final response =
        await _provider.httpUpdate(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> deleteWaterTran(id) async {
    String token = _dataConfig.getToken();
    var result;
    final String url = "$_baseURL/delete-one-transport/$id";
    final response = await _provider.httpDelete(url, token, _timeoutSeconds);
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<List<TranModel>> getAllTran() async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-transports";
    List<TranModel> trans = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List tranList = result['transports']["results"];
          trans = tranList.map((user) => TranModel.fromJson(user)).toList();
        }
      }
    }
    return trans;
  }

  Future<List<TranModel>> getTranByDate(String date) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-transports-by-day/$date";
    debugPrint(">>>>>>> get all tran $url");
    List<TranModel> trans = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      debugPrint(">>>>>>> get all tran res status ${response.statusCode}");
      debugPrint(">>>>>>> get all tran res body ${response.body}");
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List tranList = result['transports'];
          trans = tranList.map((user) => TranModel.fromJson(user)).toList();
        }
      }
    }
    return trans;
  }

  Future<List<TranModel>> getTranByDateAndDeliveryMan(
      String date, String id) async {
    String token = _dataConfig.getToken();
    final String url =
        "$_baseURL/get-all-transports-by-day-and-deliveryManId/$date/$id";
    List<TranModel> trans = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List tranList = result['transports'];
          trans = tranList.map((user) => TranModel.fromJson(user)).toList();
        }
      }
    }
    return trans;
  }

  Future<List<TranModel>> getTranByDateRange(
      String fromDate, String toDate) async {
    String token = _dataConfig.getToken();
    final String url =
        "$_baseURL/get-all-transports-by-dateRange/$fromDate/$toDate";
    List<TranModel> trans = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List tranList = result['transports'];
          trans = tranList.map((user) => TranModel.fromJson(user)).toList();
        }
      }
    }
    return trans;
  }

  //// retail sale
  Future<bool> createRetailSale(param) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/create-one-retail-sale";
    debugPrint(url);
    print(param);
    final response =
        await _provider.httpPost(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> updateRetailSale(param, id) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/update-retail-sale/$id";

    final response =
        await _provider.httpUpdate(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> deleteRetailSale(id) async {
    String token = _dataConfig.getToken();
    var result;
    final String url = "$_baseURL/delete-one-retail-sale/$id";
    final response = await _provider.httpDelete(url, token, _timeoutSeconds);
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<List<RetailSaleModel>> getAllRetailSale() async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-retail-sales";
    List<RetailSaleModel> retailSale = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List retailSaleList = result['retailSales']["results"];
          retailSale = retailSaleList
              .map((sale) => RetailSaleModel.fromJson(sale))
              .toList();
        }
      }
    }
    return retailSale;
  }

  Future<List<RetailSaleModel>> getRetailSaleByDate(String date,
      {String? id}) async {
    String token = _dataConfig.getToken();
    String url = _baseURL;
    if (id == null) {
      url = "$_baseURL/get-all-retail-sales-by-day/$date";
    } else {
      url = "$_baseURL/get-all-retail-sales-by-day/$date?sellerId=$id";
    }
    List<RetailSaleModel> retailSale = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      print(response.statusCode);
      print(response.body);
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List retailSaleList = result['retailSales'];
          retailSale = retailSaleList
              .map((sale) => RetailSaleModel.fromJson(sale))
              .toList();
        }
      }
    }
    return retailSale;
  }

  Future<List<RetailSaleModel>> getRetailSaleByDateRange(
      String fromDate, String toDate) async {
    String token = _dataConfig.getToken();
    final String url =
        "$_baseURL/get-all-retail-sales-by-dateRange/$fromDate/$toDate";
    List<RetailSaleModel> retailSale = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List retailSaleList = result['retailSales'];
          retailSale = retailSaleList
              .map((user) => RetailSaleModel.fromJson(user))
              .toList();
        }
      }
    }
    return retailSale;
  }

  //// customer
  Future<List<CustomerModel>> getAllCustomers(int activeStatus,
      {var sameLocation}) async {
    String token = _dataConfig.getToken();
    String url = "";
    if (sameLocation == null) {
      url = "$_baseURL/get-all-customers?status=$activeStatus";
    } else {
      url =
          "$_baseURL/get-all-customers-by-location?active=$activeStatus&sameLocation=$sameLocation";
    }
    List<CustomerModel> custs = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    print("url >> $url");
    if (response != null) {
      print(response.statusCode);
      print(response.body);
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List custList = [];
          print(">>>>>>  sameLocation$sameLocation");
          if (sameLocation == null) {
            custList = result['customers']["results"];
          } else {
            custList = result['customers'];
          }
          custs = custList.map((cust) => CustomerModel.fromJson(cust)).toList();
        }
      }
    }
    return custs;
  }

  Future<bool> createCustomer(param) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/create-one-customer";
    final response =
        await _provider.httpPost(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> updateCustomer(param, id) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/update-customer/$id";
    final response =
        await _provider.httpUpdate(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> changeCustomerStatus(String customerId, int status) async {
    String token = _dataConfig.getToken();
    var result;
    final String url = "$_baseURL/update-customer-status";
    var body = jsonEncode({"customerId": customerId, "status": status});
    final response =
        await _provider.httpUpdate(url, body, token, _timeoutSeconds);
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<bool> deleteCustomer(id) async {
    String token = _dataConfig.getToken();
    var result;
    final String url = "$_baseURL/delete-one-customer/$id";
    final response = await _provider.httpDelete(url, token, _timeoutSeconds);
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  //// delivery man for admin
  Future<List<UserModel>> getAllDeliveryManList() async {
    String token = _dataConfig.getToken();
    List<UserModel> deliveryManList = [];
    final String url = "$_baseURL/get-all-transports?select=deliveryMan";
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      print(">>>> deliver list res status ${response.statusCode}");
      print(">>>> deliver list res body ${response.body}");
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List deliveryMan = result['deliveryMan'] ?? [];
          deliveryManList = deliveryMan
              .map((delivery) => UserModel.fromJson(delivery))
              .toList();
        }
      }
    }
    return deliveryManList;
  }

  Future<List<UserModel>> getDeliveryManListByDay(day) async {
    String token = _dataConfig.getToken();
    List<UserModel> deliveryManList = [];
    final String url =
        "$_baseURL/get-all-transports-by-day/$day?select=deliveryMan";
    final response = await _provider.httpGet(url, token, _timeoutSeconds);

    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List deliveryMan = result['deliveryMan'];
          deliveryManList = deliveryMan
              .map((delivery) => UserModel.fromJson(delivery))
              .toList();
        }
      }
    }
    return deliveryManList;
  }

  Future<List<UserModel>> getDeliveryManListByMonth(month) async {
    String token = _dataConfig.getToken();
    List<UserModel> deliveryManList = [];
    final String url =
        "$_baseURL/get-all-transports-by-month/${DateTime.now().year}-$month?select=deliveryMan";
    final response = await _provider.httpGet(url, token, _timeoutSeconds);

    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List deliveryMan = result['deliveryMan'] ?? [];
          deliveryManList = deliveryMan
              .map((delivery) => UserModel.fromJson(delivery))
              .toList();
        }
      }
    }

    return deliveryManList;
  }

  Future<List<UserModel>> getDeliveryManListByDateRange(
      fromDate, toDate) async {
    String token = _dataConfig.getToken();
    List<UserModel> deliveryManList = [];
    final String url =
        "$_baseURL/get-all-transports-by-dateRange/$fromDate/$toDate?select=deliveryMan";
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      print(
          ">>>> deliver man list daterange res status ${response.statusCode}");
      print(">>>> deliver man list daterange res body ${response.body}");
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List deliveryMan = result['deliveryMan'] ?? [];
          deliveryManList = deliveryMan
              .map((delivery) => UserModel.fromJson(delivery))
              .toList();
        }
      }
    }
    return deliveryManList;
  }

  //// summary
  Future<List<SummarySaleCountModel>> getChartSaleCount(fromToDate) async {
    String token = _dataConfig.getToken();
    final String url =
        "$_baseURL/get-all-sales-by-dateRange/${fromToDate["from"]}/${fromToDate["to"]}?select=sale-count";
    print(">>> sale table $url");
    List<SummarySaleCountModel> chartSale = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List chartSaleList = result['data'];
          chartSale = chartSaleList
              .map((chartSale) => SummarySaleCountModel.fromJson(chartSale))
              .toList();
        }
      }
    }
    return chartSale;
  }

  Future<Map<String, dynamic>> getSaleDateRangeCountandProList(
      fromToDate) async {
    String token = _dataConfig.getToken();
    Map<String, dynamic> saleCount = {
      "totalCustomers": 0,
      "totalProductQty": 0,
      "totalReturnProductQty": 0,
      "totalProductAmount": 0,
    };
    List productList = [];
    final String url =
        "$_baseURL/get-all-sales-by-dateRange/${fromToDate["from"]}/${fromToDate["to"]}?select=customers-and-products";
    final response = await _provider.httpGet(url, token, _timeoutSeconds);

    if (response != null) {
      var result = jsonDecode(response.body);
      print("result---> $result");
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          saleCount = {
            "totalCustomers": result["totalCustomers"],
            "totalProductQty": result["totalProductQty"],
            "totalReturnProductQty": result["totalReturnProductQty"],
            "totalProductAmount": result["totalProductAmount"],
          };
          productList = List.from(result["products"]);
        }
      }
      print("saleCount---> $saleCount");
    }
    return {"saleCount": saleCount, "productList": productList};
  }

  Future<bool> createNewSale(param) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/create-one-sale";
    final response =
        await _provider.httpPost(url, param, token, _timeoutSeconds);
    var result;
    if (response != null) {
      result = jsonDecode(response.body);
      return result["success"] ?? false;
    } else {
      return false;
    }
  }

  Future<List<SaleModel>> getAllSale() async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-sales";
    List<SaleModel> sale = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List saleList = result['sales']["results"];
          sale = saleList.map((sale) => SaleModel.fromJson(sale)).toList();
        }
      }
    }
    return sale;
  }

  Future<List<SaleModel>> getSaleByDate(String date, String? id) async {
    String token = _dataConfig.getToken();
    String url = _baseURL;
    if (id == null) {
      url = "$url/get-all-sales-by-day/$date";
    } else {
      url = "$url/get-all-sales-by-day/$date?sellerId=$id";
    }
    List<SaleModel> sale = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      print(">>>>> sale by day response status ${response.statusCode}");
      print(">>>>> sale by day response body ${response.body}");
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List saleList = result['sales'];
          sale = saleList.map((sale) => SaleModel.fromJson(sale)).toList();
        }
      }
    }
    return sale;
  }

  Future<List<SaleModel>> getSaleByDateRange(
      String fromDate, String toDate) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-sales-by-dateRange/$fromDate/$toDate";
    List<SaleModel> sale = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      print(">>>>> date range sale response status ${response.statusCode}");
      print(">>>>> date range sale response body ${response.body}");
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List saleList = result['sales'];
          sale = saleList.map((user) => SaleModel.fromJson(user)).toList();
        }
      }
    }
    return sale;
  }

  //// overdue
  Future<List<OverDueModel>> getAllOverDue() async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/get-all-balanceDue";
    List<OverDueModel> overDues = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List overDueList = result['sales'];
          overDues = overDueList
              .map((overDue) => OverDueModel.fromJson(overDue))
              .toList();
        }
      }
    }
    return overDues;
  }

  Future<List<OverDueModel>> getAllOverDueByDateRange(fromDate, toDate) async {
    String token = _dataConfig.getToken();
    final String url =
        "$_baseURL/get-all-balanceDue-by-dateRange/$fromDate/$toDate";
    List<OverDueModel> overDues = [];
    final response = await _provider.httpGet(url, token, _timeoutSeconds);
    if (response != null) {
      print(">>> overdue daterange response statuscode ${response.statusCode}");
      print(">>> overdue daterange response body ${response.body}");
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          List overDueList = result['sales'];
          overDues = overDueList
              .map((overDue) => OverDueModel.fromJson(overDue))
              .toList();
        }
      }
    }
    return overDues;
  }

  Future<OverDueUpdateModel?> updateOverDue(id, param) async {
    String token = _dataConfig.getToken();
    final String url = "$_baseURL/update-sale/$id";
    OverDueUpdateModel? overDues;
    final response =
        await _provider.httpUpdate(url, param, token, _timeoutSeconds);
    if (response != null) {
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (result["success"] == true) {
          Map<String, dynamic> overDue = result['updatedSale'];
          overDues = OverDueUpdateModel.fromJson(overDue);
        }
      }
    }
    return overDues;
  }
}
