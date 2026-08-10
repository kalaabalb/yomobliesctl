import 'package:flutter/foundation.dart';

class Product {
  String? sId;
  String? name;
  String? description;
  int? quantity;
  double? price;
  double? offerPrice;
  ProRef? proCategoryId;
  ProRef? proSubCategoryId;
  ProRef? proBrandId;
  ProTypeRef? proVariantTypeId;
  List<String>? proVariantId;
  List<Images>? images;
  dynamic createdBy;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Product({
    this.sId,
    this.name,
    this.description,
    this.quantity,
    this.price,
    this.offerPrice,
    this.proCategoryId,
    this.proSubCategoryId,
    this.proBrandId,
    this.proVariantTypeId,
    this.proVariantId,
    this.images,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  // Helper getters for better UX
  bool get isInStock => (quantity ?? 0) > 0;
  bool get hasDiscount => (offerPrice ?? 0) > 0 && offerPrice! < price!;
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((price! - offerPrice!) / price! * 100).roundToDouble();
  }

  String get stockStatus {
    if (quantity == null) return 'Unknown';
    if (quantity! <= 0) return 'Out of Stock';
    if (quantity! <= 5) return 'Low Stock';
    return 'In Stock';
  }

  Product.fromJson(Map<String, dynamic> json) {
    try {
      sId = json['_id']?.toString();
      name = json['name']?.toString();
      description = json['description']?.toString();
      quantity = _parseInt(json['quantity']);
      price = _parseDouble(json['price']);
      offerPrice = _parseDouble(json['offerPrice']);

      // Handle category with null safety
      if (json['proCategoryId'] != null) {
        if (json['proCategoryId'] is Map) {
          proCategoryId = ProRef.fromJson(_convertMap(json['proCategoryId']));
        } else if (json['proCategoryId'] is String) {
          proCategoryId = ProRef(sId: json['proCategoryId']);
        }
      }

      // Handle subcategory with null safety
      if (json['proSubCategoryId'] != null) {
        if (json['proSubCategoryId'] is Map) {
          proSubCategoryId =
              ProRef.fromJson(_convertMap(json['proSubCategoryId']));
        } else if (json['proSubCategoryId'] is String) {
          proSubCategoryId = ProRef(sId: json['proSubCategoryId']);
        }
      }

      // Handle brand with null safety
      if (json['proBrandId'] != null) {
        if (json['proBrandId'] is Map) {
          proBrandId = ProRef.fromJson(_convertMap(json['proBrandId']));
        } else if (json['proBrandId'] is String) {
          proBrandId = ProRef(sId: json['proBrandId']);
        }
      }

      // Handle variant type with null safety
      if (json['proVariantTypeId'] != null) {
        if (json['proVariantTypeId'] is Map) {
          proVariantTypeId =
              ProTypeRef.fromJson(_convertMap(json['proVariantTypeId']));
        } else if (json['proVariantTypeId'] is String) {
          proVariantTypeId = ProTypeRef(sId: json['proVariantTypeId']);
        }
      }

      // Handle variant IDs
      if (json['proVariantId'] != null) {
        if (json['proVariantId'] is List) {
          proVariantId = (json['proVariantId'] as List)
              .map((item) => item.toString())
              .toList();
        } else if (json['proVariantId'] is String) {
          proVariantId = [json['proVariantId']];
        }
      }

      // Handle createdBy - it can be a Map or String
      if (json['createdBy'] != null) {
        if (json['createdBy'] is Map) {
          createdBy = _convertMap(json['createdBy']);
        } else if (json['createdBy'] is String) {
          createdBy = json['createdBy'];
        }
      }

      createdAt = json['createdAt']?.toString();
      updatedAt = json['updatedAt']?.toString();
      iV = _parseInt(json['__v']);

      // Handle images
      if (json['images'] != null && json['images'] is List) {
        images = <Images>[];
        for (var image in json['images']) {
          if (image is Map) {
            images!.add(Images.fromJson(_convertMap(image)));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Product: $e');
        print('Problematic JSON: $json');
      }
    }
  }

  // Convert Map<dynamic, dynamic> to Map<String, dynamic>
  Map<String, dynamic> _convertMap(dynamic map) {
    if (map == null) return {};

    if (map is Map<String, dynamic>) {
      return map;
    }

    if (map is Map<dynamic, dynamic>) {
      return map.cast<String, dynamic>();
    }

    return {};
  }

  // Helper methods for safe parsing
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['quantity'] = quantity;
    data['price'] = price;
    data['offerPrice'] = offerPrice;
    if (proCategoryId != null) {
      data['proCategoryId'] = proCategoryId!.toJson();
    }
    if (proSubCategoryId != null) {
      data['proSubCategoryId'] = proSubCategoryId!.toJson();
    }
    if (proBrandId != null) {
      data['proBrandId'] = proBrandId!.toJson();
    }
    if (proVariantTypeId != null) {
      data['proVariantTypeId'] = proVariantTypeId!.toJson();
    }
    data['proVariantId'] = proVariantId;

    // Handle createdBy for serialization
    if (createdBy != null) {
      if (createdBy is Map<String, dynamic>) {
        data['createdBy'] = createdBy;
      } else if (createdBy is String) {
        data['createdBy'] = createdBy;
      }
    }

    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }

  // Helper method to get createdBy as string (username or name)
  String? get createdByName {
    if (createdBy == null) return 'Unknown';
    if (createdBy is String) return createdBy as String;
    if (createdBy is Map<String, dynamic>) {
      return createdBy['name']?.toString() ??
          createdBy['username']?.toString() ??
          'Unknown Admin';
    }
    return 'Unknown';
  }

  // Helper method to get createdBy user ID
  String? get createdById {
    if (createdBy == null) return null;
    if (createdBy is Map<String, dynamic>) {
      return createdBy['_id']?.toString();
    }
    if (createdBy is String) return createdBy;
    return null;
  }

  // Get main image URL
  String? get mainImageUrl {
    if (images == null || images!.isEmpty) return null;
    return images!.first.url;
  }

  // Get all image URLs
  List<String> get allImageUrls {
    if (images == null) return [];
    return images!
        .map((img) => img.url ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }
}

class ProRef {
  String? sId;
  String? name;
  String? createdBy;

  ProRef({this.sId, this.name, this.createdBy});

  ProRef.fromJson(Map<String, dynamic> json) {
    try {
      sId = json['_id']?.toString();
      name = json['name']?.toString();
      createdBy = json['createdBy']?.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing ProRef: $e');
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['createdBy'] = createdBy;
    return data;
  }
}

class ProTypeRef {
  String? sId;
  String? type;
  String? createdBy;

  ProTypeRef({this.sId, this.type, this.createdBy});

  ProTypeRef.fromJson(Map<String, dynamic> json) {
    try {
      sId = json['_id']?.toString();
      type = json['type']?.toString();
      createdBy = json['createdBy']?.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing ProTypeRef: $e');
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['createdBy'] = createdBy;
    return data;
  }
}

class Images {
  int? image;
  String? url;
  String? sId;

  Images({this.image, this.url, this.sId});

  Images.fromJson(Map<String, dynamic> json) {
    try {
      image = _parseInt(json['image']);
      url = json['url']?.toString();
      sId = json['_id']?.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Images: $e');
      }
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['url'] = url;
    data['_id'] = sId;
    return data;
  }
}
