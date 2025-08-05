import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/enum/app_enum.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/models/customer_model.dart';
import 'package:yay_thant/pages/home/service/customers/add_and_edit_customer_page.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class CustomerListPage extends StatefulWidget {
  final String fromPage;
  const CustomerListPage({
    super.key,
    this.fromPage = "",
  });

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  bool isFilterOpen = true;
  bool _loading = false;
  // final _provider = Functionprovider();
  // filter date
  final TextEditingController _searchController = TextEditingController();
  FilterDateEnum dateFilterValue = FilterDateEnum.today;
  String dateFilterValueText = FilterDateEnum.today.name;
  List<CustomerModel> allCustomerList = [];
  List<CustomerModel> customerList = [];
  //
  String fromPage = "";

  getAllCustomers() async {
    setState(() {
      _loading = true;
    });
    var loc;
    if (fromPage == "same") {
      loc = true;
    } else if (fromPage == "without") {
      loc = 'none';
    } else {
      loc = null;
    }
    print(">>>> cust loc $loc");

    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllCustomers(1, sameLocation: loc).then((customers) {
          print(">>>> cust $customers");
          response(customers);
        });
      }
    });
    setState(() {
      _loading = false;
      filterItemList();
    });
  }

  response(customers) {
    allCustomerList = List.from(customers);
    customerList = List.from(customers);
  }

  void filterItemList() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      customerList = allCustomerList
          .where((customer) => customer.name!.toLowerCase().contains(query))
          .toList();
    });
  }

  initData() {
    fromPage = widget.fromPage;
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
          title: "customer_list",
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                return GestureDetector(
                                  onTap: () async {
                                    bool? result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddandEditCustPage(
                                                  customerData:
                                                      customerList[index],
                                                  isUpdate: true,
                                                )));
                                    if (result != null && result) {
                                      setState(() {
                                        getAllCustomers();
                                      });
                                    }
                                  },
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
