import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/config/dataconfig.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/localstr.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/models/retail_sale_model.dart';
import 'package:yay_thant/storage_util.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class ChooseItemListPage extends StatefulWidget {
  final List<ItemModel> selectItemList;
  final bool itemWithQty;
  final String? delimanTranType;
  const ChooseItemListPage({
    super.key,
    required this.selectItemList,
    required this.itemWithQty,
    this.delimanTranType,
  });

  @override
  State<ChooseItemListPage> createState() => _ChooseItemListPageState();
}

class _ChooseItemListPageState extends State<ChooseItemListPage> {
  final _dataConfig = Dataconfig();
  final _provider = Functionprovider();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> userData = {};
  List<TextEditingController> qtyCtrList = [];
  List<ItemModel> allItemList = [];
  List<ItemModel> itemList = [];
  List<ItemModel> selectItemList = [];
  List<int> maxQtys = [];
  bool _loading = false;

  initData() {
    userData = _dataConfig.getCurrentUserData();
    selectItemList = widget.selectItemList.map((item) => item.clone()).toList();
    setState(() {
      _loading = true;
      if (widget.delimanTranType == "SALE") {
        getAvailableItemList();
      } else {
        getItemList();
      }
    });
  }

  Future<void> getItemList() async {
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllItem().then((items) {
          if (items.isNotEmpty) {
            if (selectItemList.isNotEmpty) {
              for (ItemModel selectItem in selectItemList) {
                for (ItemModel item in items) {
                  if (item.id == selectItem.id) {
                    item.qty = selectItem.qty;
                    item.check = true;
                  }
                }
              }
            }
            allItemList = List.from(items);
            itemList = List.from(items);
            for (var item in itemList) {
              qtyCtrList.add(TextEditingController(text: item.qty.toString()));
            }
          }
          setState(() {
            _loading = false;
          });
        });
      } else{
        setState(() {
          _loading = false;
        });
      }
    });
  }

  Future<void> getAvailableItemList() async {
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        String tranId = StorageUtils.getString(chosenTranId);
        if (tranId != "") {
          await API().getAvailableItem(tranId).then((items) {
            if (selectItemList.isNotEmpty) {
              for (ItemModel selectItem in selectItemList) {
                for (ProductElement item in items) {
                  if (item.id == selectItem.id) {
                    item.product!.qty = selectItem.qty;
                    item.product!.check = true;
                  }
                }
              }
            }
            maxQtys = items.map((item) => item.qty! - item.soldQty!).toList();
            allItemList = items.map((item) => item.product!).toList();
            itemList = items.map((item) => item.product!).toList();
            for (var item in itemList) {
              qtyCtrList.add(TextEditingController(text: item.qty.toString()));
            }
            setState(() {
              _loading = false;
            });
          });
        } else {
          setState(() {
            _loading = false;
          });
        }
      }
    });
  }

  void filterItemList() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      itemList = allItemList
          .where((item) => item.title!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in qtyCtrList) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "stock_type",
        titleSpacing: 10,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 20,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context, null);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              CustomTextfield(
                controller: _searchController,
                hintText: "search",
                prefixIcon: null,
                suffixIcon: null,
                obscureText: false,
                onChanged: (value) {
                  setState(() {
                    filterItemList();
                  });
                },
                onSubmitted: (value) {},
              ),
            ],
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        child: _loading
            ? Center(
                child: SpinKitRing(
                  color: primaryColor,
                  lineWidth: 5,
                  size: 40,
                ),
              )
            : itemList.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //// product list
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: itemList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  if (itemList[index].check == true) {
                                    for (ItemModel item
                                        in selectItemList.toList()) {
                                      if (item.id == itemList[index].id) {
                                        selectItemList.remove(item);
                                      }
                                    }
                                    itemList[index].check = false;
                                  } else {
                                    itemList[index].check = true;
                                    selectItemList.add(itemList[index]);
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  color: const Color(0xFFFFFFFF),
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: Checkbox(
                                            activeColor: primaryColor,
                                            checkColor: Colors.white,
                                            value: itemList[index].check,
                                            onChanged: (value) {
                                              if (itemList[index].check ==
                                                  true) {
                                                for (ItemModel item
                                                    in selectItemList
                                                        .toList()) {
                                                  if (item.id ==
                                                      itemList[index].id) {
                                                    selectItemList.remove(item);
                                                  }
                                                }
                                                itemList[index].check = false;
                                              } else {
                                                itemList[index].check = true;
                                                selectItemList
                                                    .add(itemList[index]);
                                              }
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                itemList[index]
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
                                                itemList[index]
                                                    .description
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      const Color(0xFF374151),
                                                ),
                                              ),
                                              Text(
                                                "Price : ${_provider.showPriceAsThousandSeparator(itemList[index].price!)}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              if (widget.delimanTranType !=
                                                  "SALE")
                                                Text(
                                                  "Retail Price : ${_provider.showPriceAsThousandSeparator(itemList[index].retailPrice!)}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              if (widget.delimanTranType ==
                                                  "SALE")
                                                Text(
                                                  "${maxQtys[index]} left",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (widget.itemWithQty)
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (itemList[index].qty !=
                                                        1) {
                                                      itemList[index].qty =
                                                          itemList[index].qty! -
                                                              1;
                                                      qtyCtrList[index].text =
                                                          itemList[index]
                                                              .qty
                                                              .toString();
                                                      if (selectItemList
                                                          .isNotEmpty) {
                                                        for (ItemModel selectItem
                                                            in selectItemList
                                                                .toList()) {
                                                          if (itemList[index]
                                                                  .id ==
                                                              selectItem.id) {
                                                            selectItem.qty =
                                                                itemList[index]
                                                                    .qty;
                                                          }
                                                        }
                                                      }
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    border: Border.all(
                                                      width: 1,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.remove,
                                                      color: Colors.black,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 30,
                                                width: 50,
                                                child: TextField(
                                                  controller: qtyCtrList[index],
                                                  onChanged: (value) {
                                                    if (value.isNotEmpty &&
                                                        value != "0") {
                                                      itemList[index].qty =
                                                          int.parse(value);
                                                      if (selectItemList
                                                          .isNotEmpty) {
                                                        for (ItemModel selectItem
                                                            in selectItemList
                                                                .toList()) {
                                                          if (itemList[index]
                                                                  .id ==
                                                              selectItem.id) {
                                                            selectItem.qty =
                                                                itemList[index]
                                                                    .qty;
                                                          }
                                                        }
                                                      }
                                                    } else {
                                                      itemList[index].qty = 1;
                                                    }
                                                    setState(() {});
                                                  },
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 2,
                                                          color: primaryColor),
                                                    ),
                                                  ),
                                                  // onTap: () {
                                                  //   qtyCtrList[index]
                                                  //           .selection =
                                                  //       TextSelection(
                                                  //           baseOffset: 0,
                                                  //           extentOffset:
                                                  //               qtyCtrList[
                                                  //                       index]
                                                  //                   .text
                                                  //                   .length);
                                                  // },
                                                  onTapOutside: (value) {
                                                    if (qtyCtrList[index]
                                                            .text
                                                            .isEmpty ||
                                                        qtyCtrList[index]
                                                                .text ==
                                                            "0") {
                                                      setState(() {
                                                        qtyCtrList[index].text =
                                                            "1";
                                                      });
                                                    }
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  onSubmitted: (value) {
                                                    if (value.isEmpty ||
                                                        value == "0") {
                                                      setState(() {
                                                        qtyCtrList[index].text =
                                                            "1";
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    itemList[index].qty =
                                                        itemList[index].qty! +
                                                            1;
                                                    qtyCtrList[index].text =
                                                        itemList[index]
                                                            .qty
                                                            .toString();
                                                    if (selectItemList
                                                        .isNotEmpty) {
                                                      for (ItemModel selectItem
                                                          in selectItemList
                                                              .toList()) {
                                                        if (itemList[index]
                                                                .id ==
                                                            selectItem.id) {
                                                          selectItem.qty =
                                                              itemList[index]
                                                                  .qty;
                                                        }
                                                      }
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    border: Border.all(
                                                      width: 1,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.add,
                                                      color: Colors.black,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      "no_data".tr(),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () {
            if (widget.delimanTranType == "SALE") {
              bool notEnough = false;
              for (var item in selectItemList) {
                for (int i = 0; i < itemList.length; i++) {
                  if (item.id == itemList[i].id) {
                    if (item.qty! > maxQtys[i]) {
                      notEnough = true;
                      showSnackBar("Not enough product quantity!", false);
                      break;
                    }
                  }
                }
              }
              if (!notEnough) {
                setState(() {
                  Navigator.pop(context, selectItemList);
                });
              }
            } else {
              setState(() {
                Navigator.pop(context, selectItemList);
              });
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                "confirm_txt".tr(),
                style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
