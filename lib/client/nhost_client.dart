import 'package:cli/models/config.dart';
import 'package:nhost_dart/nhost_dart.dart';
import 'admin_http.dart';

NhostClient createNhostClient(ConfigData conf) {
  return NhostClient(
    httpClientOverride: AdminHTTPClient(adminToken: conf.adminToken),
    subdomain: Subdomain(subdomain: conf.subdomain, region: conf.region),
  );
}
