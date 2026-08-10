class ErrorUtils {
  static String getHumanReadableError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('connection failed') ||
        errorString.contains('network is unreachable')) {
      return 'Network connection failed. Please check your internet connection.';
    }

    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Server is taking too long to respond. Please try again.';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Requested resource not found.';
    }

    if (errorString.contains('500') ||
        errorString.contains('internal server error')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('format') ||
        errorString.contains('json') ||
        errorString.contains('parsing')) {
      return 'Invalid response from server. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }

  static String getOperationErrorMessage(String operation) {
    switch (operation.toLowerCase()) {
      case 'add':
      case 'create':
        return 'Failed to create item. Please try again.';
      case 'update':
      case 'edit':
        return 'Failed to update item. Please try again.';
      case 'delete':
      case 'remove':
        return 'Failed to delete item. Please try again.';
      case 'fetch':
      case 'load':
      case 'get':
        return 'Failed to load data. Please try again.';
      default:
        return 'Operation failed. Please try again.';
    }
  }
}
