import 'dart:convert';

import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/models/user_model.dart';

class RetailSaleModel {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? address;
  List<ProductElement>? products;
  int? totalAmount;
  UserModel? saleBy;
  String? t1;
  String? t2;
  String? t3;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  RetailSaleModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.products,
    this.totalAmount,
    this.saleBy,
    this.t1,
    this.t2,
    this.t3,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  RetailSaleModel clone() {
    return RetailSaleModel(
      id: id,
      name: name,
      phone: phone,
      email: email,
      address: address,
      products: products,
      totalAmount: totalAmount,
      saleBy: saleBy,
      t1: t1,
      t2: t2,
      t3: t3,
      createdAt: createdAt,
      updatedAt: updatedAt,
      v: v,
    );
  }

  factory RetailSaleModel.fromRawJson(String str) =>
      RetailSaleModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RetailSaleModel.fromJson(Map<String, dynamic> json) =>
      RetailSaleModel(
        id: json["_id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
        products: json["products"] == null
            ? []
            : List<ProductElement>.from(
                json["products"]!.map((x) => ProductElement.fromJson(x))),
        totalAmount: json["totalAmount"],
        saleBy:
            json["saleBy"] == null ? null : UserModel.fromJson(json["saleBy"]),
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
        "_id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "totalAmount": totalAmount,
        "saleBy": saleBy?.toJson(),
        "t1": t1,
        "t2": t2,
        "t3": t3,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class ProductElement {
  ItemModel? product;
  int? qty;
  int? amount;
  String? id;
  int? soldQty;

  ProductElement({
    this.product,
    this.qty,
    this.amount,
    this.id,
    this.soldQty
  });

  factory ProductElement.fromRawJson(String str) =>
      ProductElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductElement.fromJson(Map<String, dynamic> json) => ProductElement(
        product: json["product"] == null
            ? null
            : ItemModel.fromJson(json["product"]),
        qty: json["qty"],
        amount: json["amount"],
        id: json["_id"],
        soldQty: json["soldQty"],
      );

  Map<String, dynamic> toJson() => {
        "product": product?.toJson(),
        "qty": qty,
        "amount": amount,
        "_id": id,
        "soldQty": soldQty,
      };
}
