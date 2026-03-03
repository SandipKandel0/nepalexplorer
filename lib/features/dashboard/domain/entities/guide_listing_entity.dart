class GuideListingEntity {
  final String guideId;
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String bio;
  final List<String> languages;
  final int experience;
  final String? profilePictureUrl;
  final double? rating;

  GuideListingEntity({
    required this.guideId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.bio,
    required this.languages,
    required this.experience,
    this.profilePictureUrl,
    this.rating,
  });
}
