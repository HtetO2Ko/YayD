import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/models/customerbyroute_model.dart';
import 'package:yay_thant/models/retail_sale_model.dart';
import 'package:yay_thant/models/sale_response_model.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';

TextStyle titleStyle =
    TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.w600);
TextStyle labelStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
TextStyle totalAmtStyle =
    TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: primaryColor);
TextStyle textStyle1 = TextStyle(fontSize: 15);

class SaleDetailPage extends StatefulWidget {
  final SaleModel? saleData;
  const SaleDetailPage({
    super.key,
    this.saleData,
  });

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SaleModel saleData = widget.saleData!;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: customAppBar(
          title: "sale_detail",
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: SvgPicture.asset(
                    "assets/icons/check.svg",
                    width: 65,
                    height: 65,
                  ),
                ),
                DetailCardWidget(
                  customer: saleData.customer!,
                  delivererName: saleData.saleBy!.name!,
                  saleData: saleData,
                ),
                DeliveredProductListWidget(saleData: saleData),
                ReturnProductListWidget(
                  returnProducts: saleData.returnProducts!,
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailCardWidget extends StatelessWidget {
  final CustomerByRouteModel customer;
  final String delivererName;
  final SaleModel saleData;
  const DetailCardWidget({
    super.key,
    required this.customer,
    required this.delivererName,
    required this.saleData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "cust".tr(),
                  style: titleStyle,
                ),
                SizedBox(
                  height: 5,
                ),
                textWidget("${"name".tr()} :", true),
                SizedBox(
                  height: 5,
                ),
                if(customer.email != null)
                textWidget("${"email".tr()} :", true),
                if(customer.email != null)
                SizedBox(
                  height: 5,
                ),
                textWidget("${"ph".tr()} :", true),
                SizedBox(
                  height: 5,
                ),
                textWidget("${"address".tr()} :", true),
                SizedBox(
                  height: 10,
                ),
                textWidget("${"delivery_man".tr()} :", true),
                SizedBox(
                  height: 10,
                ),
                textWidget("${"remark".tr()} :", true),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 20,
                ),
                textWidget(customer.name!, false),
                SizedBox(
                  height: 5,
                ),
                if(customer.email != null)
                textWidget(customer.email!, false),
                if(customer.email != null)
                SizedBox(
                  height: 5,
                ),
                textWidget(customer.phone!, false),
                SizedBox(
                  height: 5,
                ),
                textWidget(customer.address!, false),
                SizedBox(
                  height: 10,
                ),
                textWidget(delivererName, false),
                SizedBox(
                  height: 10,
                ),
                if (saleData.remark != "")
                  textWidget(saleData.remark.toString(), false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget textWidget(String value, bool isLabel) {
    return Text(
      value,
      style: isLabel ? labelStyle : textStyle1,
    );
  }
}

class DeliveredProductListWidget extends StatelessWidget {
  final SaleModel saleData;
  const DeliveredProductListWidget({super.key, required this.saleData});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          Text(
            "delivered_product".tr(),
            style: titleStyle,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                "product".tr(),
                textAlign: TextAlign.start,
                style: labelStyle,
              )),
              Expanded(
                  child: Text(
                "qty".tr(),
                textAlign: TextAlign.center,
                style: labelStyle,
              )),
              Expanded(
                  child: Text(
                "price".tr(),
                textAlign: TextAlign.center,
                style: labelStyle,
              )),
              Expanded(
                  child: Text(
                "amount".tr(),
                textAlign: TextAlign.end,
                style: labelStyle,
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Divider(),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: saleData.products!.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      saleData.products![index].product!.title!,
                      textAlign: TextAlign.start,
                      style: textStyle1,
                    )),
                    Expanded(
                        child: Text(
                      saleData.products![index].qty.toString(),
                      textAlign: TextAlign.center,
                      style: textStyle1,
                    )),
                    Expanded(
                        child: Text(
                      saleData.products![index].product!.price.toString(),
                      textAlign: TextAlign.center,
                      style: textStyle1,
                    )),
                    Expanded(
                        child: Text(
                      saleData.products![index].amount.toString(),
                      textAlign: TextAlign.end,
                      style: textStyle1,
                    )),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${"total_amt".tr()}:",
                style: totalAmtStyle,
              ),
              Text(
                saleData.totalAmount.toString(),
                style: textStyle1,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${"recieve_amt".tr()}:",
                style: totalAmtStyle,
              ),
              Text(
                saleData.receiveAmount.toString(),
                style: textStyle1,
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

class ReturnProductListWidget extends StatelessWidget {
  final List<ProductElement> returnProducts;
  const ReturnProductListWidget({super.key, required this.returnProducts});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
            Text(
              "returned_product".tr(),
              style: titleStyle,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "product".tr(),
                    style: labelStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    "qty".tr(),
                    style: labelStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Divider(),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: returnProducts.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          returnProducts[index].product!.title!,
                          style: textStyle1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          returnProducts[index].qty.toString(),
                          style: textStyle1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
