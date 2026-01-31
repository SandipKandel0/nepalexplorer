import '../../domain/entities/guide_entity.dart';

class GuideModel extends GuideEntity {
  const GuideModel({
    String? guideId,
    required String authId,
    required String fullName,
    required String email,
    required String phoneNumber,
    required int experience,
    required List<String> languages,
    required String bio,
    double rating = 0.0,
    bool isAvailable = true,
    String? profilePictureUrl,
  }) : super(
          guideId: guideId,
          authId: authId,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          experience: experience,
          languages: languages,
          bio: bio,
          isAvailable: isAvailable,
          profilePictureUrl: profilePictureUrl,
        );

  /// From JSON (API response)
  factory GuideModel.fromJson(Map<String, dynamic> json) {
    return GuideModel(
      guideId: json['guideId']?.toString(),
      authId: json['authId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      experience: json['experience'] ?? 0,
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : [],
      bio: json['bio'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      profilePictureUrl: json['profilePictureUrl'], // optional
    );
  }

  /// To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      "guideId": guideId,
      "authId": authId,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "experience": experience,
      "languages": languages,
      "bio": bio,
      "isAvailable": isAvailable,
      "profilePictureUrl": profilePictureUrl,
    };
  }

  /// Convert entity to model
  factory GuideModel.fromEntity(GuideEntity entity) {
    return GuideModel(
      guideId: entity.guideId,
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      experience: entity.experience,
      languages: entity.languages,
      bio: entity.bio,
      isAvailable: entity.isAvailable,
      profilePictureUrl: entity.profilePictureUrl,
    );
  }

  /// Convert model to entity
  GuideEntity toEntity() {
    return GuideEntity(
      guideId: guideId,
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      experience: experience,
      languages: languages,
      bio: bio,
      isAvailable: isAvailable,
      profilePictureUrl: profilePictureUrl,
    );
  }
}
