import 'dart:convert';
import 'package:yay_thant/models/item_model.dart';
import 'package:yay_thant/models/route_model.dart';

class CustomerModel {
  Location? location;
  String? id;
  RouteModel? route;
  String? name;
  String? phone;
  String? email;
  String? address;
  String? t1;
  String? t2;
  String? t3;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<ItemModel>? products;
  bool? active;
  int? status;

  CustomerModel({
    this.location,
    this.id,
    this.route,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.t1,
    this.t2,
    this.t3,
    this.v,
    this.createdAt,
    this.updatedAt,
    this.products,
    this.active,
    this.status,
  });

  factory CustomerModel.fromRawJson(String str) =>
      CustomerModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        id: json["_id"],
        route:
            json["route"] == null ? null : RouteModel.fromJson(json["route"]),
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
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
        products: json["products"] == null
            ? []
            : List<ItemModel>.from(
                json["products"]!.map((x) => ItemModel.fromJson(x))),
        active: json["active"],
        status: json["status"]
      );

  Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "_id": id,
        "route": route?.toJson(),
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "t1": t1,
        "t2": t2,
        "t3": t3,
        "__v": v,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "active": active,
        "status": status,
      };
}

class Location {
  String lat;
  String lon;

  Location({
    this.lat = "",
    this.lon = "",
  });

  factory Location.fromRawJson(String str) =>
      Location.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: json["lat"] ?? "",
        lon: json["lon"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lon": lon,
      };
}
