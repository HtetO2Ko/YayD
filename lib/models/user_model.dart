import 'dart:convert';

class UserModel {
  bool? active;
  String? id;
  String? name;
  String? email;
  String? phone;
  int? role;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? avatar;

  UserModel({
    this.active,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.avatar,
  });

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        active: json["active"],
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        role: json["role"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        avatar: json["avatar"],
      );

  Map<String, dynamic> toJson() => {
        "active": active,
        "_id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "avatar": avatar,
      };
}
