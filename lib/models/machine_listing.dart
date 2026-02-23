import 'package:cloud_firestore/cloud_firestore.dart';

class MachineListing {
  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final String titleLowercase;
  final String description;
  final String category;
  final double price;
  final String condition;
  final String location;
  final String brand;
  final String model;
  final int? year;
  final int? hours;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MachineListing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.title,
    String? titleLowercase,
    required this.description,
    required this.category,
    required this.price,
    required this.condition,
    required this.location,
    this.brand = '',
    this.model = '',
    this.year,
    this.hours,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  }) : titleLowercase = titleLowercase ?? '';

  factory MachineListing.fromJson(Map<String, dynamic> json, {String? id}) {
    return MachineListing(
      id: id ?? json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      title: json['title'] ?? '',
      titleLowercase: json['titleLowercase'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
      location: json['location'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] as int?,
      hours: json['hours'] as int?,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'title': title,
      'titleLowercase': title.toLowerCase(),
      'description': description,
      'category': category,
      'price': price,
      'condition': condition,
      'location': location,
      'brand': brand,
      'model': model,
      'year': year,
      'hours': hours,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MachineListing copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? title,
    String? description,
    String? category,
    double? price,
    String? condition,
    String? location,
    String? brand,
    String? model,
    int? year,
    int? hours,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearYear = false,
    bool clearHours = false,
  }) {
    return MachineListing(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      title: title ?? this.title,
      titleLowercase: (title ?? this.title).toLowerCase(),
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: clearYear ? null : (year ?? this.year),
      hours: clearHours ? null : (hours ?? this.hours),
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
