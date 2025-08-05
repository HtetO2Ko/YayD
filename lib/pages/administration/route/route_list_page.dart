import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/route_model.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class RouteListPage extends StatefulWidget {
  const RouteListPage({super.key});

  @override
  State<RouteListPage> createState() => _RouteListPageState();
}

class _RouteListPageState extends State<RouteListPage> {
  bool _loading = false;
  //// data
  // list
  List<RouteModel> routeList = [];

  // entry
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  /// apis
  Future<void> getRoutes() async {
    setState(() {
      _loading = true;
    });
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

  Future<bool> createRoute() async {
    bool dataResult = false;
    var param = jsonEncode({
      "title": _titleController.text,
      "description": _descController.text,
      "t1": "",
      "t2": "",
      "t3": ""
    });
    await API().createRoute(param).then((result) {
      if (result) {
        showCreateSuccessMsg("route");
        dataResult = result;
      }
      _titleController.clear();
      _descController.clear();
    });
    return dataResult;
  }

  Future<bool> updateRoute(id) async {
    bool dataResult = false;
    var param = jsonEncode({
      "title": _titleController.text,
      "description": _descController.text,
      "t1": "",
      "t2": "",
      "t3": ""
    });
    await API().updateRoute(param, id).then((result) {
      if (result) {
        showUpdateSuccessMsg("route");
        dataResult = result;
      }
      _titleController.clear();
      _descController.clear();
    });
    return dataResult;
  }

  Future<bool> deleteRoute(id) async {
    bool isSuccess = await API().deleteRoute(id);
    setState(() {
      showDeleteSuccessMsg("route");
      Navigator.pop(context);
    });
    return isSuccess;
  }

  //
  validateRouteData() {
    bool isValid = false;
    if (_titleController.text == "") {
      showRequiredMsg("route_name");
    } else {
      isValid = true;
    }
    setState(() {});
    return isValid;
  }

  Future addAndEditRoute(String id) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    id == "" ? "add_new_route".tr() : "update_route".tr(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomTextfieldWithLabel(
                    label: "route_name",
                    controller: _titleController,
                    prefixIcon: null,
                    suffixIcon: null,
                    obscureText: false,
                    onChanged: (value) {},
                    onSubmitted: (value) {},
                    hintText: '',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextfieldWithLabel(
                    label: "route_desc",
                    controller: _descController,
                    prefixIcon: null,
                    suffixIcon: null,
                    obscureText: false,
                    onChanged: (value) {},
                    onSubmitted: (value) {},
                    hintText: '',
                    maxLine: 5,
                    textFieldHeight: 100,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.5, color: Colors.grey),
                              borderRadius: BorderRadius.circular(5)),
                          alignment: Alignment.center,
                          child: Text("cancel".tr(),
                              style: TextStyle(color: primaryColor)),
                        ),
                        onTap: () {
                          _titleController.clear();
                          _descController.clear();
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        child: Container(
                          height: 40,
                          // width: 70,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: primaryColor),
                          alignment: Alignment.center,
                          child: Text(
                            // id == "" ? "save".tr() : "update".tr(),
                            "save".tr(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () async {
                          await Functionprovider()
                              .checkInternetConnection()
                              .then((result) async {
                            if (result) {
                              showLoadingDialog(context);
                              final isValid = await validateRouteData();
                              if (isValid) {
                                bool result = false;
                                if (id == "") {
                                  result = await createRoute();
                                } else {
                                  result = await updateRoute(id);
                                }
                                if (result) {
                                  await getRoutes();
                                  Navigator.pop(context);
                                }
                              }
                              Navigator.pop(context);
                            }
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  deleteConfirmDialog(id) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Are you sure you want to delete?".tr(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.5, color: Colors.grey),
                              borderRadius: BorderRadius.circular(5)),
                          alignment: Alignment.center,
                          child: Text("cancel".tr(),
                              style: TextStyle(color: primaryColor)),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      InkWell(
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.red),
                          alignment: Alignment.center,
                          child: Text(
                            "delete".tr(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () async {
                          await Functionprovider()
                              .checkInternetConnection()
                              .then((result) async {
                            if (result) {
                              showLoadingDialog(context);
                              bool isSuccess = await deleteRoute(id);
                              if (isSuccess) {
                                getRoutes();
                              }
                              Navigator.pop(context);
                            }
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  initData() {
    getRoutes();
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: customAppBar(
          title: "routes",
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
                      "no_data".tr(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: routeList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    _titleController.text =
                                        routeList[index].title!;
                                    _descController.text =
                                        routeList[index].description!;
                                    addAndEditRoute(
                                        routeList[index].id.toString());
                                  },
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'edit'.tr(),
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    deleteConfirmDialog(routeList[index].id);
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'delete'.tr(),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 15,
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        routeList[index].title!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        routeList[index].description!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 0.5,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
        floatingActionButton: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50), color: primaryColor),
          child: GestureDetector(
            onTap: () {
              addAndEditRoute("");
            },
            child: Center(
                child: Icon(
              Icons.add,
              size: 25,
              color: Colors.white,
            )),
          ),
        ),
      ),
    );
  }
}
