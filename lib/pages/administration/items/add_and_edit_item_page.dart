import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_button.dart';
import 'package:yay_thant/widgets/custom_switch.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class AddandEditItemPage extends StatefulWidget {
  final ItemModel? editItemData;
  const AddandEditItemPage({
    super.key,
    this.editItemData,
  });

  @override
  State<AddandEditItemPage> createState() => _AddandEditItemPageState();
}

class _AddandEditItemPageState extends State<AddandEditItemPage> {
  ////
  final EdgeInsets textfieldMargin =
      EdgeInsets.symmetric(horizontal: 15, vertical: 5);
  final EdgeInsets labelMargin = EdgeInsets.only(left: 15, top: 5, right: 15);
  ////
  bool isLoading = false;
  ItemModel? editItemData;
  // data
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _retailPriceController = TextEditingController();
  bool deliverable = false;
  bool collectable = false;

  // apis
  bool validateItemData() {
    bool isValid = false;
    if (_titleController.text == "") {
      showRequiredMsg("stock_type");
    } else if (_descController.text == "") {
      showRequiredMsg("desc");
    } else if (_priceController.text == "") {
      showRequiredMsg("price");
    } else if (_retailPriceController.text == "") {
      showRequiredMsg("retail_price");
    } else {
      isValid = true;
    }
    return isValid;
  }

  Future<void> createItem() async {
    var param = jsonEncode({
      "title": _titleController.text,
      "description": _descController.text,
      "price": int.parse(_priceController.text),
      "images": [],
      "retailPrice": int.parse(_retailPriceController.text),
      "deliverable": deliverable,
      "collectable": collectable,
      "t1": "",
      "t2": "",
      "t3": ""
    });
    await API().createItem(param).then((result) {
      if (result) {
        showCreateSuccessMsg("stock_type");
        Navigator.pop(context, true);
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateItem() async {
    var param = jsonEncode({
      "title": _titleController.text,
      "description": _descController.text,
      "price": int.parse(_priceController.text),
      "images": [],
      "retailPrice": int.parse(_retailPriceController.text),
      "deliverable": deliverable,
      "collectable": collectable,
      "t1": "",
      "t2": "",
      "t3": ""
    });
    await API().updateItem(param, editItemData!.id).then((result) {
      if (result) {
        showUpdateSuccessMsg("stock_type");
        Navigator.pop(context, true);
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> deleteItem() async {
    bool isSuccess = await API().deleteItem(editItemData!.id);
    setState(() {
      Navigator.pop(context);
    });
    return isSuccess;
  }

  //

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
                              final isSuccess = await deleteItem();
                              setState(() {});
                              if (isSuccess) {
                                showDeleteSuccessMsg("stock_type");
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

  bindEditData() {
    editItemData = widget.editItemData;
    setState(() {
      if (editItemData != null) {
        _titleController.text = editItemData!.title.toString();
        _descController.text = editItemData!.description.toString();
        _priceController.text = editItemData!.price.toString();
        _retailPriceController.text = editItemData!.retailPrice.toString();
        deliverable = editItemData!.deliverable ?? false;
        collectable = editItemData!.collectable ?? false;
      }
    });
  }

  initData() {
    bindEditData();
    setState(() {});
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: editItemData == null ? "create_stock" : "update_stock",
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
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextfieldWithLabel(
                  label: "stock_type",
                  controller: _titleController,
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
                  label: "desc",
                  controller: _descController,
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
                  label: "price",
                  controller: _priceController,
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
                CustomTextfieldWithLabel(
                  label: "retail_price",
                  controller: _retailPriceController,
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
                CustomSwitch(
                  switchValue: deliverable,
                  labelText: "deliverable",
                  onChanged: (bool? value) {
                    setState(() {
                      deliverable = value ?? false;
                    });
                  },
                ),
                CustomSwitch(
                  switchValue: collectable,
                  labelText: "collectable",
                  onChanged: (bool? value) {
                    setState(() {
                      collectable = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
        child: editItemData == null
            ? CustomButton(
                buttonText: "save",
                isLoading: isLoading,
                onTap: () async {
                  await Functionprovider()
                      .checkInternetConnection()
                      .then((result) async {
                    if (result) {
                      final isValid = validateItemData();
                      if (isValid) {
                        isLoading = true;
                        setState(() {});
                        if (editItemData != null) {
                          await updateItem();
                        } else {
                          await createItem();
                        }
                      }
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
                      onTap: () async {
                        await Functionprovider()
                            .checkInternetConnection()
                            .then((result) async {
                          if (result) {
                            final isValid = validateItemData();
                            if (isValid) {
                              isLoading = true;
                              setState(() {});
                              if (editItemData != null) {
                                await updateItem();
                              } else {
                                await createItem();
                              }
                            }
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
