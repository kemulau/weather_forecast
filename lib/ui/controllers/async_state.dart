class AsyncState<T> {
  final bool isLoading;
  final T? data;
  final Object? error;

  const AsyncState._({required this.isLoading, this.data, this.error});

  const AsyncState.initial() : this._(isLoading: false);

  const AsyncState.loading() : this._(isLoading: true);

  const AsyncState.data(T data) : this._(isLoading: false, data: data);

  const AsyncState.error(Object error)
      : this._(isLoading: false, error: error);
}
