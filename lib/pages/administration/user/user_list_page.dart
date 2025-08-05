import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/models/user_model.dart';
import 'package:yay_thant/pages/administration/user/add_and_edit_user_page.dart';
import 'package:yay_thant/widgets/custom_avater.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  bool _loading = false;
  List<UserModel> adminList = [];
  List<UserModel> managerList = [];
  List<UserModel> deliverymanList = [];

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() {
    getUserList();
    setState(() {});
  }

  Future<void> getUserList() async {
    setState(() {
      _loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        adminList = [];
        managerList = [];
        deliverymanList = [];
        await API().getAllUser().then((users) {
          if (users.isNotEmpty) {
            for (var i = 0; i < users.length; i++) {
              if (currentUserData["role"] == 1) {
                switch (users[i].role) {
                  case 0:
                    deliverymanList.add(users[i]);
                    break;
                }
              } else if (currentUserData["role"] == 2) {
                switch (users[i].role) {
                  case 0:
                    deliverymanList.add(users[i]);
                    break;
                  case 1:
                    managerList.add(users[i]);
                    break;
                }
              }
            }
          }
        });
      }
    });
    setState(() {
      _loading = false;
    });
  }

  Widget showUserListByRole(
      {required String role, required List<UserModel> users}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 5, left: 10),
          child: Text(
            role.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: primaryColor,
            ),
          ),
        ),
        ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                final isSuccess = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddandEdituserPage(
                      userData: users[index],
                    ),
                  ),
                );
                setState(() {
                  if (isSuccess) {
                    getUserList();
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                height: 50,
                decoration: BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomAvater(
                      imageURL: users[index].avatar,
                      name: users[index].name!,
                      radius: 35,
                      fontSize: 14,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          users[index].name!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          users[index].phone ?? users[index].email ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: customAppBar(
          title: "users",
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
            : adminList.isNotEmpty ||
                    managerList.isNotEmpty ||
                    deliverymanList.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        adminList.isEmpty
                            ? Container()
                            : showUserListByRole(
                                role: "admin",
                                users: adminList,
                              ),
                        managerList.isEmpty
                            ? Container()
                            : showUserListByRole(
                                role: "manager",
                                users: managerList,
                              ),
                        deliverymanList.isEmpty
                            ? Container()
                            : showUserListByRole(
                                role: "delivery_man",
                                users: deliverymanList,
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
        floatingActionButton: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50), color: primaryColor),
          child: GestureDetector(
            onTap: () async {
              final isSuccess = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddandEdituserPage(),
                ),
              );
              setState(() {
                if (isSuccess) {
                  getUserList();
                }
              });
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
