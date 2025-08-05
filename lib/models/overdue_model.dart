import 'dart:convert';

import 'package:yay_thant/models/customer_model.dart';
import 'package:yay_thant/models/retail_sale_model.dart';
import 'package:yay_thant/models/user_model.dart';

class OverDueModel {
  int? receiveAmount;
  String? id;
  CustomerModel? customer;
  UserModel? saleBy;
  List<ProductElement>? products;
  int? totalAmount;
  int? balanceDue;
  List<ProductElement>? returnProducts;
  int? totalReturnQty;
  String? remark;
  String? t1;
  String? t2;
  String? t3;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  OverDueModel({
    this.receiveAmount,
    this.id,
    this.customer,
    this.saleBy,
    this.products,
    this.totalAmount,
    this.balanceDue,
    this.returnProducts,
    this.totalReturnQty,
    this.remark,
    this.t1,
    this.t2,
    this.t3,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory OverDueModel.fromRawJson(String str) =>
      OverDueModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OverDueModel.fromJson(Map<String, dynamic> json) => OverDueModel(
        receiveAmount: json["receiveAmount"],
        id: json["_id"],
        customer: json["customer"] == null
            ? null
            : CustomerModel.fromJson(json["customer"]),
        saleBy:
            json["saleBy"] == null ? null : UserModel.fromJson(json["saleBy"]),
        products: json["products"] == null
            ? []
            : List<ProductElement>.from(
                json["products"]!.map((x) => ProductElement.fromJson(x))),
        totalAmount: json["totalAmount"],
        balanceDue: json["balanceDue"],
        returnProducts: json["returnProducts"] == null
            ? []
            : List<ProductElement>.from(
                json["returnProducts"]!.map((x) => ProductElement.fromJson(x))),
        totalReturnQty: json["totalReturnQty"],
        remark: json["remark"],
        t1: json["t1"],
        t2: json["t2"],
        t3: json["t3"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "receiveAmount": receiveAmount,
        "_id": id,
        "customer": customer?.toJson(),
        "saleBy": saleBy?.toJson(),
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "totalAmount": totalAmount,
        "balanceDue": balanceDue,
        "returnProducts": returnProducts == null
            ? []
            : List<dynamic>.from(returnProducts!.map((x) => x.toJson())),
        "totalReturnQty": totalReturnQty,
        "remark": remark,
        "t1": t1,
        "t2": t2,
        "t3": t3,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}