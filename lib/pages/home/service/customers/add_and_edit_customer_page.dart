import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/customer_model.dart';
import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/models/route_model.dart';
import 'package:yay_thant/widgets/choose_item_page.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_button.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';
import 'package:yay_thant/widgets/tap_address_from_map.dart';

class AddandEditCustPage extends StatefulWidget {
  final CustomerModel? customerData;
  final bool isUpdate;
  final String? routeID;
  const AddandEditCustPage({
    super.key,
    this.customerData,
    required this.isUpdate,
    this.routeID,
  });

  @override
  State<AddandEditCustPage> createState() => _AddandEditCustPageState();
}

class _AddandEditCustPageState extends State<AddandEditCustPage> {
  EdgeInsets textfieldMargin =
      EdgeInsets.symmetric(horizontal: 15, vertical: 5);
  bool _saveLoading = false;
  bool _deleteLoading = false;
  EdgeInsets labelMargin = EdgeInsets.only(left: 15, top: 5);
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController phCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();
  LatLng? address;
  Map<String, dynamic> currentUserData = {};
  List<ItemModel> selectItemList = [];
  String _selectedRouteID = "-";
  List<RouteModel> routeList = [];
  //
  CustomerModel? editCustData;

  //// apis
  Future<void> createCustomer() async {
    final isValid = await validCustData();
    if (isValid) {
      setState(() {
        _saveLoading = true;
      });
      List<String> selectedItems = [];
      for (var item in selectItemList) {
        selectedItems.add(item.id!);
      }
      var param = jsonEncode({
        "route": _selectedRouteID,
        "products": selectedItems,
        "name": nameCtrl.text,
        "phone": phCtrl.text,
        "email": emailCtrl.text,
        "address": addressCtrl.text,
        "location": address == null
            ? {"lat": "", "lon": ""}
            : {"lat": "${address!.latitude}", "lon": "${address!.longitude}"},
        "active": true,
        "t1": "",
        "t2": "",
        "t3": ""
      });
      await API().createCustomer(param).then((result) {
        if (result) {
          showCreateSuccessMsg("cust");
          Navigator.pop(context);
        }
      });
      setState(() {
        _saveLoading = false;
      });
    }
  }

  Future<void> updateCustomer(bool isUpdateData) async {
    final isValid = await validCustData();
    if (isValid) {
      if (isUpdateData) {
        _saveLoading = true;
      } else {
        showLoadingDialog(context);
      }
      setState(() {});
      var param;
      List<String> selectedItems = [];
      for (var item in selectItemList) {
        selectedItems.add(item.id!);
      }
      if (isUpdateData) {
        param = jsonEncode({
          "route": _selectedRouteID,
          "products": selectedItems,
          "name": nameCtrl.text,
          "phone": phCtrl.text,
          "email": emailCtrl.text,
          "address": addressCtrl.text,
          "location": address == null
              ? {"lat": "", "lon": ""}
              : {"lat": "${address!.latitude}", "lon": "${address!.longitude}"},
          "active": true,
          "t1": "",
          "t2": "",
          "t3": ""
        });
      } else {
        param = jsonEncode({
          "route": editCustData!.route!.id,
          "products":
              editCustData!.products!.map((product) => product.id).toList(),
          "name": editCustData!.name,
          "phone": editCustData!.phone,
          "email": editCustData!.email,
          "address": editCustData!.address,
          "location": address == null
              ? {"lat": "", "lon": ""}
              : {"lat": "${address!.latitude}", "lon": "${address!.longitude}"},
          "active": false,
          "t1": "",
          "t2": "",
          "t3": ""
        });
      }
      await API().updateCustomer(param, editCustData!.id).then((result) {
        if (result) {
          if (isUpdateData) {
            showUpdateSuccessMsg("cust");
          } else {
            Navigator.pop(context);
            Navigator.pop(context);
            showDeleteSuccessMsg("cust");
          }
          Navigator.pop(context, true);
        }
      });
      setState(() {
        _saveLoading = false;
      });
    }
  }

  Future<void> deleteCustomer() async {
    setState(() {
      _deleteLoading = true;
      Navigator.pop(context);
    });
    await API().changeCustomerStatus(editCustData!.id!, 2).then((result) {
      if (result) {
        showDeleteSuccessMsg("cust");
      }
      Navigator.pop(context, true);
    });
    setState(() {
      _deleteLoading = false;
    });
  }

  //
  validCustData() {
    bool isValid = false;
    if (nameCtrl.text == "") {
      showRequiredMsg("name");
    } else if (phCtrl.text == "") {
      showRequiredMsg("ph");
    } else if (_selectedRouteID == "-") {
      showChooseMsg("route", context);
    } else if (selectItemList.isEmpty) {
      showChooseMsg("stock_type", context);
    } else {
      isValid = true;
    }
    setState(() {});
    return isValid;
  }

  showDeleteDialog() {
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
                          padding: EdgeInsets.only(left: 10, right: 10),
                          height: 40,
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
                        width: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Functionprovider()
                              .checkInternetConnection()
                              .then((result) {
                            if (result) {
                              deleteCustomer();
                            }
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.red),
                          alignment: Alignment.center,
                          child: Text(
                            "delete".tr(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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

  Future chooseItem() async {
    List<ItemModel>? data = await showCupertinoModalBottomSheet(
      enableDrag: false,
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChooseItemListPage(
        selectItemList: selectItemList,
        itemWithQty: false,
      ),
    );
    setState(() {
      if (data != null) {
        selectItemList = data.map((item) => item.clone()).toList();
      }
    });
  }

  Future<void> getRoutes() async {
    routeList = [];
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllRoute().then((routes) {
          if (routes.isNotEmpty) {
            routeList.add(RouteModel(id: "-", title: "-"));
            for (var route in routes) {
              routeList.add(route);
            }
          }
        });
      }
    });
    if (routeList.isNotEmpty) {
      setState(() {
        if (editCustData == null) {
          _selectedRouteID = routeList[0].id ?? "";
        }
        if (widget.routeID != null && widget.routeID != "") {
          _selectedRouteID = widget.routeID!;
        }
      });
    }
  }

  initData() {
    getRoutes();
    if (widget.isUpdate) {
      bindEditCustData();
    }
  }

  bindEditCustData() {
    editCustData = widget.customerData;
    nameCtrl.text = editCustData!.name!;
    emailCtrl.text = editCustData!.email ?? "";
    phCtrl.text = editCustData!.phone ?? "";
    addressCtrl.text = editCustData!.address ?? "";
    if (editCustData!.location != null &&
        editCustData!.location!.lat != "" &&
        editCustData!.location!.lon != "") {
      address = LatLng(
        double.parse(editCustData!.location!.lat),
        double.parse(editCustData!.location!.lon),
      );
    }
    _selectedRouteID = editCustData!.route!.id!;
    selectItemList =
        editCustData!.products!.map((item) => item.clone()).toList();
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: customAppBar(
          title: editCustData == null ? "create_customer" : "update_customer",
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextfieldWithLabel(
                label: "name",
                controller: nameCtrl,
                hintText: "",
                prefixIcon: null,
                suffixIcon: null,
                obscureText: false,
                onChanged: (value) {},
                onSubmitted: (value) {},
                margin: textfieldMargin,
                labelMargin: labelMargin,
              ),
              CustomTextfieldWithLabel(
                label: "ph",
                controller: phCtrl,
                hintText: "",
                prefixIcon: null,
                suffixIcon: null,
                obscureText: false,
                keyboardType: TextInputType.number,
                inputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {},
                onSubmitted: (value) {},
                margin: textfieldMargin,
                labelMargin: labelMargin,
              ),
              CustomTextfieldWithLabel(
                label: "email",
                controller: emailCtrl,
                hintText: "",
                prefixIcon: null,
                suffixIcon: null,
                obscureText: false,
                onChanged: (value) {},
                onSubmitted: (value) {},
                margin: textfieldMargin,
                labelMargin: labelMargin,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomTextfieldWithLabel(
                      label:
                          "Address\n(Latitude - ${address?.latitude == null ? "" : (address?.latitude)!.toStringAsFixed(6)} / Longitude - ${address?.longitude == null ? "" : (address?.longitude)!.toStringAsFixed(6)})",
                      controller: addressCtrl,
                      hintText: "",
                      prefixIcon: null,
                      suffixIcon: null,
                      obscureText: false,
                      onChanged: (value) {},
                      onSubmitted: (value) {},
                      textFieldHeight: 90,
                      maxLine: 3,
                      margin: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      labelMargin: labelMargin,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final getAddress = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TapAddressPage(
                            selectedLocation: address,
                          ),
                        ),
                      );
                      address = getAddress;
                      if (addressCtrl.text == "") {
                        if (address != null) {
                          addressCtrl.text = await getAddressNameWithLatLong(
                            address!.latitude,
                            address!.longitude,
                          );
                        }
                        setState(() {});
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 30),
                      width: screenHeight(context) * 0.05,
                      height: 40,
                      child: Image.asset("assets/icons/add-location.png"),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  )
                ],
              ),
              // Padding(
              //   padding: labelMargin,
              //   child: Text(
              //     "Add Location",
              //     style: labelTextStyle,
              //   ),
              // ),
              // Row(
              //   children: [
              //     InkWell(
              //       onTap: () async {
              //         final getAddress = await Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => TapAddressPage(
              //               selectedLocation: address,
              //             ),
              //           ),
              //         );
              //         address = getAddress;
              //         if (addressCtrl.text == "") {
              //           if (address != null) {
              //             addressCtrl.text = await getAddressNameWithLatLong(
              //               address!.latitude,
              //               address!.longitude,
              //             );
              //           }
              //           setState(() {});
              //         }
              //       },
              //       child: Container(
              //         margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              //         width: screenHeight(context) * 0.07,
              //         height: 50,
              //         child: SvgPicture.asset("assets/icons/add-location.svg"),
              //       ),
              //     ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         RichText(
              //           text: TextSpan(
              //             children: [
              //               TextSpan(
              //                 text: "Latitude - ",
              //                 style: TextStyle(color: Colors.black)
              //               ),
              //               TextSpan(
              //                 text: address?.latitude == null ? "" : (address?.latitude)!.toStringAsFixed(6),
              //                 style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)
              //               )
              //             ]
              //           ),
              //         ),
              //         SizedBox(height: 10),
              //         RichText(
              //           text: TextSpan(
              //             children: [
              //               TextSpan(
              //                 text: "Longitude - ",
              //                 style: TextStyle(color: Colors.black)
              //               ),
              //               TextSpan(
              //                 text: address?.longitude == null ? "" : (address?.longitude)!.toStringAsFixed(6),
              //                 style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)
              //               )
              //             ]
              //           ),
              //         )
              //       ]
              //     ),
              //   ],
              // ),
              Padding(
                padding: labelMargin,
                child: Text(
                  "route".tr(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Container(
                height: 40,
                margin: textfieldMargin,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButton(
                  isExpanded: true,
                  value: _selectedRouteID,
                  items: routeList.map((route) {
                    return DropdownMenuItem<String>(
                      value: route.id,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(route.title.toString()),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRouteID = newValue!;
                    });
                  },
                  underline: SizedBox.shrink(),
                  icon: Icon(Icons.arrow_drop_down),
                ),
              ),
              Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 8, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "stock_type".tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              selectItemList.isEmpty
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 13),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            chooseItem();
                                          });
                                        },
                                        child: Icon(
                                          Icons.add,
                                          size: 23,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        selectItemList.isEmpty
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    chooseItem();
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  color: Colors.transparent,
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Center(
                                    child: Text(
                                      "create_stock".tr(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: selectItemList.length,
                                itemBuilder: (context, index) {
                                  return Slidable(
                                    endActionPane: ActionPane(
                                      motion: const DrawerMotion(),
                                      extentRatio: 0.3,
                                      children: [
                                        SlidableAction(
                                          label: "delete",
                                          backgroundColor: Colors.red,
                                          icon: Icons.delete,
                                          onPressed: (context) {
                                            setState(() {
                                              selectItemList.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      width: screenWidth(context),
                                      margin: const EdgeInsets.only(
                                          left: 16,
                                          right: 20,
                                          top: 8,
                                          bottom: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: screenWidth(context) * 0.9,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectItemList[index]
                                                      .title
                                                      .toString(),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  selectItemList[index]
                                                      .description
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        const Color(0xFF374151),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ])),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: isDeliveryMan
              ? const EdgeInsets.only(left: 5, right: 5, bottom: 70)
              : const EdgeInsets.only(left: 5, right: 5, bottom: 20),
          child: !widget.isUpdate
              ? CustomButton(
                  buttonText: "save",
                  isLoading: _saveLoading,
                  onTap: () {
                    Functionprovider().checkInternetConnection().then((result) {
                      if (result) {
                        createCustomer();
                      }
                    });
                  },
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: "delete",
                        isLoading: _deleteLoading,
                        buttonColor: Colors.red,
                        onTap: () {
                          showDeleteDialog();
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        buttonText: "save",
                        isLoading: _saveLoading,
                        onTap: () {
                          Functionprovider()
                              .checkInternetConnection()
                              .then((result) {
                            if (result) {
                              updateCustomer(true);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
