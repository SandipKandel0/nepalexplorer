import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:nepalexplorer/features/dashboard/presentation/view_model/user_profile_viewmodel.dart';

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
  test('fetchProfile loads user profile data', () async {
    final fakeApi = FakeApiClient(
      onGet: (path) async {
        expect(path, ApiEndpoints.getProfile);
        return _response(
          statusCode: 200,
          data: {
            'data': {
              'user': {
                '_id': 'u-1',
                'fullName': 'Test User',
                'email': 'user@test.com',
                'phoneNumber': '9800000000',
                'profilePicture': '/uploads/user.png',
              },
            },
          },
        );
      },
    );

    final vm = UserProfileViewModel(apiClient: fakeApi);

    await vm.fetchProfile();

    expect(vm.errorMessage, isNull);
    expect(vm.profile, isNotNull);
    expect(vm.profile!.authId, 'u-1');
    expect(vm.profile!.fullName, 'Test User');
    expect(vm.profile!.email, 'user@test.com');
    expect(vm.profile!.phoneNumber, '9800000000');
  });

  test('fetchProfile sets error when API throws DioException', () async {
    final fakeApi = FakeApiClient(
      onGet: (path) async {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          response: _response(
            statusCode: 401,
            data: {'message': 'No token'},
          ),
          type: DioExceptionType.badResponse,
        );
      },
    );

    final vm = UserProfileViewModel(apiClient: fakeApi);

    await vm.fetchProfile();

    expect(vm.profile, isNull);
    expect(vm.errorMessage, 'No token');
  });

  test('updateProfile updates mapped user profile on success', () async {
    final fakeApi = FakeApiClient(
      onUpload: (path, formData) async {
        expect(path, ApiEndpoints.updateProfile);
        return _response(
          statusCode: 200,
          data: {
            'data': {
              'user': {
                '_id': 'u-2',
                'fullName': 'Updated User',
                'email': 'updated@test.com',
                'phoneNumber': '9812345678',
                'profilePicture': '/uploads/updated.png',
              },
            },
          },
        );
      },
    );
    final vm = UserProfileViewModel(apiClient: fakeApi);

    await vm.updateProfile(fullName: 'Updated User', phoneNumber: '9812345678');

    expect(vm.errorMessage, isNull);
    expect(vm.profile, isNotNull);
    expect(vm.profile!.fullName, 'Updated User');
    expect(vm.profile!.email, 'updated@test.com');
  });

  test('updateProfile sets failed message on non-200', () async {
    final fakeApi = FakeApiClient(
      onUpload: (_, __) async => _response(statusCode: 400, data: {'message': 'Bad request'}),
    );
    final vm = UserProfileViewModel(apiClient: fakeApi);

    await vm.updateProfile(fullName: 'U', phoneNumber: '9');

    expect(vm.errorMessage, 'Failed to update profile');
  });

  test('updateProfile extracts DioException message', () async {
    final fakeApi = FakeApiClient(
      onUpload: (path, formData) async {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          response: _response(statusCode: 401, data: {'message': 'Unauthorized'}),
          type: DioExceptionType.badResponse,
        );
      },
    );
    final vm = UserProfileViewModel(apiClient: fakeApi);

    await vm.updateProfile(fullName: 'U', phoneNumber: '9');

    expect(vm.errorMessage, 'Unauthorized');
  });
}
