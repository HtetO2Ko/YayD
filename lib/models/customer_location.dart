import 'dart:convert';

import 'package:yay_thant/models/customer_model.dart';

class CustomerLocation {
  Location? location;
  String? id;
  String? name;
  String? phone;
  String? email;
  String? address;
  int? status;
  CustomerLocation({
    this.location,
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.status,
  });

  factory CustomerLocation.fromRawJson(String str) =>
      CustomerLocation.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CustomerLocation.fromJson(Map<String, dynamic> json) =>
      CustomerLocation(
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        id: json["_id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "_id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "status": status,
      };
}
