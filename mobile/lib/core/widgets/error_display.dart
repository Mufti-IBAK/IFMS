import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../theme/app_colors.dart';

class ErrorDisplay extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? customMessage;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
  });

  String _getFriendlyMessage() {
    if (customMessage != null) return customMessage!;

    if (error is DioException) {
      final dioError = error as DioException;
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The connection timed out. Please check your internet connection and try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please verify your network and try again.';
        case DioExceptionType.badResponse:
          final status = dioError.response?.statusCode;
          if (status == 404) {
            return 'The requested information could not be found on the server.';
          } else if (status == 403 || status == 401) {
            return 'Access denied. You do not have permission to view this details.';
          } else if (status == 500) {
            return 'The server encountered an error. Our team has been notified. Please try again later.';
          }
          return 'Server returned an error ($status). Please try again.';
        default:
          return 'A network error occurred. Please try again.';
      }
    }

    final errString = error.toString().toLowerCase();
    if (errString.contains('socketexception') || errString.contains('network_error')) {
      return 'No internet connection. Please connect to a network and try again.';
    }

    return 'Something went wrong while loading this information. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final message = _getFriendlyMessage();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.errorContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.errorContainer.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off,
                  color: AppColors.onErrorContainer,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to Load Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onErrorContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorContainer,
                    foregroundColor: AppColors.onErrorContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
