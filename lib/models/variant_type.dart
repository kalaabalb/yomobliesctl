class VariantType {
  String? name;
  String? type;
  String? sId;
  dynamic createdBy; // Change to dynamic
  String? createdAt;
  String? updatedAt;

  VariantType({
    this.name,
    this.type,
    this.sId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  VariantType.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    sId = json['_id'];
    createdBy = json['createdBy']; // Can be String or Map
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['_id'] = sId;
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
