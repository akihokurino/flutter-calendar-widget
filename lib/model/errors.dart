import 'dart:isolate';

class AppError extends RemoteError {
  AppError(String message) : super(message, "");
}
