class AdminUser {
  String? sId;
  String? username;
  String? name;
  String? email;
  String? clearanceLevel;
  dynamic createdBy; // Change from String? to dynamic
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  AdminUser({
    this.sId,
    this.username,
    this.name,
    this.email,
    this.clearanceLevel,
    this.createdBy,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  AdminUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    name = json['name'];
    email = json['email'];
    clearanceLevel = json['clearanceLevel'];

    // Handle createdBy - it can be String (ID) or Map (populated user object)
    if (json['createdBy'] != null) {
      if (json['createdBy'] is String) {
        createdBy = json['createdBy'];
      } else if (json['createdBy'] is Map<String, dynamic>) {
        // Extract just the ID from the populated user object
        createdBy = json['createdBy']['_id']?.toString();
      }
    }

    isActive = json['isActive'];
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['username'] = username;
    data['name'] = name;
    data['email'] = email;
    data['clearanceLevel'] = clearanceLevel;
    data['createdBy'] = createdBy;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  bool get isSuperAdmin => clearanceLevel == 'super_admin';
  bool get isAdmin => clearanceLevel == 'admin';
}
