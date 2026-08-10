class Brand {
  String? sId;
  String? name;
  SubcategoryId? subcategoryId;
  dynamic createdBy; // Change to dynamic
  String? createdAt;
  String? updatedAt;

  Brand({
    this.sId,
    this.name,
    this.subcategoryId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Brand.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    subcategoryId = json['subcategoryId'] != null
        ? SubcategoryId.fromJson(json['subcategoryId'])
        : null;
    createdBy = json['createdBy']; // Can be String or Map
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    if (subcategoryId != null) {
      data['subcategoryId'] = subcategoryId!.toJson();
    }
    data['createdBy'] = createdBy;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  // Helper methods
  String get createdByName {
    if (createdBy == null) return 'Unknown';
    if (createdBy is String) return createdBy as String;
    if (createdBy is Map<String, dynamic>) {
      return createdBy['name']?.toString() ??
          createdBy['username']?.toString() ??
          'Unknown Admin';
    }
    return 'Unknown';
  }
}

class SubcategoryId {
  String? sId;
  String? name;
  String? categoryId;
  String? createdBy; // Add this field
  String? createdAt;
  String? updatedAt;

  SubcategoryId(
      {this.sId,
      this.name,
      this.categoryId,
      this.createdBy, // Add this
      this.createdAt,
      this.updatedAt});

  SubcategoryId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    categoryId = json['categoryId'];
    createdBy = json['createdBy']; // Add this
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['categoryId'] = categoryId;
    data['createdBy'] = createdBy; // Add this
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
