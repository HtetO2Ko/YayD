import 'dart:convert';
import 'package:yay_thant/models/retail_sale_model.dart';
import 'package:yay_thant/models/route_model.dart';
import 'package:yay_thant/models/user_model.dart';

class TranModel {
  String? id;
  List<ProductElement>? products;
  int? totalQty;
  int? totalAmount;
  UserModel? deliveryMan;
  RouteModel? route;
  String? description;
  String? remark;
  bool? status;
  String? t1;
  String? t2;
  String? t3;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  TranModel({
    this.id,
    this.products,
    this.totalQty,
    this.totalAmount,
    this.deliveryMan,
    this.route,
    this.description,
    this.remark,
    this.status,
    this.t1,
    this.t2,
    this.t3,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  TranModel clone() {
    return TranModel(
      id: this.id,
      products: this.products,
      totalQty: this.totalQty,
      totalAmount: this.totalAmount,
      deliveryMan: this.deliveryMan,
      route: this.route,
      description: this.description,
      remark: this.remark,
      status: this.status,
      t1: this.t1,
      t2: this.t2,
      t3: this.t3,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      v: this.v,
    );
  }

  factory TranModel.fromRawJson(String str) =>
      TranModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TranModel.fromJson(Map<String, dynamic> json) => TranModel(
        id: json["_id"],
        products: json["products"] == null
            ? []
            : List<ProductElement>.from(
                json["products"]!.map((x) => ProductElement.fromJson(x))),
        totalQty: json["totalQty"],
        totalAmount: json["totalAmount"],
        deliveryMan: json["deliveryMan"] == null
            ? null
            : UserModel.fromJson(json["deliveryMan"]),
        route:
            json["route"] == null ? null : RouteModel.fromJson(json["route"]),
        description: json["description"],
        remark: json["remark"],
        status: json["status"],
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
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "totalQty": totalQty,
        "totalAmount": totalAmount,
        "deliveryMan": deliveryMan?.toJson(),
        "route": route?.toJson(),
        "description": description,
        "remark": remark,
        "status": status,
        "t1": t1,
        "t2": t2,
        "t3": t3,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
