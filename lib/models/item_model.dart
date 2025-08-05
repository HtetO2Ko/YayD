import 'dart:convert';

class ItemModel {
  final String? id;
  final String? title;
  final String? description;
  final int? price;
  final int? retailPrice;
  final bool? deliverable;
  final bool? collectable;
  final List<String>? images;
  final String? t1;
  final String? t2;
  final String? t3;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  late bool? check;
  late int? qty;

  ItemModel({
    this.id,
    this.title,
    this.description,
    this.price,
    this.retailPrice,
    this.deliverable,
    this.collectable,
    this.images,
    this.t1,
    this.t2,
    this.t3,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.check,
    this.qty,
  });

  ItemModel clone() {
    return ItemModel(
      id: this.id,
      title: this.title,
      description: this.description,
      price: this.price,
      retailPrice: this.retailPrice,
      deliverable: this.deliverable,
      collectable: this.collectable,
      images: this.images,
      t1: this.t1,
      t2: this.t2,
      t3: this.t3,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      v: this.v,
      check: this.check,
      qty: this.qty,
    );
  }

  factory ItemModel.fromRawJson(String str) =>
      ItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        id: json["_id"],
        title: json["title"],
        description: json["description"],
        price: json["price"],
        retailPrice: json["retailPrice"],
        deliverable: json["deliverable"],
        collectable: json["collectable"],
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
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
        check: json['check'] ?? false,
        qty: json['qty'] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "price": price,
        "retailPrice": retailPrice,
        "deliverable": deliverable,
        "collectable": collectable,
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "t1": t1,
        "t2": t2,
        "t3": t3,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "check": check,
        "qty": qty,
      };
}
