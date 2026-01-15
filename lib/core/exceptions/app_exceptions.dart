import 'package:news_reader/core/constants/api_constants.dart';

/// Base Exception Class
/// Class dasar untuk semua exception di aplikasi
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  AppException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'AppException: $message (Status Code: $statusCode)';
    }
    return 'AppException: $message';
  }
}

/// Network Exception
/// Error yang berhubungan dengan koneksi internet
class NetworkException extends AppException {
  NetworkException({
    String? message,
    super.originalError,
  }) : super(
          message: message ?? ErrorMessages.noInternet,
        );
}

/// API Exception
/// Error dari API response
class ApiException extends AppException {
  ApiException({
    required super.message,
    super.statusCode,
    super.originalError,
  });

  /// Factory method untuk membuat ApiException berdasarkan status code
  factory ApiException.fromStatusCode(int statusCode, {String? message}) {
    switch (statusCode) {
      case 400:
        return ApiException(
          message: message ?? 'Bad request. Please check your input.',
          statusCode: statusCode,
        );
      case 401:
        return ApiException(
          message: message ?? ErrorMessages.invalidApiKey,
          statusCode: statusCode,
        );
      case 403:
        return ApiException(
          message: message ?? 'Access forbidden.',
          statusCode: statusCode,
        );
      case 404:
        return ApiException(
          message: message ?? 'Resource not found.',
          statusCode: statusCode,
        );
      case 429:
        return ApiException(
          message: message ?? ErrorMessages.apiLimitReached,
          statusCode: statusCode,
        );
      case 500:
      case 502:
      case 503:
        return ApiException(
          message: message ?? ErrorMessages.serverError,
          statusCode: statusCode,
        );
      default:
        return ApiException(
          message: message ?? ErrorMessages.unknownError,
          statusCode: statusCode,
        );
    }
  }
}

/// Parse Exception
/// Error saat parsing data dari API
class ParseException extends AppException {
  ParseException({
    String? message,
    super.originalError,
  }) : super(
          message: message ?? 'Failed to parse data from server.',
        );
}

/// Cache Exception
/// Error yang berhubungan dengan cache
class CacheException extends AppException {
  CacheException({
    String? message,
    super.originalError,
  }) : super(
          message: message ?? 'Failed to access cache.',
        );
}

/// No Data Exception
/// Error ketika tidak ada data
class NoDataException extends AppException {
  NoDataException({
    String? message,
  }) : super(
          message: message ?? ErrorMessages.noDataFound,
        );
}

/// Timeout Exception
/// Error ketika request timeout
class TimeoutException extends AppException {
  TimeoutException({
    String? message,
  }) : super(
          message: message ?? 'Request timeout. Please try again.',
        );
}

/// Exception Handler Utility
/// Utility untuk menghandle berbagai jenis error
class ExceptionHandler {
  /// Convert generic error menjadi AppException
  static AppException handleError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    // Handle berbagai jenis error
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return NetworkException(originalError: error);
    }

    if (errorString.contains('timeout')) {
      return TimeoutException();
    }

    if (errorString.contains('format') || errorString.contains('parse')) {
      return ParseException(originalError: error);
    }

    // Default unknown error
    return AppException(
      message: ErrorMessages.unknownError,
      originalError: error,
    );
  }

  /// Get user-friendly error message
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return ErrorMessages.unknownError;
  }
}
