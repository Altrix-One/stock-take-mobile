import 'dart:convert';

class ErrorMessageParser {
  /// Parse technical error messages and convert them to user-friendly messages
  static String parseLeaveApplicationError(String errorMessage) {
    if (errorMessage.isEmpty)
      return 'An unknown error occurred. Please try again.';

    // Convert to lowercase for easier matching
    final lowerError = errorMessage.toLowerCase();

    // Check for overlap errors
    if (lowerError.contains('overlapError') ||
        lowerError.contains('overlap') ||
        lowerError.contains('already applied for')) {
      return 'You have already applied for leave during this period. Please check your existing leave applications and choose different dates.';
    }

    // Check for insufficient balance errors
    if (lowerError.contains('insufficient') ||
        lowerError.contains('balance') ||
        lowerError.contains('not enough leave')) {
      return 'You do not have sufficient leave balance for this request. Please check your leave balance and adjust the dates accordingly.';
    }

    // Check for timestamp/concurrency errors
    if (lowerError.contains('timestampmismatcherror') ||
        lowerError.contains('has been modified after you have opened it')) {
      return 'This leave application has been modified by another user or system process. Please refresh the page and try submitting your application again.';
    }

    // Check for cancelled document errors
    if (lowerError.contains('cannot edit cancelled document') ||
        lowerError.contains('validationError')) {
      return 'This operation cannot be completed as the document has been cancelled or is no longer editable.';
    }

    // Check for date validation errors
    if (lowerError.contains('date') &&
        (lowerError.contains('invalid') ||
            lowerError.contains('past') ||
            lowerError.contains('future'))) {
      return 'The selected dates are invalid. Please ensure you are selecting appropriate leave dates within the allowed range.';
    }

    // Check for permission/authorization errors
    if (lowerError.contains('permission') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('access denied')) {
      return 'You do not have permission to perform this action. Please contact your HR administrator.';
    }

    // Check for network/connectivity errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('unreachable')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }

    // Check for server errors
    if (lowerError.contains('500') ||
        lowerError.contains('internal server error') ||
        lowerError.contains('server error')) {
      return 'Server error occurred. Please try again later or contact support if the problem persists.';
    }

    // Check for authentication errors
    if (lowerError.contains('401') ||
        lowerError.contains('authentication') ||
        lowerError.contains('token') ||
        lowerError.contains('login')) {
      return 'Your session has expired. Please log in again to continue.';
    }

    // Try to extract meaningful message from JSON errors
    try {
      if (errorMessage.contains('{')) {
        final jsonStart = errorMessage.indexOf('{');
        final jsonPart = errorMessage.substring(jsonStart);
        final errorData = jsonDecode(jsonPart) as Map<String, dynamic>;

        // Check for exception messages
        if (errorData['exception'] != null) {
          final exception = errorData['exception'].toString();
          return parseLeaveApplicationError(
              exception); // Recursive call with extracted message
        }

        // Check for message field
        if (errorData['message'] != null) {
          return parseLeaveApplicationError(errorData['message'].toString());
        }
      }
    } catch (_) {
      // JSON parsing failed, continue with fallback
    }

    // Fallback: Return a sanitized version of the original error
    return 'Application could not be submitted: ${_sanitizeErrorMessage(errorMessage)}. Please review your request and try again.';
  }

  /// Parse general error messages for other operations
  static String parseGeneralError(String errorMessage,
      {String operation = 'operation'}) {
    if (errorMessage.isEmpty)
      return 'An unknown error occurred during $operation.';

    final lowerError = errorMessage.toLowerCase();

    // Network errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return 'Network error. Please check your connection and try again.';
    }

    // Server errors
    if (lowerError.contains('500') || lowerError.contains('server error')) {
      return 'Server error occurred. Please try again later.';
    }

    // Authentication errors
    if (lowerError.contains('401') || lowerError.contains('unauthorized')) {
      return 'Authentication required. Please log in again.';
    }

    // Permission errors
    if (lowerError.contains('403') || lowerError.contains('permission')) {
      return 'You do not have permission to perform this action.';
    }

    // Not found errors
    if (lowerError.contains('404') || lowerError.contains('not found')) {
      return 'The requested resource was not found.';
    }

    return 'Error during $operation: ${_sanitizeErrorMessage(errorMessage)}';
  }

  /// Sanitize error messages for user display
  static String _sanitizeErrorMessage(String message) {
    // Remove technical stack traces and long JSON strings
    if (message.length > 200) {
      message = message.substring(0, 200) + '...';
    }

    // Remove HTML tags
    message = message.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove technical prefixes
    message = message
        .replaceFirst(RegExp(r'^[A-Z][a-z]+ API error \d+:\s*'), '')
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^Error:\s*'), '');

    return message.trim();
  }

  /// Get appropriate icon for error type
  static String getErrorIcon(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();

    if (lowerError.contains('timestampmismatcherror') ||
        lowerError.contains('has been modified after you have opened it')) {
      return '🔄'; // Sync icon for concurrency issues
    }

    if (lowerError.contains('overlap') ||
        lowerError.contains('already applied')) {
      return '📅'; // Calendar icon for date conflicts
    }

    if (lowerError.contains('balance') || lowerError.contains('insufficient')) {
      return '⚖️'; // Balance scale for insufficient balance
    }

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return '🌐'; // Globe for network issues
    }

    if (lowerError.contains('permission') ||
        lowerError.contains('unauthorized')) {
      return '🔒'; // Lock for permission issues
    }

    return '⚠️'; // Warning for general errors
  }
}
