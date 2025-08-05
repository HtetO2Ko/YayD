import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/enum/app_enum.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/models/customer_model.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';

class DeletedCustomerListPage extends StatefulWidget {
  const DeletedCustomerListPage({super.key});

  @override
  State<DeletedCustomerListPage> createState() =>
      _DeletedCustomerListPageState();
}

class _DeletedCustomerListPageState extends State<DeletedCustomerListPage> {
  bool isFilterOpen = true;
  bool _loading = false;
  FilterDateEnum dateFilterValue = FilterDateEnum.today;
  String dateFilterValueText = FilterDateEnum.today.name;
  List<CustomerModel> customerList = [];

  // apis
  getAllCustomers() async {
    setState(() {
      _loading = true;
    });
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllCustomers(2).then((customers) {
          customerList = List.from(customers);
        });
      }
    });
    setState(() {
      _loading = false;
    });
  }

  Future<bool> deactivateCustomer(id) async {
    bool isSuccess = await API().deleteCustomer(id);
    return isSuccess;
  }

  Future<bool> activateCustomer(CustomerModel customer) async {
    bool isSuccess = await API().changeCustomerStatus(customer.id ?? "", 1);

    return isSuccess;
  }

  //
  showDeleteDialog(id) {
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
                              setState(() {
                                _loading = true;
                              });
                              showLoadingDialog(context);
                              final isSuccess = await deactivateCustomer(id);
                              if (isSuccess) {
                                showDeleteSuccessMsg("cust");
                                getAllCustomers();
                                Navigator.pop(context, isSuccess);
                                Navigator.pop(context);
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

  showActivateDialog(CustomerModel customer) {
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
                    "Are you sure you want to reactivate ${customer.name}?"
                        .tr(),
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
                              setState(() {
                                _loading = true;
                              });
                              showLoadingDialog(context);
                              final isSuccess =
                                  await activateCustomer(customer);
                              // setState(() {});
                              if (isSuccess) {
                                showUpdateSuccessMsg("cust");
                                getAllCustomers();
                                Navigator.pop(context, isSuccess);
                                Navigator.pop(context);
                              }
                            }
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: primaryColor,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "activate".tr(),
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
    getAllCustomers();
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
          title: "deleted_customer_list",
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
          child: _loading
              ? Center(
                  child: SpinKitRing(
                    color: primaryColor,
                    lineWidth: 5,
                    size: 40,
                  ),
                )
              : customerList.isEmpty
                  ? Center(
                      child: Text(
                        "no_data".tr(),
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //// tran list
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: customerList.length,
                              itemBuilder: (context, index) {
                                return Slidable(
                                  key: ValueKey(index),
                                  endActionPane: ActionPane(
                                    motion: DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) async {
                                          showActivateDialog(
                                              customerList[index]);
                                        },
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        icon: Icons.check_circle,
                                        label: 'activate'.tr(),
                                      ),
                                      SlidableAction(
                                        onPressed: (context) {
                                          showDeleteDialog(
                                              customerList[index].id);
                                        },
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'delete'.tr(),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        color: const Color(0xFFFFFFFF),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 8, 16, 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                customerList[index].name!,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                "Phone Number: ${customerList[index].phone}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      const Color(0xFF374151),
                                                ),
                                              ),
                                              Text(
                                                "Address: ${customerList[index].address}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      const Color(0xFF374151),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 1,
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ],
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
                    ),
        ));
  }
}
