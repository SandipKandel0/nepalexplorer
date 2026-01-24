import '../../domain/entities/guide_entity.dart';

class GuideModel extends GuideEntity {
  const GuideModel({
    String? guideId,
    required String authId,
    required int experience,
    required List<String> languages,
    required String bio,
    double rating = 0.0,
    bool isAvailable = true,
  }) : super(
          guideId: guideId,
          authId: authId,
          experience: experience,
          languages: languages,
          bio: bio,
          rating: rating,
          isAvailable: isAvailable,
        );

factory GuideModel.fromJson(Map<String, dynamic> json) {
  return GuideModel(
    guideId: json['guideId']?.toString(),
    authId: json['authId'] ?? '',
    experience: json['experience'] ?? 0,
    languages: json['languages'] != null
        ? List<String>.from(json['languages'])
        : [],
    bio: json['bio'] ?? '',
    rating: (json['rating'] ?? 0).toDouble(),
    isAvailable: json['isAvailable'] ?? true,
  );
}


  Map<String, dynamic> toJson() {
    return {
      "guideId": guideId,
      "authId": authId,
      "experience": experience,
      "languages": languages,
      "bio": bio,
      "rating": rating,
      "isAvailable": isAvailable,
    };
  }
}
