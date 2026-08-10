class SubCategory {
  String? sId;
  String? name;
  CategoryId? categoryId;
  dynamic createdBy; // Change to dynamic
  String? createdAt;
  String? updatedAt;

  SubCategory({
    this.sId,
    this.name,
    this.categoryId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  SubCategory.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    categoryId = json['categoryId'] != null
        ? CategoryId.fromJson(json['categoryId'])
        : null;
    createdBy = json['createdBy']; // Can be String or Map
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    if (categoryId != null) {
      data['categoryId'] = categoryId!.toJson();
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

class CategoryId {
  String? sId;
  String? name;
  String? createdBy; // Add this field

  CategoryId({this.sId, this.name, this.createdBy}); // Add this

  CategoryId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    createdBy = json['createdBy']; // Add this
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    data['createdBy'] = createdBy; // Add this
    return data;
  }
}
