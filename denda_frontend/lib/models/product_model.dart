class CategoryModel {
  final int id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['Id'] ?? 0,
      name: json['name'] ?? json['Name'] ?? '',
    );
  }
}
class ProductModel {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;
  final int categoryId;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
  return ProductModel(
    id: json['id'] ?? json['Id'] ?? 0,
    name: json['name'] ?? json['Name'] ?? '',
    price: (json['basePrice'] ?? json['BasePrice'] ?? json['price'] ?? json['Price'] ?? 0).toDouble(),
    imageUrl: json['imageUrl'] ?? json['ImageUrl'],
    categoryId: json['categoryId'] ?? json['CategoryId'] ?? 0,
  );
}
}
class OptionModel {
  final int id;
  final String name;
  final String type; 
  final double price;

  OptionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
  return OptionModel(
    id: json['id'] ?? json['Id'] ?? 0,
    name: json['name'] ?? json['Name'] ?? '',
    type: json['type'] ?? json['Type'] ?? '',
    price: (json['additionalPrice'] ?? json['AdditionalPrice'] ?? json['price'] ?? json['Price'] ?? 0).toDouble(),
  );
}
}