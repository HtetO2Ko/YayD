import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/user_model.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_button.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class AddandEdituserPage extends StatefulWidget {
  final UserModel? userData;
  const AddandEdituserPage({super.key, this.userData});

  @override
  State<AddandEdituserPage> createState() => _AddandEdituserPageState();
}

class _AddandEdituserPageState extends State<AddandEdituserPage> {
  //
  EdgeInsets textfieldMargin =
      EdgeInsets.symmetric(horizontal: 15, vertical: 5);
  EdgeInsets labelMargin = EdgeInsets.only(left: 15, top: 5);
  bool _loading = false;
  // userdata
  UserModel? userData;
  TextEditingController userNameCtrl = TextEditingController();
  TextEditingController roleCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController phCtrl = TextEditingController();
  TextEditingController pswCtrl = TextEditingController();
  bool _obsecurePsw = true;
  int _selectedRoleID = -1;
  List userRoles = [
    {
      "role": -1,
      "name": "-",
    },
    {
      "role": 0,
      "name": "delivery_man",
    },
    {
      "role": 1,
      "name": "manager",
    },
  ];

  validateUserData() {
    bool isValid = false;
    print(">>>>>>>>> user data $userData");
    if (userNameCtrl.text == "") {
      showRequiredMsg("name");
    } else if (phCtrl.text == "") {
      showRequiredMsg("ph");
    } else if (emailCtrl.text == "") {
      showRequiredMsg("email");
    } else if (pswCtrl.text == "" && userData == null) {
      showRequiredMsg("psw");
    } else if (pswCtrl.text.length < 6 && userData == null) {
      showSnackBar("Password must be at least 6 characters!", false);
    } else if (_selectedRoleID == -1 && userData == null) {
      showChooseMsg("user_type", context);
    } else {
      isValid = true;
    }
    print(">>>>>>>>> isValid$isValid");
    setState(() {});
    return isValid;
  }

  Future<void> createUser() async {
    var param = jsonEncode({
      "name": userNameCtrl.text,
      "email": emailCtrl.text,
      "phone": phCtrl.text,
      "password": pswCtrl.text,
      "role": _selectedRoleID,
      "active": true,
      "avatar": ""
    });
    await API().createUser(param).then((result) {
      if (result) {
        // showSnackBar("User created successfully!", true);
        showCreateSuccessMsg("user");
        Navigator.pop(context, true);
      }
    });
    setState(() {
      _loading = false;
    });
  }

  Future<void> updateUserData() async {
    var param = jsonEncode({
      "name": userNameCtrl.text,
      "email": emailCtrl.text,
      "phone": phCtrl.text,
      "active": true,
      "avatar": ""
    });
    await API().updateUserData(param, userData!.id).then((result) {
      if (result) {
        showUpdateSuccessMsg("user");
        Navigator.pop(context, true);
      }
    });
    setState(() {
      _loading = false;
    });
  }

  Future<bool> deleteUser() async {
    bool isSuccess = await API().deleteUser(userData!.id);
    setState(() {
      Navigator.pop(context);
    });
    return isSuccess;
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
                          Functionprovider()
                              .checkInternetConnection()
                              .then((result) async {
                            if (result) {
                              showLoadingDialog(context);
                              final isSuccess = await deleteUser();
                              setState(() {});
                              if (isSuccess) {
                                showDeleteSuccessMsg("user");
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

  initData() {
    userData = widget.userData;
    print(currentUserData);
    if (currentUserData["role"].toString() == '1') {
      _selectedRoleID = 0;
    }
    print(_selectedRoleID);
    if (userData != null) {
      bindEditData();
    }
    setState(() {});
  }

  bindEditData() {
    userNameCtrl.text = userData!.name!;
    emailCtrl.text = userData!.email ?? "";
    phCtrl.text = userData!.phone ?? "";
    setState(() {});
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    userNameCtrl.dispose();
    roleCtrl.dispose();
    emailCtrl.dispose();
    phCtrl.dispose();
    pswCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: customAppBar(
          title: userData == null ? "create_user" : "update_user",
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
                controller: userNameCtrl,
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
              if (userData == null)
                CustomTextfieldWithLabel(
                  label: "psw",
                  controller: pswCtrl,
                  hintText: "",
                  prefixIcon: null,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obsecurePsw = !_obsecurePsw;
                      });
                    },
                    child: Icon(
                      _obsecurePsw ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                  ),
                  obscureText: _obsecurePsw,
                  onChanged: (value) {},
                  onSubmitted: (value) {},
                  margin: textfieldMargin,
                  labelMargin: labelMargin,
                ),
              if (userData == null)
                currentUserData["role"] == 1
                    ? Container()
                    : Padding(
                        padding: labelMargin,
                        child: Text(
                          "user_type".tr(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
              if (userData == null)
                currentUserData["role"] == 1
                    ? Container()
                    : Container(
                        height: 40,
                        margin: textfieldMargin,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          value: _selectedRoleID.toString(),
                          items: userRoles.map((role) {
                            print(">>> role $role");
                            return DropdownMenuItem<String>(
                              value: role["role"].toString(),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(role["name"].toString().tr()),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRoleID = int.parse(newValue!);
                            });
                          },
                          underline: SizedBox.shrink(),
                          icon: Icon(Icons.arrow_drop_down),
                        ),
                      ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
          child: userData == null
              ? CustomButton(
                  buttonText: "save".tr(),
                  isLoading: _loading,
                  onTap: () async {
                    Functionprovider()
                        .checkInternetConnection()
                        .then((result) async {
                      if (result) {
                        final isValid = validateUserData();
                        if (isValid) {
                          _loading = true;
                          setState(() {});
                          if (userData != null) {
                            await updateUserData();
                          } else {
                            await createUser();
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
                        buttonText: "save".tr(),
                        isLoading: _loading,
                        onTap: () async {
                          Functionprovider()
                              .checkInternetConnection()
                              .then((result) async {
                            if (result) {
                              final isValid = validateUserData();
                              if (isValid) {
                                _loading = true;
                                setState(() {});
                                if (userData != null) {
                                  await updateUserData();
                                } else {
                                  await createUser();
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
      ),
    );
  }
}
