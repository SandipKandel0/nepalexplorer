import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:nepalexplorer/features/guide/presentation/view_model/profile_viewmodel.dart';

class FakeApiClient extends ApiClient {
  FakeApiClient({this.onGet, this.onUpload});

  final Future<Response<dynamic>> Function(String path)? onGet;
  final Future<Response<dynamic>> Function(String path, FormData formData)? onUpload;

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (onGet == null) {
      throw UnimplementedError('onGet was not provided');
    }
    return onGet!(path);
  }

  @override
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    if (onUpload == null) {
      throw UnimplementedError('onUpload was not provided');
    }
    return onUpload!(path, formData);
  }
}

Response<dynamic> _response({required int statusCode, required dynamic data}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: '/test'),
    statusCode: statusCode,
    data: data,
  );
}

void main() {
  test('fetchProfile loads guide profile data', () async {
    final fakeApi = FakeApiClient(
      onGet: (path) async {
        expect(path, ApiEndpoints.guideProfile);
        return _response(
          statusCode: 200,
          data: {
            'data': {
              'user': {
                '_id': 'g-user-1',
                'fullName': 'Guide One',
                'email': 'guide@test.com',
                'phoneNumber': '9811111111',
              },
              'guide': {
                'bio': 'Mountain guide',
                'languages': ['English', 'Nepali'],
                'experience': 7,
                'profilePicture': '/uploads/guide.png',
              },
            },
          },
        );
      },
    );

    final vm = ProfileViewModel(apiClient: fakeApi);

    await vm.fetchProfile('ignored-auth-id');

    expect(vm.errorMessage, isNull);
    expect(vm.guide, isNotNull);
    expect(vm.guide!.fullName, 'Guide One');
    expect(vm.guide!.bio, 'Mountain guide');
    expect(vm.guide!.experience, 7);
    expect(vm.guide!.languages, ['English', 'Nepali']);
  });

  test('fetchProfile sets error when request fails', () async {
    final fakeApi = FakeApiClient(
      onGet: (path) async {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.connectionError,
        );
      },
    );

    final vm = ProfileViewModel(apiClient: fakeApi);

    await vm.fetchProfile('ignored-auth-id');

    expect(vm.guide, isNull);
    expect(vm.errorMessage, isNotNull);
    expect(vm.errorMessage!, startsWith('Error:'));
  });

  test('fetchProfile sets failed message for non-200 response', () async {
    final fakeApi = FakeApiClient(
      onGet: (_) async => _response(statusCode: 403, data: {'message': 'Forbidden'}),
    );

    final vm = ProfileViewModel(apiClient: fakeApi);
    await vm.fetchProfile('ignored');

    expect(vm.guide, isNull);
    expect(vm.errorMessage, 'Failed to load profile');
  });

  test('updateProfile updates guide entity on success', () async {
    final fakeApi = FakeApiClient(
      onUpload: (path, formData) async {
        expect(path, ApiEndpoints.guideProfile);
        return _response(
          statusCode: 200,
          data: {
            'data': {
              'user': {
                '_id': 'g-user-3',
                'fullName': 'Guide Updated',
                'email': 'updated-guide@test.com',
                'phoneNumber': '9812222222',
              },
              'guide': {
                'bio': 'Updated bio',
                'languages': ['Nepali'],
                'experience': 8,
                'profilePicture': '/uploads/g3.png',
              },
            },
          },
        );
      },
    );

    final vm = ProfileViewModel(apiClient: fakeApi);
    await vm.updateProfile(
      fullName: 'Guide Updated',
      email: 'updated-guide@test.com',
      phoneNumber: '9812222222',
      bio: 'Updated bio',
      languages: 'Nepali',
      experience: '8',
    );

    expect(vm.errorMessage, isNull);
    expect(vm.guide, isNotNull);
    expect(vm.guide!.fullName, 'Guide Updated');
    expect(vm.guide!.experience, 8);
  });

  test('updateProfile sets failed message for non-200 response', () async {
    final fakeApi = FakeApiClient(
      onUpload: (_, __) async => _response(statusCode: 400, data: {'message': 'Bad request'}),
    );

    final vm = ProfileViewModel(apiClient: fakeApi);
    await vm.updateProfile(
      fullName: 'Guide',
      email: 'g@test.com',
      phoneNumber: '980',
      bio: 'b',
      languages: 'English',
      experience: '1',
    );

    expect(vm.errorMessage, 'Failed to update profile');
  });
}
