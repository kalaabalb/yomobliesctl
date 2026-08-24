class Variant {
  String? sId;
  String? name;
  VariantTypeId? variantTypeId;
  dynamic createdBy; // Change to dynamic
  String? createdAt;
  String? updatedAt;

  Variant({
    this.sId,
    this.name,
    this.variantTypeId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Variant.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    variantTypeId = json['variantTypeId'] != null
        ? VariantTypeId.fromJson(json['variantTypeId'])
        : null;
    createdBy = json['createdBy']; // Can be String or Map
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    if (variantTypeId != null) {
      data['variantTypeId'] = variantTypeId!.toJson();
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

class VariantTypeId {
  String? sId;
  String? name;
  String? type;
  String? createdBy; // Add this field
  String? createdAt;
  String? updatedAt;

  VariantTypeId(
      {this.sId,
      this.name,
      this.type,
      this.createdBy, // Add this
      this.createdAt,
      this.updatedAt});

  VariantTypeId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    type = json['type'];
    createdBy = json['createdBy']; // Add this
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['type'] = type;
    data['createdBy'] = createdBy; // Add this
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
