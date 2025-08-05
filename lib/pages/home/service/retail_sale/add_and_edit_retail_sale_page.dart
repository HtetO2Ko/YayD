// ignore_for_file: use_build_context_synchronously

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
import 'package:yay_thant/constants/localstr.dart';
import 'package:yay_thant/constants/textstyle.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/models/retail_sale_model.dart';
import 'package:yay_thant/models/route_model.dart';
import 'package:yay_thant/storage_util.dart';
import 'package:yay_thant/widgets/choose_item_page.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_button.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';
import 'package:yay_thant/widgets/tap_address_from_map.dart';

class AddAndEditRetailSalePage extends StatefulWidget {
  final RetailSaleModel? editRetailSale;
  const AddAndEditRetailSalePage({
    super.key,
    this.editRetailSale,
  });

  @override
  State<AddAndEditRetailSalePage> createState() =>
      _AddAndEditRetailSalePageState();
}

class _AddAndEditRetailSalePageState extends State<AddAndEditRetailSalePage> {
  EdgeInsets textfieldMargin =
      EdgeInsets.symmetric(horizontal: 15, vertical: 5);
  EdgeInsets labelMargin = EdgeInsets.only(left: 15, top: 5);
  bool isLoading = false;
  // data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  LatLng? address;
  List<ItemModel> selectItemList = [];
  bool isAddCust = false;
  List<RouteModel> routeList = [];
  String _selectedRouteID = "-";
  // editdata
  RetailSaleModel? editRetailSale;

  //// apis
  Future<void> getRoutes() async {
    routeList = [
      RouteModel(
        id: "-",
        title: "-",
        description: "",
        t1: "",
        t2: "",
        t3: "",
        createdAt: null,
        updatedAt: null,
        v: 0,
      )
    ];
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllRoute().then((routes) {
          if (routes.isNotEmpty) {
            for (RouteModel route in routes) {
              routeList.add(route);
            }
          }
        });
      }
    });
    setState(() {
      if (routeList.isNotEmpty) {
        if (editRetailSale != null) {
        } else {
          _selectedRouteID = routeList[0].id ?? "";
        }
      }
    });
  }

  void createRetailSale() async {
    final isValid = await checkValidate();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      List products = await productListToAPI();
      String tranId = StorageUtils.getString(chosenTranId);
      var param = jsonEncode({
        "transportId": tranId,
        "products": products,
        "name": _nameController.text,
        "phone": _phoneController.text,
        "email": _emailController.text,
        "address": _addressController.text,
        "saleBy": currentUserData["_id"],
        "t1": "",
        "t2": "",
        "t3": ""
      });
      await API().createRetailSale(param).then((result) {
        if (result) {
          showCreateSuccessMsg("retail_sale");
          if (!isAddCust) {
            Navigator.pop(context, true);
          }
        }
      });
      print("selected route id >> $_selectedRouteID");
      if (isAddCust && _selectedRouteID != "-") {
        List<String> selectedItems = [];
        for (var item in selectItemList) {
          selectedItems.add(item.id!);
        }
        var param = jsonEncode({
          "route": _selectedRouteID,
          "products": selectedItems,
          "name": _nameController.text,
          "phone": _phoneController.text,
          "email": _emailController.text,
          "address": _addressController.text,
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
            Navigator.pop(context, true);
          }
        });
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void editRetailSaleAPI() async {
    final isValid = await checkValidate();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      List products = await productListToAPI();
      var param = jsonEncode({
        "products": products,
        "name": _nameController.text,
        "phone": _phoneController.text,
        "email": _emailController.text,
        "address": _addressController.text,
        "saleBy": currentUserData["_id"],
        "t1": "",
        "t2": "",
        "t3": ""
      });
      await API()
          .updateRetailSale(param, editRetailSale!.id.toString())
          .then((result) {
        if (result) {
          showUpdateSuccessMsg("retail_sale");
          Navigator.pop(context, true);
        }
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  deleteRetailSale() async {
    bool isSuccess = await API().deleteRetailSale(editRetailSale!.id);
    setState(() {
      Navigator.pop(context);
    });
    return isSuccess;
  }

  //
  checkValidate() {
    bool isValid = false;
    if (_nameController.text == "") {
      showRequiredMsg("name");
    } else if (_phoneController.text == "") {
      showRequiredMsg("ph");
    } else if (selectItemList.isEmpty) {
      showChooseMsg("stock_type", context);
    } else if (isAddCust && _selectedRouteID == "-") {
      showChooseMsg("route", context);
    } else {
      isValid = true;
    }
    setState(() {});
    return isValid;
  }

  Future chooseItem() async {
    List<ItemModel>? data = await showCupertinoModalBottomSheet(
      enableDrag: false,
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => isDeliveryMan
          ? ChooseItemListPage(
              selectItemList: selectItemList,
              itemWithQty: true,
              delimanTranType: "SALE",
            )
          : ChooseItemListPage(
              selectItemList: selectItemList,
              itemWithQty: true,
            ),
    );
    setState(() {
      if (data != null) {
        selectItemList = data.map((item) => item.clone()).toList();
      }
    });
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
                        onTap: () async {
                          await Functionprovider()
                              .checkInternetConnection()
                              .then((result) async {
                            if (result) {
                              showLoadingDialog(context);
                              final isSuccess = await deleteRetailSale();
                              setState(() {});
                              if (isSuccess) {
                                showDeleteSuccessMsg("retail_sale");
                                Navigator.pop(context, isSuccess);
                                Navigator.pop(context, isSuccess);
                              }
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

  productListToAPI() {
    List productsList = [];
    for (ItemModel item in selectItemList) {
      productsList.add(
        {"product": item.id, "qty": item.qty},
      );
    }
    return productsList;
  }

  productAPIToList() {
    selectItemList = [];
    editRetailSale!.products?.forEach((product) {
      selectItemList.add(ItemModel(
        id: product.product!.id,
        title: product.product!.title,
        description: product.product!.description,
        price: product.product!.price,
        retailPrice: product.product!.retailPrice,
        deliverable: product.product!.deliverable,
        collectable: product.product!.collectable,
        images: product.product!.images,
        t1: product.product!.t1,
        t2: product.product!.t2,
        t3: product.product!.t3,
        v: product.product!.v,
        qty: product.qty,
        check: true,
      ));
    });
    setState(() {});
  }

  initData() {
    // editRetailSale = widget.editRetailSale.map((item) => item.clone()).toList();
    if (widget.editRetailSale != null) {
      editRetailSale = widget.editRetailSale!.clone();
      bindEditData();
    }
    print(currentUserData);
    setState(() {
      if (isDeliveryMan) {
      } else {
        getRoutes();
      }
    });
  }

  bindEditData() {
    _nameController.text = editRetailSale!.name!;
    _phoneController.text = editRetailSale!.phone!;
    _emailController.text = editRetailSale!.email!;
    _addressController.text = editRetailSale!.address!;
    productAPIToList();
    setState(() {});
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: editRetailSale == null
            ? "create_retail_sale"
            : "update_retail_sale",
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
      body: PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // delivery man
              // isDeliveryMan
              //     ? Container()
              //     : Padding(
              //         padding: labelMargin,
              //         child: Text(
              //           "delivery_man".tr(),
              //           style: Theme.of(context).textTheme.labelSmall,
              //         ),
              //       ),
              // isDeliveryMan
              //     ? Container()
              //     : Container(
              //         height: 40,
              //         margin: textfieldMargin,
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           border: Border.all(width: 1),
              //           borderRadius: BorderRadius.circular(5),
              //         ),
              //         child: DropdownButton(
              //           isExpanded: true,
              //           value: _selectDeliveryManID,
              //           items: deliverymanList.map((deliveryMan) {
              //             return DropdownMenuItem<String>(
              //               value: deliveryMan.id,
              //               child: Padding(
              //                 padding: const EdgeInsets.only(left: 20),
              //                 child: Text(deliveryMan.name.toString()),
              //               ),
              //             );
              //           }).toList(),
              //           onChanged: (String? newValue) {
              //             setState(() {
              //               _selectDeliveryManID = newValue!;
              //             });
              //           },
              //           underline: SizedBox.shrink(),
              //           icon: Icon(Icons.arrow_drop_down),
              //         ),
              //       ),
              // name
              CustomTextfieldWithLabel(
                label: "name",
                controller: _nameController,
                hintText: "",
                prefixIcon: null,
                suffixIcon: null,
                obscureText: false,
                onChanged: (value) {},
                onSubmitted: (value) {},
                margin: textfieldMargin,
                labelMargin: labelMargin,
              ),
              // phone
              CustomTextfieldWithLabel(
                label: "ph",
                controller: _phoneController,
                hintText: "",
                prefixIcon: null,
                suffixIcon: null,
                obscureText: false,
                onChanged: (value) {},
                onSubmitted: (value) {},
                margin: textfieldMargin,
                labelMargin: labelMargin,
                keyboardType: TextInputType.number,
                inputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              // email
              CustomTextfieldWithLabel(
                label: "email",
                controller: _emailController,
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
                      controller: _addressController,
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
                      if (_addressController.text == "") {
                        if (address != null) {
                          _addressController.text =
                              await getAddressNameWithLatLong(
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
              // add customer
              isDeliveryMan
                  ? Container()
                  : editRetailSale != null
                    ? Container()
                    : GestureDetector(
                      onTap: () {
                        setState(() {
                          isAddCust = !isAddCust;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            activeColor: primaryColor,
                            value: isAddCust,
                            onChanged: (value) {
                              isAddCust = !isAddCust;
                              setState(() {});
                            },
                          ),
                          Text(
                            "create_customer".tr(),
                            style: labelTextStyle,
                          ),
                        ],
                      ),
                    ),
              // route
              isAddCust && editRetailSale == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        )
                      ],
                    )
                  : Container(),
              // stock
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 20, top: 8, bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: screenWidth(context) * 0.7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectItemList[index]
                                                  .title
                                                  .toString(),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              "Price: ${selectItemList[index].price}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF374151),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        selectItemList[index].qty.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
        child: editRetailSale == null
            ? CustomButton(
                buttonText: "save",
                isLoading: isLoading,
                onTap: () {
                  Functionprovider().checkInternetConnection().then((result) {
                    if (result) {
                      createRetailSale();
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
                      isLoading: false,
                      onTap: showDeleteDialog,
                      buttonColor: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      buttonText: "save",
                      isLoading: isLoading,
                      onTap: () {
                        Functionprovider()
                            .checkInternetConnection()
                            .then((result) {
                          if (result) {
                            editRetailSaleAPI();
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
