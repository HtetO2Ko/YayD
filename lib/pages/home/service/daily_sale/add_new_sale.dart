import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/config/dataconfig.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/constants/localstr.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/customerbyroute_model.dart';
import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/storage_util.dart';
import 'package:yay_thant/widgets/choose_item_page.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_button.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class AddNewSalePage extends StatefulWidget {
  final CustomerByRouteModel? customer;
  const AddNewSalePage({
    super.key,
    this.customer,
  });

  @override
  State<AddNewSalePage> createState() => _AddNewSalePageState();
}

class _AddNewSalePageState extends State<AddNewSalePage> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _receiveAmtController = TextEditingController();
  bool isLoading = false;
  int totalPrice = 0;
  List<ItemModel> selectedStockList = [];
  List<ItemModel> selectedReturnStockList = [];
  final _provider = Functionprovider();

  Future chooseItem(isReturn) async {
    List<ItemModel>? data = await showCupertinoModalBottomSheet(
      enableDrag: false,
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChooseItemListPage(
        selectItemList: isReturn ? selectedReturnStockList : selectedStockList,
        itemWithQty: true,
        delimanTranType: isReturn ? "RETURN" : "SALE",
      ),
    );

    if (data != null) {
      if (isReturn) {
        selectedReturnStockList = data.map((item) => item.clone()).toList();
      } else {
        selectedStockList = data.map((item) => item.clone()).toList();
        for (var stock in selectedStockList) {
          totalPrice = totalPrice + (stock.price! * stock.qty!.toInt());
        }
      }
    }

    setState(() {});
  }

  Future addProductList(List<ItemModel> productList) async {
    List products = [];
    for (var product in productList) {
      products.add({"product": product.id, "qty": product.qty});
    }
    return products;
  }

  void createNewSale() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> userData = Dataconfig().getCurrentUserData();
    String tranId = StorageUtils.getString(chosenTranId);
    List saleProducts = await addProductList(selectedStockList);
    List returnProducts = await addProductList(selectedReturnStockList);
    var param = jsonEncode({
      "products": saleProducts,
      "customer": widget.customer!.id,
      "saleBy": userData["_id"],
      "returnProducts": returnProducts,
      "receiveAmount": _receiveAmtController.text,
      "transportId": tranId,
      "remark": _noteController.text,
      "t1": "",
      "t2": "",
      "t3": ""
    });
    print("param >> $param");
    await API().createNewSale(param).then((result) {
      if (result) {
        showCreateSuccessMsg("Sale");
        Navigator.pop(context, true);
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  showDiscardDialog() {
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
                    "Are you sure you want to discard sale?".tr(),
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
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.red),
                          alignment: Alignment.center,
                          child: Text(
                            "confirm".tr(),
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _receiveAmtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "${"deliver_water_bottle".tr()} (${widget.customer!.name})",
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: CustomTextfieldWithLabel(
                  label: "recieve_amt".tr(),
                  controller: _receiveAmtController,
                  prefixIcon: null,
                  suffixIcon: null,
                  obscureText: false,
                  onChanged: (value) {},
                  onSubmitted: (value) {},
                  hintText: '',
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: CustomTextfieldWithLabel(
                  label: "remark",
                  controller: _noteController,
                  prefixIcon: null,
                  suffixIcon: null,
                  obscureText: false,
                  onChanged: (value) {},
                  onSubmitted: (value) {},
                  hintText: '',
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
                            selectedStockList.isEmpty
                                ? "stock_type".tr()
                                : "${"stock_type".tr()} (${_provider.showPriceAsThousandSeparator(totalPrice)} Ks)",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          selectedStockList.isEmpty
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.only(left: 13),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        chooseItem(false);
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
                    selectedStockList.isEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                chooseItem(false);
                              });
                            },
                            child: Container(
                              height: 40,
                              color: Colors.transparent,
                              margin: const EdgeInsets.symmetric(vertical: 8),
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
                            itemCount: selectedStockList.length,
                            itemBuilder: (context, index) {
                              return Slidable(
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.3,
                                  children: [
                                    SlidableAction(
                                      label: "Delete",
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      onPressed: (context) {
                                        setState(() {
                                          selectedStockList.removeAt(index);
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
                                              selectedStockList[index]
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
                                              "${"price".tr()}: ${selectedStockList[index].price}",
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
                                        selectedStockList[index].qty.toString(),
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
                            "return_product".tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          selectedReturnStockList.isEmpty
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.only(left: 13),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        chooseItem(true);
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
                    selectedReturnStockList.isEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                chooseItem(true);
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
                            itemCount: selectedReturnStockList.length,
                            itemBuilder: (context, index) {
                              return Slidable(
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      label: "delete",
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      onPressed: (context) {
                                        setState(() {
                                          selectedReturnStockList
                                              .removeAt(index);
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedReturnStockList[index]
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
                                            "Price: ${selectedReturnStockList[index].price}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        selectedReturnStockList[index]
                                            .qty
                                            .toString(),
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
          child: CustomButton(
            buttonText: "save",
            isLoading: isLoading,
            onTap: () {
              if (selectedStockList.isEmpty) {
                showRequiredMsg("Added Stocks");
              } else {
                Functionprovider().checkInternetConnection().then((result) {
                  if (result) {
                    createNewSale();
                  }
                });
              }
            },
          )),
    );
  }
}
