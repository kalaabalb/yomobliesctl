class Category {
  String? sId;
  String? name;
  String? image;
  dynamic createdBy; // Change from String? to dynamic
  String? createdAt;
  String? updatedAt;

  Category({
    this.sId,
    this.name,
    this.image,
    this.createdBy, // Keep as dynamic
    this.createdAt,
    this.updatedAt,
  });

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
    createdBy = json['createdBy']; // Can be String or Map
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['image'] = image;
    data['createdBy'] = createdBy;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  // Helper method to get creator name
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

  // Helper method to get creator ID
  String? get createdById {
    if (createdBy == null) return null;
    if (createdBy is Map<String, dynamic>) {
      return createdBy['_id']?.toString();
    }
    if (createdBy is String) return createdBy;
    return null;
  }
}
