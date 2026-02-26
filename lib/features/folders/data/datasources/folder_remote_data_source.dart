import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../audio_manager/data/models/audio_file_model.dart';
import '../../domain/entities/folder_create.dart';
import '../../domain/entities/folder_search_dto.dart';
import '../../domain/entities/folder_update.dart';
import '../../domain/entities/move_audio_to_folder.dart';
import '../models/folder_model.dart';
import '../models/folder_page_model.dart';

abstract class FolderRemoteDataSource {
  Future<FolderModel> createFolder(FolderCreate request);
  Future<FolderPageModel> searchFolders(FolderSearchDto request);
  Future<FolderModel> getFolderDetails(int folderId);
  Future<FolderModel> updateFolder(int folderId, FolderUpdate request);
  Future<void> deleteFolder(int folderId);
  Future<List<AudioFileModel>> getAudioInFolder(
    int folderId, {
    int skip = 0,
    int limit = 100,
  });
  Future<AudioFileModel> moveAudioToFolder(MoveAudioToFolder request);
}

class FolderRemoteDataSourceImpl implements FolderRemoteDataSource {
  final Dio dio;

  FolderRemoteDataSourceImpl({required this.dio});

  @override
  Future<FolderModel> createFolder(FolderCreate request) async {
    try {
      final response = await dio.post(
        AppConstants.foldersEndpoint,
        data: request.toJson(),
      );

      final data = _extractData(
        response,
        fallbackMessage: 'Failed to create folder',
      );

      return FolderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e, fallbackMessage: 'Failed to create folder');
    }
  }

  @override
  Future<FolderPageModel> searchFolders(FolderSearchDto request) async {
    try {
      final response = await dio.post(
        AppConstants.folderSearchEndpoint,
        data: request.toJson(),
      );

      final data = _extractData(
        response,
        fallbackMessage: 'Failed to search folders',
      );

      if (data is List) {
        return FolderPageModel.fromJson({
          'items': data,
          'total': data.length,
          'page': request.page,
          'limit': request.pageSize,
          'has_next_page': false,
        });
      }

      return FolderPageModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e, fallbackMessage: 'Failed to search folders');
    }
  }

  @override
  Future<FolderModel> getFolderDetails(int folderId) async {
    try {
      final response = await dio.get(AppConstants.folderById(folderId));

      final data = _extractData(
        response,
        fallbackMessage: 'Failed to load folder details',
      );

      return FolderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        fallbackMessage: 'Failed to load folder details',
      );
    }
  }

  @override
  Future<FolderModel> updateFolder(
    int folderId,
    FolderUpdate request,
  ) async {
    try {
      final response = await dio.put(
        AppConstants.folderById(folderId),
        data: request.toJson(),
      );

      final data = _extractData(
        response,
        fallbackMessage: 'Failed to update folder',
      );

      return FolderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e, fallbackMessage: 'Failed to update folder');
    }
  }

  @override
  Future<void> deleteFolder(int folderId) async {
    try {
      final response = await dio.delete(AppConstants.folderById(folderId));

      _extractData(
        response,
        fallbackMessage: 'Failed to delete folder',
      );
    } on DioException catch (e) {
      throw _handleDioException(e, fallbackMessage: 'Failed to delete folder');
    }
  }

  @override
  Future<List<AudioFileModel>> getAudioInFolder(
    int folderId, {
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await dio.get(
        AppConstants.folderAudio(folderId),
        queryParameters: {'skip': skip, 'limit': limit},
      );

      final data = _extractData(
        response,
        fallbackMessage: 'Failed to load folder audio',
      );

      if (data is! List) {
        throw const ServerException('Invalid response data');
      }

      return data
          .map(
            (item) => AudioFileModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(
        e,
        fallbackMessage: 'Failed to load folder audio',
      );
    }
  }

  @override
  Future<AudioFileModel> moveAudioToFolder(
    MoveAudioToFolder request,
  ) async {
    try {
      final response = await dio.post(
        AppConstants.moveAudioToFolderEndpoint,
        data: request.toJson(),
      );

      final data = _extractData(
        response,
        fallbackMessage: 'Failed to move audio',
      );

      return AudioFileModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e, fallbackMessage: 'Failed to move audio');
    }
  }

  dynamic _extractData(
    Response<dynamic> response, {
    required String fallbackMessage,
  }) {
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw const ServerException('Invalid response format');
    }

    final success = payload['success'] == true;
    final statusCode = response.statusCode ?? 500;
    if (statusCode >= 200 && statusCode < 300 && success) {
      return payload['data'];
    }

    final message = payload['message']?.toString() ?? fallbackMessage;
    final code = payload['code'] is int ? payload['code'] as int : statusCode;
    throw ServerException(message, code: code);
  }

  ServerException _handleDioException(
    DioException exception, {
    required String fallbackMessage,
  }) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ??
          data['detail']?.toString() ??
          fallbackMessage;
      final code = data['code'] is int
          ? data['code'] as int
          : exception.response?.statusCode ?? 500;
      return ServerException(message, code: code);
    }
    return ServerException(
      fallbackMessage,
      code: exception.response?.statusCode ?? 500,
    );
  }
}
