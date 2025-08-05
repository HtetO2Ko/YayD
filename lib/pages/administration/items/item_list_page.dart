import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/config/dataconfig.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/pages/administration/items/add_and_edit_item_page.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final _dataConfig = Dataconfig();
  final _provider = Functionprovider();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> userData = {};
  List<ItemModel> allItemList = [];
  List<ItemModel> itemList = [];
  bool _loading = false;

  initData() {
    userData = _dataConfig.getCurrentUserData();
    setState(() {
      _loading = true;
      getItemList();
    });
  }

  Future<void> getItemList() async {
    await Functionprovider().checkInternetConnection().then((result) async {
      if (result) {
        await API().getAllItem().then((items) {
          allItemList = items;
          itemList = items;
        });
      }
    });
    setState(() {
      _loading = false;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "stock_type",
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
            : itemList.isEmpty
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
                        //// product list
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: itemList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  final isSuccess = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddandEditItemPage(
                                        editItemData: itemList[index],
                                      ),
                                    ),
                                  );
                                  if (isSuccess != null && isSuccess) {
                                    setState(() {
                                      _loading = true;
                                    });
                                    getItemList();
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      color: const Color(0xFFFFFFFF),
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 8, 16, 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              itemList[index].title.toString(),
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
                                                color: const Color(0xFF374151),
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
                                            Text(
                                              "Retail Price : ${_provider.showPriceAsThousandSeparator(itemList[index].retailPrice!)}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
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
      ),
      floatingActionButton: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: primaryColor),
        child: GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddandEditItemPage(),
              ),
            );
            setState(() {
              if (result == true) {
                getItemList();
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
    );
  }
}
