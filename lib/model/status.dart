import 'dart:convert';

class Status {
  double temperature = 0;
  double humidity = 0;
  double pm1p0 = 0;
  double pm2p5 = 0;
  double pm10 = 0;
  double gas = 0;
  double brightness = 0;
  double fan = 0;
  double window = 0;
  String timesAgo = "초기화중...";

  Status() {
    temperature = 0;
    humidity = 0;
    pm1p0 = 0;
    pm2p5 = 0;
    pm10 = 0;
    gas = 0;
    brightness = 0;
    fan = 0;
    window = 0;
    timesAgo = "초기화중...";
  }

  Status.fromJson(String data) {
    Map response = json.decode(data);

    humidity = response['humidity'] ?? 0;
    temperature = response['temperature'] ?? 0;
    pm1p0 = response['pm1p0'] ?? 0;
    pm2p5 = response['pm2p5'] ?? 0;
    pm10 = response['pm10'] ?? 0;
    gas = response['gas'] ?? 0;
    brightness = response['brightness'] ?? 0;
    fan = response['fan'] ?? 0;
    window = response['window'] ?? 0;
    timesAgo = response['times_ago'] ?? "에러";
  }
}
