import 'package:equatable/equatable.dart';

// Represents a category in the menu
class FoodCategory extends Equatable {
  final String categoryName;
  final String categoryImage;
  final String categoryId;
  final String? categoryDescription;

  FoodCategory({
    required this.categoryName,
    required this.categoryImage,
    required this.categoryId,
    this.categoryDescription,
  });

  FoodCategory copyWith({
    String? categoryName,
    String? categoryImage,
    String? categoryId,
    String? categoryDescription,
  }) {
    return FoodCategory(
      categoryName: categoryName ?? this.categoryName,
      categoryImage: categoryImage ?? this.categoryImage,
      categoryId: categoryId ?? this.categoryId,
      categoryDescription: categoryDescription ?? this.categoryDescription,
    );
  }

  @override
  List<Object?> get props =>
      [categoryName, categoryImage, categoryId, categoryDescription];

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'categoryImage': categoryImage,
      'categoryId': categoryId,
      'categoryDescription': categoryDescription,
    };
  }

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      categoryName: json['categoryName'] ?? '',
      categoryImage: json['categoryImage'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryDescription: json['categoryDescription'],
    );
  }
}

// Represents a single food item
class FoodItem extends Equatable {
  final String foodId;
  final String foodName;
  final String foodImage;
  final String foodDescription;
  final double foodPrice; // Using double for monetary values
  final FoodCategory foodCategory;
  final bool isVegan;
  final bool isLactoseFree; // Additional dietary marking
  final bool containsEgg;
  final bool isGlutenFree; // Additional dietary marking
  final List<Allergens> allergies; // Allergy information
  final List<FoodItem> sides; // Side dishes
  final List<FoodItem> recommendations; // Recommended foods
  final double? discount; // Discount value
  final int spiceLevel; // Spice level (1-5 or similar scale)

  final double nutritionalInfo;

  final bool isAvailable;

  FoodItem({
    required this.foodId,
    required this.foodName,
    required this.foodImage,
    required this.foodDescription,
    required this.foodPrice,
    required this.foodCategory,
    this.isVegan = false,
    this.containsEgg = false,
    this.isGlutenFree = false,
    this.allergies = const [],
    this.sides = const [],
    this.recommendations = const [],
    this.discount,
    this.spiceLevel = 0,
    this.nutritionalInfo = 0.0,
    this.isAvailable = true,
    this.isLactoseFree = false,
  });

  FoodItem copyWith({
    String? foodId,
    String? foodName,
    String? foodImage,
    String? foodDescription,
    double? foodPrice,
    FoodCategory? foodCategory,
    bool? isVegan,
    bool? containsEgg,
    bool? isGlutenFree,
    List<Allergens>? allergies,
    List<FoodItem>? sides,
    List<FoodItem>? recommendations,
    double? discount,
    int? spiceLevel,
  }) {
    return FoodItem(
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      foodImage: foodImage ?? this.foodImage,
      foodDescription: foodDescription ?? this.foodDescription,
      foodPrice: foodPrice ?? this.foodPrice,
      foodCategory: foodCategory ?? this.foodCategory,
      isVegan: isVegan ?? this.isVegan,
      containsEgg: containsEgg ?? this.containsEgg,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      allergies: allergies ?? this.allergies,
      sides: sides ?? this.sides,
      recommendations: recommendations ?? this.recommendations,
      discount: discount ?? this.discount,
      spiceLevel: spiceLevel ?? this.spiceLevel,
    );
  }

  @override
  List<Object?> get props => [
        foodId,
        foodName,
        foodImage,
        foodDescription,
        foodPrice,
        foodCategory,
        isVegan,
        containsEgg,
        isGlutenFree,
        allergies,
        sides,
        recommendations,
        discount,
        spiceLevel,
        isAvailable,
        nutritionalInfo,
        isLactoseFree,
      ];

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'foodImage': foodImage,
      'foodDescription': foodDescription,
      'foodPrice': foodPrice,
      'foodCategory': foodCategory.toJson(),
      'isVegan': isVegan,
      'containsEgg': containsEgg,
      'isGlutenFree': isGlutenFree,
      'allergies': allergies.map((a) => a.toJson()).toList(),
      'sides': sides.map((s) => s.toJson()).toList(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'discount': discount,
      'spiceLevel': spiceLevel,
      'nutritionalInfo': nutritionalInfo,
      'isAvailable': isAvailable,
      'isLactoseFree': isLactoseFree,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodId: json['foodId'] ?? '',
      foodName: json['foodName'] ?? '',
      foodImage: json['foodImage'] ?? '',
      foodDescription: json['foodDescription'] ?? '',
      foodPrice: json['foodPrice']?.toDouble() ?? 0.0,
      foodCategory: FoodCategory.fromJson(json['foodCategory']),
      isVegan: json['isVegan'] ?? false,
      containsEgg: json['containsEgg'] ?? false,
      isGlutenFree: json['isGlutenFree'] ?? false,
      isLactoseFree: json['isLactoseFree'] ?? false,
      allergies: (json['allergies'] as List<dynamic>? ?? [])
          .map((a) => Allergens.fromJson(a))
          .toList(),
      sides: (json['sides'] as List<dynamic>? ?? [])
          .map((s) => FoodItem.fromJson(s))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((r) => FoodItem.fromJson(r))
          .toList(),
      discount: json['discount']?.toDouble(),
      spiceLevel: json['spiceLevel'] ?? 0,
      nutritionalInfo: json['nutritionalInfo']?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

// enum Allergens {
//   gluten,
//   peanuts,
//   treeNuts,
//   dairy,
//   soy,
//   eggs,
//   shellfish,
//   fish,
//   sesame,

// }

class Allergens extends Equatable {
  String allergenName;
  String allergenImage;
  String allergenId;

  Allergens({
    required this.allergenName,
    required this.allergenImage,
    required this.allergenId,
  });

  Allergens copyWith({
    String? allergenName,
    String? allergenImage,
    String? allergenId,
  }) {
    return Allergens(
      allergenName: allergenName ?? this.allergenName,
      allergenImage: allergenImage ?? this.allergenImage,
      allergenId: allergenId ?? this.allergenId,
    );
  }

  @override
  List<Object?> get props => [allergenName, allergenImage, allergenId];

  Map<String, dynamic> toJson() {
    return {
      'allergenName': allergenName,
      'allergenImage': allergenImage,
      'allergenId': allergenId,
    };
  }

  factory Allergens.fromJson(Map<String, dynamic> json) {
    return Allergens(
      allergenName: json['allergenName'] ?? '',
      allergenImage: json['allergenImage'] ?? '',
      allergenId: json['allergenId'] ?? '',
    );
  }
}
