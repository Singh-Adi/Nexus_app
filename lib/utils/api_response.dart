class ApiResponse<T> {
  final Status status;
  final T? data;
  final String? message;
  
  ApiResponse.loading() : status = Status.LOADING, data = null, message = null;
  ApiResponse.completed(this.data) : status = Status.COMPLETED, message = null;
  ApiResponse.error(this.message) : status = Status.ERROR, data = null;
  
  bool get isLoading => status == Status.LOADING;
  bool get isCompleted => status == Status.COMPLETED;
  bool get isError => status == Status.ERROR;
}

enum Status { LOADING, COMPLETED, ERROR }