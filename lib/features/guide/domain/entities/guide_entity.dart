import 'package:equatable/equatable.dart';

class GuideEntity extends Equatable {
  final String? guideId;
  final String authId;
  final int experience;
  final List<String> languages;
  final String bio;
  final double rating;
  final bool isAvailable;

  const GuideEntity({
    this.guideId,
    required this.authId,
    required this.experience,
    required this.languages,
    required this.bio,
    this.rating = 0.0,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
        guideId,
        authId,
        experience,
        languages,
        bio,
        rating,
        isAvailable,
      ];
}
