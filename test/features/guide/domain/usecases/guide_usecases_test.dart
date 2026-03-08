import 'package:flutter_test/flutter_test.dart';
import 'package:nepalexplorer/features/guide/domain/entities/guide_entity.dart';
import 'package:nepalexplorer/features/guide/domain/repositories/guide_repository.dart';
import 'package:nepalexplorer/features/guide/domain/usecases/get_guide_profile.dart';
import 'package:nepalexplorer/features/guide/domain/usecases/update_guide_profile.dart';

class FakeGuideRepository implements GuideRepository {
  GuideEntity? profileResult;
  String? lastAuthId;
  GuideEntity? lastUpdatedGuide;
  bool shouldThrowOnGet = false;
  bool shouldThrowOnUpdate = false;

  @override
  Future<GuideEntity> getGuideProfile(String authId) async {
    lastAuthId = authId;
    if (shouldThrowOnGet) {
      throw Exception('failed to fetch');
    }
    return profileResult ??
        const GuideEntity(
          authId: 'g-1',
          fullName: 'Guide',
          email: 'guide@example.com',
          phoneNumber: '9800000000',
          experience: 5,
          languages: ['English'],
          bio: 'Default guide',
        );
  }

  @override
  Future<void> updateGuideProfile(GuideEntity guide) async {
    if (shouldThrowOnUpdate) {
      throw Exception('failed to update');
    }
    lastUpdatedGuide = guide;
  }
}

void main() {
  group('Guide usecases', () {
    late FakeGuideRepository repository;

    setUp(() {
      repository = FakeGuideRepository();
    });

    test('GetGuideProfile returns profile and forwards authId', () async {
      final usecase = GetGuideProfile(repository);

      final result = await usecase('auth-99');

      expect(repository.lastAuthId, 'auth-99');
      expect(result.authId, 'g-1');
      expect(result.email, 'guide@example.com');
    });

    test('GetGuideProfile rethrows repository exception', () async {
      repository.shouldThrowOnGet = true;
      final usecase = GetGuideProfile(repository);

      expect(() => usecase('auth-99'), throwsException);
    });

    test('UpdateGuideProfile sends entity to repository', () async {
      final usecase = UpdateGuideProfile(repository);
      const guide = GuideEntity(
        authId: 'g-10',
        fullName: 'Updated Guide',
        email: 'updated@example.com',
        phoneNumber: '9811111111',
        experience: 9,
        languages: ['English', 'Nepali'],
        bio: 'Experienced',
      );

      await usecase(guide);

      expect(repository.lastUpdatedGuide, isNotNull);
      expect(repository.lastUpdatedGuide!.fullName, 'Updated Guide');
      expect(repository.lastUpdatedGuide!.experience, 9);
    });

    test('UpdateGuideProfile rethrows repository exception', () async {
      repository.shouldThrowOnUpdate = true;
      final usecase = UpdateGuideProfile(repository);
      const guide = GuideEntity(
        authId: 'g-11',
        fullName: 'Guide',
        email: 'g@example.com',
        phoneNumber: '9800000000',
        experience: 1,
        languages: ['Nepali'],
        bio: 'Bio',
      );

      expect(() => usecase(guide), throwsException);
    });
  });
}
