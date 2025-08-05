import 'dart:convert';

class DeviceInfoModel {
  String? deviceId;
  String? model;
  String? appVersion;
  String? os;
  String? osVersion;

  DeviceInfoModel({
    this.deviceId,
    this.model,
    this.appVersion,
    this.os,
    this.osVersion,
  });

  factory DeviceInfoModel.fromRawJson(String str) =>
      DeviceInfoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) =>
      DeviceInfoModel(
        deviceId: json["deviceId"], 
        model: json["model"],
        appVersion: json["appVersion"],
        os: json["os"],
        osVersion: json["osVersion"]
      );

  Map<String, dynamic> toJson() => {
    "deviceId": deviceId ?? "",
    "model": model ?? "",
    "appVersion": appVersion ?? "",
    "os": os ?? "",
    "osVersion": osVersion ?? ""
  };
}
