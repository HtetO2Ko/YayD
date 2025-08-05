import 'dart:convert';

class SummarySaleCountModel {
  final String? date;
  final int? saleCount;

  SummarySaleCountModel({
    this.date,
    this.saleCount,
  });

  SummarySaleCountModel clone() {
    return SummarySaleCountModel(
      date: this.date,
      saleCount: this.saleCount,
    );
  }

  factory SummarySaleCountModel.fromRawJson(String str) =>
      SummarySaleCountModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SummarySaleCountModel.fromJson(Map<String, dynamic> json) => SummarySaleCountModel(
        date: json["date"],
        saleCount: json["saleCount"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "saleCount": saleCount,
      };
}
