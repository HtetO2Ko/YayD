import 'dart:convert';

import 'package:yay_thant/models/customer_model.dart';
import 'package:yay_thant/models/route_model.dart';

class CustomerByRouteModel {
  Location? location;
  String? id;
  RouteModel? route;
  String? name;
  String? phone;
  String? email;
  String? address;
  int? status;
  String? t1;
  String? t2;
  String? t3;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;

  CustomerByRouteModel({
    this.location,
    this.id,
    this.route,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.status,
    this.t1,
    this.t2,
    this.t3,
    this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerByRouteModel.fromRawJson(String str) =>
      CustomerByRouteModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CustomerByRouteModel.fromJson(Map<String, dynamic> json) =>
      CustomerByRouteModel(
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        id: json["_id"],
        route: json["route"] == null ? null : RouteModel.fromJson(json["route"]),
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
        status: json["status"],
        t1: json["t1"],
        t2: json["t2"],
        t3: json["t3"],
        v: json["__v"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "_id": id,
        "route": route?.toJson(),
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "status": status,
        "t1": t1,
        "t2": t2,
        "t3": t3,
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}