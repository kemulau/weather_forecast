abstract class AppException implements Exception {
  final int statusCode;
  final int code;
  final String message;

  const AppException(this.statusCode, this.code, this.message);

  String get userMessage;

  @override
  String toString() => 'erro $code: $message';
}

class ApiKeyMissing extends AppException {
  ApiKeyMissing(int statusCode, String message)
      : super(statusCode, 1002, message);

  @override
  String get userMessage => 'Chave da API não informada. Configure WEATHER_API_KEY.';
}

class QueryMissing extends AppException {
  QueryMissing(int statusCode, String message)
      : super(statusCode, 1003, message);

  @override
  String get userMessage => 'Parâmetro de busca ausente. Informe uma cidade.';
}

class LocationNotFound extends AppException {
  LocationNotFound(int statusCode, String message)
      : super(statusCode, 1006, message);

  @override
  String get userMessage => 'Localização não encontrada. Verifique o nome e tente novamente.';
}

class InvalidKey extends AppException {
  InvalidKey(int statusCode, String message)
      : super(statusCode, 2006, message);

  @override
  String get userMessage => 'Chave da API inválida. Revise a WEATHER_API_KEY.';
}

class QuotaExceeded extends AppException {
  QuotaExceeded(int statusCode, String message)
      : super(statusCode, 2007, message);

  @override
  String get userMessage => 'Cota de uso excedida. Tente novamente mais tarde.';
}

class KeyDisabled extends AppException {
  KeyDisabled(int statusCode, String message)
      : super(statusCode, 2008, message);

  @override
  String get userMessage => 'Chave da API desativada. Verifique sua conta.';
}

class PlanNotAllowed extends AppException {
  PlanNotAllowed(int statusCode, String message)
      : super(statusCode, 2009, message);

  @override
  String get userMessage =>
      'Plano atual não permite esta operação. Reduza os dias ou atualize seu plano.';
}

class UnknownApiError extends AppException {
  UnknownApiError(int statusCode, int code, String message)
      : super(statusCode, code, message);

  @override
  String get userMessage => message;
}
