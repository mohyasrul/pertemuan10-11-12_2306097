import 'dart:convert';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'price': price};
  }

  String toJsonString() => json.encode(toJson());

  factory ProductModel.fromJsonString(String source) =>
      ProductModel.fromJson(json.decode(source));

  @override
  String toString() {
    return 'ProductModel{id: $id, name: $name, description: $description, price: $price}';
  }
}
