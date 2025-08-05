// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/models/route_model.dart';
import 'package:yay_thant/models/tran_model.dart';
import 'package:yay_thant/models/user_model.dart';
import 'package:yay_thant/widgets/choose_item_page.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_button.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class AddAndEditWaterTranPage extends StatefulWidget {
  final String? title;
  final TranModel? editTranData;
  const AddAndEditWaterTranPage({
    super.key,
    this.title,
    this.editTranData,
  });

  @override
  State<AddAndEditWaterTranPage> createState() =>
      _AddAndEditWaterTranPageState();
}

class _AddAndEditWaterTranPageState extends State<AddAndEditWaterTranPage> {
  EdgeInsets textfieldMargin =
      EdgeInsets.symmetric(horizontal: 15, vertical: 5);
  EdgeInsets labelMargin = EdgeInsets.only(left: 15, top: 5);
  bool isLoading = false;
  // data
  String _selectDeliveryManID = "-";
  String _selectedRouteID = "-";
  // final TextEditingController _descController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  List<ItemModel> selectItemList = [];
  List<UserModel> deliverymanList = [];
  List<RouteModel> routeList = [];
  // editdata
  TranModel? editTranData;

  //// apis
  Future<void> getUserList() async {
    deliverymanList = [
      UserModel(
        active: true,
        id: "-",
        name: "-",
        email: "",
        phone: "",
        role: 0,
        createdAt: null,
        updatedAt: null,
        v: 0,
        avatar: "",
      )
    ];

    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllUser().then((users) {
          if (users.isNotEmpty) {
            for (var i = 0; i < users.length; i++) {
              switch (users[i].role) {
                case 0:
                  deliverymanList.add(users[i]);
                  break;
              }
            }
          }
        });
      }
    });
    setState(() {
      if (deliverymanList.isNotEmpty) {
        if (editTranData != null) {
          _selectDeliveryManID = editTranData!.deliveryMan!.id ?? "";
        } else {
          _selectDeliveryManID = deliverymanList[0].id ?? "";
        }
      }
    });
  }

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
        if (editTranData != null) {
          _selectedRouteID = editTranData!.route!.id ?? "";
        } else {
          _selectedRouteID = routeList[0].id ?? "";
        }
      }
    });
  }

  void createWaterTransport() async {
    final isValid = validWaterTranData();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      List products = await productListToAPI();
      var param = jsonEncode({
        "products": products,
        "deliveryMan": _selectDeliveryManID,
        "route": _selectedRouteID,
        "description": "",
        "remark": _remarkController.text,
        "status": true,
        "t1": "",
        "t2": "",
        "t3": ""
      });
      print(">> create tran body $param");
      await API().createWaterTran(param).then((result) {
        if (result) {
          showCreateSuccessMsg("tran_route");
          Navigator.pop(context, true);
        }
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  void editWaterTransport() async {
    final isValid = validWaterTranData();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      List products = await productListToAPI();
      var param = jsonEncode({
        "products": products,
        "deliveryMan": _selectDeliveryManID,
        "route": _selectedRouteID,
        "description": "",
        "remark": _remarkController.text,
        "status": true,
        "t1": "",
        "t2": "",
        "t3": ""
      });
      await API().updateWaterTran(param, editTranData!.id).then((result) {
        if (result) {
          showUpdateSuccessMsg("tran_route");
          Navigator.pop(context, true);
        }
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  deleteWaterTran() async {
    bool isSuccess = await API().deleteWaterTran(editTranData!.id);
    setState(() {
      Navigator.pop(context);
    });
    return isSuccess;
  }

  //
  bool validWaterTranData() {
    bool isValid = false;
    if (_selectDeliveryManID == "-") {
      showChooseMsg("delivery_man", context);
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

  Future chooseItem() async {
    List<ItemModel>? data = await showCupertinoModalBottomSheet(
      enableDrag: false,
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChooseItemListPage(
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
                              final isSuccess = await deleteWaterTran();
                              if (isSuccess) {
                                showDeleteSuccessMsg("tran_route");
                                Navigator.pop(context, isSuccess);
                                Navigator.pop(context, isSuccess);
                              }
                              setState(() {});
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
    editTranData!.products?.forEach((product) {
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
    if (widget.editTranData != null) {
      editTranData = widget.editTranData!.clone();
      bindEditData();
    }
    setState(() {
      getUserList();
      getRoutes();
    });
  }

  bindEditData() {
    _remarkController.text = editTranData!.remark.toString();
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
        title: widget.title,
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
              Padding(
                padding: labelMargin,
                child: Text(
                  "delivery_man".tr(),
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
                  value: _selectDeliveryManID,
                  items: deliverymanList.map((deliveryMan) {
                    return DropdownMenuItem<String>(
                      value: deliveryMan.id,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(deliveryMan.name.toString()),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectDeliveryManID = newValue!;
                    });
                  },
                  underline: SizedBox.shrink(),
                  icon: Icon(Icons.arrow_drop_down),
                ),
              ),
              // route
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
              // // desc
              // CustomTextfieldWithLabel(
              //   label: "desc",
              //   controller: _descController,
              //   hintText: "",
              //   prefixIcon: null,
              //   suffixIcon: null,
              //   obscureText: false,
              //   onChanged: (value) {},
              //   onSubmitted: (value) {},
              //   margin: textfieldMargin,
              //   labelMargin: labelMargin,
              // ),
              // remark
              CustomTextfieldWithLabel(
                label: "remark",
                controller: _remarkController,
                hintText: "",
                prefixIcon: null,
                suffixIcon: null,
                obscureText: false,
                onChanged: (value) {},
                onSubmitted: (value) {},
                margin: textfieldMargin,
                labelMargin: labelMargin,
              ),
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
                                child: Container(
                                  width: screenWidth(context),
                                  margin: const EdgeInsets.only(
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
                                              selectItemList[index]
                                                  .description
                                                  .toString(),
                                              maxLines: 3,
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
        child: editTranData == null
            ? CustomButton(
                buttonText: "save",
                isLoading: isLoading,
                onTap: () {
                  Functionprovider()
                      .checkInternetConnection()
                      .then((result) async {
                    if (result) {
                      createWaterTransport();
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
                            .then((result) async {
                          if (result) {
                            editWaterTransport();
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
