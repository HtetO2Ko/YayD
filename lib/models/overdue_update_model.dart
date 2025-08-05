import 'dart:convert';

class OverDueUpdateModel {
  int? receiveAmount;
  String? id;
  String? customer;
  String? saleBy;
  List<OverDueProductModel>? products;
  int? totalAmount;
  int? balanceDue;
  List<OverDueProductModel>? returnProducts;
  int? totalReturnQty;
  String? remark;
  String? t1;
  String? t2;
  String? t3;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  OverDueUpdateModel({
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

  factory OverDueUpdateModel.fromRawJson(String str) =>
      OverDueUpdateModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OverDueUpdateModel.fromJson(Map<String, dynamic> json) =>
      OverDueUpdateModel(
        receiveAmount: json["receiveAmount"],
        id: json["_id"],
        customer: json["customer"],
        saleBy: json["saleBy"],
        products: json["products"] == null
            ? []
            : List<OverDueProductModel>.from(
                json["products"]!.map((x) => OverDueProductModel.fromJson(x))),
        totalAmount: json["totalAmount"],
        balanceDue: json["balanceDue"],
        returnProducts: json["returnProducts"] == null
            ? []
            : List<OverDueProductModel>.from(json["returnProducts"]!
                .map((x) => OverDueProductModel.fromJson(x))),
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
        "customer": customer,
        "saleBy": saleBy,
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

class OverDueProductModel {
  String? product;
  int? qty;
  int? amount;
  String? id;

  OverDueProductModel({this.product, this.qty, this.amount, this.id});

  factory OverDueProductModel.fromRawJson(String str) =>
      OverDueProductModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OverDueProductModel.fromJson(Map<String, dynamic> json) =>
      OverDueProductModel(
        product: json["product"],
        qty: json["qty"],
        amount: json["amount"] ?? 0,
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "product": product,
        "qty": qty,
        "amount": amount,
        "_id": id,
      };
}
