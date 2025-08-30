abstract class MarineApiService {
  Future<Map<String, dynamic>> getMarinePoint(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
    List<String> params,
  );

  Future<Map<String, dynamic>> getTideExtremes(
    double lat,
    double lng,
    DateTime start,
    DateTime end,
  );
}

