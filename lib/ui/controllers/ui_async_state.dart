class UiAsyncState<T> {
  final bool isLoading;
  final T? data;
  final Object? error;

  const UiAsyncState._({required this.isLoading, this.data, this.error});

  const UiAsyncState.initial() : this._(isLoading: false);

  const UiAsyncState.loading() : this._(isLoading: true);

  const UiAsyncState.data(T data) : this._(isLoading: false, data: data);

  const UiAsyncState.error(Object error)
      : this._(isLoading: false, error: error);
}
