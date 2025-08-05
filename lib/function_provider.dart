import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/main.dart';
import 'package:yay_thant/pages/login_page.dart';
import 'package:yay_thant/storage_util.dart';

class Functionprovider {
  //// http calls

  Future<http.Response?> httpPostWithoutToken(url, body, seconds) async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse(url),
        body: body,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: seconds));
    } on TimeoutException catch (e) {
      print("Request Timeout: $e");
      showErrorMassage("Request timed out. Please try again.");
    } catch (error) {
      print(">>> delete error ${error.toString()}");
      return null;
    }

    print(response.statusCode);
    print(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      showErrorMassage(response.body);
    }
    return response;
  }

  Future<http.Response?> httpPost(url, body, token, seconds) async {
    late http.Response? response;
    try {
      response = await http.post(
        Uri.parse(url),
        body: body,
        headers: <String, String>{
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: seconds));
    } on TimeoutException catch (e) {
      print("Request Timeout: $e");
      showErrorMassage("Request timed out. Please try again.");
    } catch (error) {
      print(">>> delete error ${error.toString()}");
      // throw Exception(error);
      return null;
    }

    if (response!.statusCode != 200 && response.statusCode != 201) {
      if (response.statusCode == 500) {
        var result = jsonDecode(response.body);
        if (result["status"] == 500 && result["message"] == "jwt expired") {
          logout();
        } else {
          showErrorMassage(response.body);
        }
      } else {
        showErrorMassage(response.body);
      }
    }
    return response;
  }

  Future<http.Response?> httpGet(url, token, seconds) async {
    late http.Response response;
    try {
      print(">>> url $url");
      print(">>> token $token");
      response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: seconds));
    } on TimeoutException catch (e) {
      print("Request Timeout: $e");
      showErrorMassage("Request timed out. Please try again.");
    } catch (error) {
      print(">>> delete error ${error.toString()}");
      // throw Exception(error);
      return null;
    }

    print(">>> response status ${response.statusCode}");
    print(">>> response body ${response.body}");
    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.statusCode == 500) {
        var result = jsonDecode(response.body);
        if (result["status"] == 500 && result["message"] == "jwt expired") {
          logout();
        } else {
          showErrorMassage(response.body);
        }
      } else {
        showErrorMassage(response.body);
      }
    }
    return response;
  }

  Future<http.Response?> httpUpdate(url, body, token, seconds) async {
    late http.Response response;
    try {
      response = await http.put(
        Uri.parse(url),
        body: body,
        headers: <String, String>{
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: seconds));
    } on TimeoutException catch (e) {
      print("Request Timeout: $e");
      showErrorMassage("Request timed out. Please try again.");
    } catch (error) {
      print(">>> delete error ${error.toString()}");
      // throw Exception(error);
      return null;
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.statusCode == 500) {
        var result = jsonDecode(response.body);
        if (result["status"] == 500 && result["message"] == "jwt expired") {
          logout();
        } else {
          showErrorMassage(response.body);
        }
      } else {
        showErrorMassage(response.body);
      }
    }
    return response;
  }

  Future<http.Response?> httpDelete(url, token, seconds) async {
    late http.Response response;
    try {
      response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          "Content-Type": "application/json",
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: seconds));
    } on TimeoutException catch (e) {
      print("Request Timeout: $e");
      showErrorMassage("Request timed out. Please try again.");
    } catch (error) {
      print(">>> delete error ${error.toString()}");
      // throw Exception(error);
      return null;
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.statusCode == 500) {
        var result = jsonDecode(response.body);
        if (result["status"] == 500 && result["message"] == "jwt expired") {
          logout();
        } else {
          showErrorMassage(response.body);
        }
      } else {
        showErrorMassage(response.body);
      }
    }
    return response;
  }

  Future<void> logout({bool isExpired = true}) async {
    await StorageUtils.clrString();
    if (isExpired) {
      showSnackBar("Login Expired!\nPlease Login Again!", false);
    }
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  showErrorMassage(resBody) {
    var res = jsonDecode(resBody);
    showSnackBar(res["message"] ?? "Something went wrong.", false);
  }

  //// profile colors

  Color getBackgroundColor(String username) {
    if (username.isEmpty) {
      return Colors.black; // Default color for empty username
    }

    // Map letter ranges to light colors
    Map<String, Color> letterRangeColors = {
      'A-E': const Color(0xFFFFCDD2), // Light Pink
      'F-J': const Color(0xFFBBDEFB), // Light Blue
      'K-O': const Color(0xFFC8E6C9), // Light Green
      'P-T': const Color(0xFFFFE0B2), // Light Orange
      'U-Z': const Color(0xFFFFE0B2), // Light Yellow
    };

    String firstLetter = username[0].toUpperCase();

    // Determine the color based on the first letter
    if ('A'.compareTo(firstLetter) <= 0 && 'E'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['A-E']!;
    } else if ('F'.compareTo(firstLetter) <= 0 &&
        'J'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['F-J']!;
    } else if ('K'.compareTo(firstLetter) <= 0 &&
        'O'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['K-O']!;
    } else if ('P'.compareTo(firstLetter) <= 0 &&
        'T'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['P-T']!;
    } else if ('U'.compareTo(firstLetter) <= 0 &&
        'Z'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['U-Z']!;
    }

    return Colors.black; // Default to black if letter not found
  }

  Color getTextColor(String username) {
    if (username.isEmpty) {
      return Colors.black; // Default color for empty username
    }

    // Map letter ranges to darker colors
    Map<String, Color> letterRangeColors = {
      'A-E': const Color(0xFFC2185B), // Dark Pink
      'F-J': const Color(0xFF1976D2), // Dark Blue
      'K-O': const Color(0xFF388E3C), // Dark Green
      'P-T': const Color(0xFFF57C00), // Dark Orange
      'U-Z': const Color(0xFFF57C00), // Dark Yellow
    };

    String firstLetter = username[0].toUpperCase();

    // Determine the color based on the first letter
    if ('A'.compareTo(firstLetter) <= 0 && 'E'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['A-E']!;
    } else if ('F'.compareTo(firstLetter) <= 0 &&
        'J'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['F-J']!;
    } else if ('K'.compareTo(firstLetter) <= 0 &&
        'O'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['K-O']!;
    } else if ('P'.compareTo(firstLetter) <= 0 &&
        'T'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['P-T']!;
    } else if ('U'.compareTo(firstLetter) <= 0 &&
        'Z'.compareTo(firstLetter) >= 0) {
      return letterRangeColors['U-Z']!;
    }

    return Colors.black; // Default to black if letter not found
  }

  //// int to format
  String showPriceAsThousandSeparator(int number) {
    final String formattedNumber = NumberFormat("###,###,###").format(number);
    return formattedNumber;
  }

  //// date
  final dateformat = DateFormat("dd/MM/yyyy");

  showDateAsDDMMYYYY(DateTime datetime) {
    String formattedDate = dateformat.format(datetime);
    return formattedDate;
  }

  showDateAsDDMMYYYYToDateTime(String date) {
    DateTime formattedDate = dateformat.parse(date);
    return formattedDate;
  }

  final dateformatForChart = DateFormat("dd MMM");

  showDateAsddMMM(DateTime datetime) {
    String formattedDate = dateformatForChart.format(datetime);
    return formattedDate;
  }

  showDateAsddMMMToDateTime(String date) {
    DateTime formattedDate = dateformatForChart.parse(date);
    return formattedDate;
  }

  final dateformatForAPI = DateFormat("yyyy-MM-dd");

  showDateAsYYYYMMDD(DateTime datetime) {
    String formattedDate = dateformatForAPI.format(datetime);
    return formattedDate;
  }

  showDateAsYYYYMMDDToDateTime(String date) {
    DateTime formattedDate = dateformatForAPI.parse(date);
    return formattedDate;
  }

  getCurrentYear(aStatus) {
    var date = DateFormat("dd/MM/yyyy").format(DateTime.now());
    var year;
    if (aStatus == "max") {
      year = int.parse(date.substring(6, 10)) + 1;
      return DateTime(year, 12, 31);
    } else {
      year = int.parse(date.substring(6, 10)) - 20;
      return DateTime(year, 01, 01);
    }
  }

  void showDatePicker({
    required BuildContext context,
    required void Function()? onPressed,
    required void Function(DateTime) dateOnChange,
    required DateTime date,
  }) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: primaryColor),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  onPressed: onPressed,
                  child: Text(
                    'Done',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: date,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: dateOnChange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // get mon to sun
  DateTime getStartOfWeek(DateTime date) {
    int subtractDays = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: subtractDays));
  }

  DateTime getEndOfWeek(DateTime date) {
    int addDays = DateTime.sunday - date.weekday;
    return date.add(Duration(days: addDays));
  }

  Map<String, DateTime> getWeeklyDateRange(DateTime date) {
    DateTime startOfWeek = getStartOfWeek(date);
    DateTime endOfWeek = getEndOfWeek(date);

    return {
      "startOfWeek": startOfWeek,
      "endOfWeek": endOfWeek,
    };
  }

  // get last six days
  List<String> getLastSixDays() {
    List<String> dates = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: i));
      String formattedDate = DateFormat("ddMMM").format(date);
      dates.add(formattedDate);
    }

    // 25Jan
    return dates;
  }

  Map<String, dynamic> getLastSixDaysFromTo() {
    List<String> dates = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: i));
      // String formattedDate = DateFormat("ddMMM").format(date);
      String formattedDate = showDateAsYYYYMMDD(date);
      dates.add(formattedDate);
    }

    Map<String, dynamic> fromToDate = {
      "from": dates.last,
      "to": dates.first,
    };

    return fromToDate;
  }

  Future<bool> checkInternetConnection() async {
    bool result = await InternetConnection().hasInternetAccess;
    if (!result) {
      showSnackBar("No Internet Connection!", false);
    }
    return result;
  }
}
