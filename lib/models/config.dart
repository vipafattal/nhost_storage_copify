import 'dart:convert';
import 'dart:io';

class Config {
  final ConfigData target;
  final ConfigData source;

  Config.fromJson(Map<String, dynamic> json)
      : target = ConfigData.fromJson(json['target']),
        source = ConfigData.fromJson(json['source']);

  static Config getConfig() {
    const String configFilePath = 'resources/config.json';

    final config = File(configFilePath).readAsStringSync();
    final jsonConfig = json.decode(config);
    return Config.fromJson(jsonConfig);
  }
}

class ConfigData {
  final String adminToken;
  final String subdomain;
  final String region;

  ConfigData.fromJson(Map<String, dynamic> json)
      : adminToken = json['admin_token'],
        subdomain = json['subdomain'],
        region = json['region'];
}
