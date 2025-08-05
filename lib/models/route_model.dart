import 'dart:convert';

class RouteModel {
    String? id;
    String? title;
    String? description;
    String? t1;
    String? t2;
    String? t3;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    RouteModel({
        this.id,
        this.title,
        this.description,
        this.t1,
        this.t2,
        this.t3,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory RouteModel.fromRawJson(String str) => RouteModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json["_id"],
        title: json["title"],
        description: json["description"],
        t1: json["t1"],
        t2: json["t2"],
        t3: json["t3"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "t1": t1,
        "t2": t2,
        "t3": t3,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}
