
class NetworkProcess<T> {
  final String message;
  final bool isCompleted;
  final bool isIdeal;
  final bool isSuccessful;
  final bool isProcessing;
  final Exception? exception;
  final T? data;

  bool get hasError => exception != null;


  const NetworkProcess({
    required this.message,
    required this.isCompleted,
    required this.isSuccessful,
    this.isIdeal = false,
    this.isProcessing = false,
    required this.exception,
    this.data,
  });

  NetworkProcess<TR> transform<TR>([TR? data]) => NetworkProcess(
        message: this.message,
        isIdeal: this.isIdeal,
        isSuccessful: this.isSuccessful,
        isCompleted: this.isCompleted,
        isProcessing: this.isProcessing,
        exception: this.exception,
        data: data,
      );

  NetworkProcess<T> copyWith({
    String? message,
    bool? isSuccessful,
    bool? isCompleted,
    bool? isProcessing,
    bool? isStarted,
    Exception? exception,
    T? data,
  }) =>
      NetworkProcess(
        message: message ?? this.message,
        isSuccessful: isSuccessful ?? this.isSuccessful,
        isCompleted: isCompleted ?? this.isCompleted,
        isIdeal: isStarted ?? this.isIdeal,
        isProcessing: isProcessing ?? this.isProcessing,
        exception: exception ?? this.exception,
        data: data ?? this.data,
      );

  NetworkProcess.newProcess()
      : message = "",
        isCompleted = false,
        isSuccessful = false,
        isProcessing = false,
        isIdeal = true,
        data = null,
        exception = null;

  NetworkProcess.processing({String? msg})
      : message = "processing",
        isCompleted = false,
        isSuccessful = false,
        isProcessing = true,
        isIdeal = false,
        data = null,
        exception = null;

  NetworkProcess.succeeded({String msg = "", T? newData})
      : message = msg,
        isCompleted = true,
        isSuccessful = true,
        isProcessing = false,
        isIdeal = false,
        data = newData,
        exception = null;

  NetworkProcess.failed(Exception? exception, [String? message, T? newData])
      : exception = exception ?? Exception("Unknown Error"),
        message = message ??"Unknown Error",
        isCompleted = true,
        isSuccessful = false,
        isProcessing = false,
        isIdeal = false,
        data = newData;
}
