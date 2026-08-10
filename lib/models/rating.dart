class Rating {
  String? sId;
  String? productId;
  String? userId;
  String? userName;
  int? rating;
  String? review;
  bool? verifiedPurchase;
  String? createdAt;
  String? updatedAt;

  Rating({
    this.sId,
    this.productId,
    this.userId,
    this.userName,
    this.rating,
    this.review,
    this.verifiedPurchase,
    this.createdAt,
    this.updatedAt,
  });

  Rating.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    productId = json['productId'];
    userId = json['userId'];
    userName = json['userName'];
    rating = json['rating'];
    review = json['review'];
    verifiedPurchase = json['verifiedPurchase'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['productId'] = productId;
    data['userId'] = userId;
    data['userName'] = userName;
    data['rating'] = rating;
    data['review'] = review;
    data['verifiedPurchase'] = verifiedPurchase;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class RatingStats {
  double? averageRating;
  int? ratingCount;
  Map<String, int>? distribution;

  RatingStats({
    this.averageRating,
    this.ratingCount,
    this.distribution,
  });

  RatingStats.fromJson(Map<String, dynamic> json) {
    averageRating = json['averageRating']?.toDouble();
    ratingCount = json['ratingCount'];
    distribution = json['distribution'] != null
        ? Map<String, int>.from(json['distribution'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['averageRating'] = averageRating;
    data['ratingCount'] = ratingCount;
    data['distribution'] = distribution;
    return data;
  }
}
