import 'package:equatable/equatable.dart';

class GuideEntity extends Equatable {
  final String? guideId;
  final String authId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final int experience;
  final List<String> languages;
  final String bio;
  final bool isAvailable;
  final String? profilePictureUrl;

  const GuideEntity({
    this.guideId,
    required this.authId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.experience,
    required this.languages,
    required this.bio,
    this.isAvailable = true,
    this.profilePictureUrl,
  });

  @override
  List<Object?> get props => [
        guideId,
        authId,
        fullName,
        email,
        phoneNumber,
        experience,
        languages,
        bio,
        isAvailable,
        profilePictureUrl,
      ];

  /// CopyWith for updating entity easily
  GuideEntity copyWith({
    String? guideId,
    String? authId,
    String? fullName,
    String? email,
    String? phoneNumber,
    int? experience,
    List<String>? languages,
    String? bio,
    bool? isAvailable,
    String? profilePictureUrl,
  }) {
    return GuideEntity(
      guideId: guideId ?? this.guideId,
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      experience: experience ?? this.experience,
      languages: languages ?? this.languages,
      bio: bio ?? this.bio,
      isAvailable: isAvailable ?? this.isAvailable,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
