class Poster {
  String? sId;
  String? posterName;
  String? imageUrl;
  dynamic createdBy; // Change to dynamic
  String? createdAt;
  String? updatedAt;
  int? iV;

  Poster({
    this.sId,
    this.posterName,
    this.imageUrl,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Poster.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    posterName = json['posterName'];
    imageUrl = json['imageUrl'];
    createdBy = json['createdBy']; // Can be String or Map
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.sId;
    data['posterName'] = this.posterName;
    data['imageUrl'] = this.imageUrl;
    data['createdBy'] = this.createdBy;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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
