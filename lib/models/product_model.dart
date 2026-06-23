import 'dart:convert';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? image;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory ProductModel.fromJsonString(String source) =>
      ProductModel.fromJson(json.decode(source));

  @override
  String toString() {
    return 'ProductModel{id: $id, name: $name, description: $description, price: $price}';
  }
}
