abstract interface class ApiErrorMapper<T> {
  T mapError(Object exception, StackTrace? stackTrace);
}
