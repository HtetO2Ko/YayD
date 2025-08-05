import 'package:flutter/material.dart';
import 'package:yay_thant/config/dataconfig.dart';
import 'package:yay_thant/function_provider.dart';

final dataconfig = Dataconfig();
final provider = Functionprovider();
bool isDeliveryMan = false;
Map<String, dynamic> currentUserData = {};
String hasToken = dataconfig.getToken();

double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

List tabsListForMgr = [
  {
    'id': 1,
    'icon': "assets/icons/home.svg",
    'name': 'home',
  },
  {
    'id': 2,
    'icon': "assets/icons/summary.svg",
    'name': 'summary',
  },
  {
    'id': 3,
    'icon': "assets/icons/administration.svg",
    'name': 'administration',
  },
  {
    'id': 4,
    'icon': "assets/icons/more.svg",
    'name': 'more',
  },
];

List tabsListForDeli = [
  {
    'id': 1,
    'icon': "assets/icons/home.svg",
    'name': 'home',
  },
  {
    'id': 2,
    'icon': "assets/icons/summary.svg",
    'name': 'map',
  },
  {
    'id': 3,
    'icon': "assets/icons/summary.svg",
    'name': 'history',
  },
  {
    'id': 4,
    'icon': "assets/icons/administration.svg",
    'name': 'retail',
  },
  {
    'id': 5,
    'icon': "assets/icons/more.svg",
    'name': 'more',
  },
];
