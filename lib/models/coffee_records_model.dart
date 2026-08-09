import 'dart:convert';

CoffeeRecordsModel coffeeRecordsModelFromJson(String str) =>
    CoffeeRecordsModel.fromJson(json.decode(str));

String coffeeRecordsModelToJson(CoffeeRecordsModel data) =>
    json.encode(data.toJson());

class CoffeeRecordsModel {
  String? id;
  String name;
  double price;
  String size;
  String sugarLevel;
  DateTime createdAt;

  CoffeeRecordsModel({
    this.id,
    required this.name,
    required this.price,
    required this.size,
    required this.sugarLevel,
    required this.createdAt,
  });

  factory CoffeeRecordsModel.fromJson(Map<String, dynamic> json, {String? docId}) =>
      CoffeeRecordsModel(
        id: docId ?? json["id"],
        name: json["name"] ?? '',
        price: (json["price"] as num?)?.toDouble() ?? 0.0,
        size: json["size"] ?? 'Medium',
        sugarLevel: json["sugarLevel"] ?? 'Regular',
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "size": size,
        "sugarLevel": sugarLevel,
        "createdAt": createdAt.toIso8601String(),
      };
}