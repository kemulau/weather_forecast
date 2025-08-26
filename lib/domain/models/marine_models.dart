class MarineHour {
  final DateTime time;
  final double? waveHeight;
  final double? swellHeight;
  final double? swellPeriod;
  final double? windSpeed;
  final double? windDirection;
  final double? waterTemperature;

  const MarineHour({
    required this.time,
    this.waveHeight,
    this.swellHeight,
    this.swellPeriod,
    this.windSpeed,
    this.windDirection,
    this.waterTemperature,
  });

  factory MarineHour.fromJson(Map<String, dynamic> json) {
    double? _valueOf(String key) {
      final data = json[key];
      if (data is Map && data['sg'] != null) {
        final v = data['sg'];
        if (v is num) return v.toDouble();
      }
      return null;
    }

    return MarineHour(
      time: DateTime.parse(json['time']),
      waveHeight: _valueOf('waveHeight'),
      swellHeight: _valueOf('swellHeight'),
      swellPeriod: _valueOf('swellPeriod'),
      windSpeed: _valueOf('windSpeed'),
      windDirection: _valueOf('windDirection'),
      waterTemperature: _valueOf('waterTemperature'),
    );
  }
}

class TideExtreme {
  final DateTime time;
  final String type; // "low" or "high"
  final double? height;

  const TideExtreme({
    required this.time,
    required this.type,
    this.height,
  });

  factory TideExtreme.fromJson(Map<String, dynamic> json) {
    return TideExtreme(
      time: DateTime.parse(json['time']),
      type: json['type'],
      height: (json['height'] as num?)?.toDouble(),
    );
  }
}

