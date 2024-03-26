import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as clients;
class AdminHTTPClient extends clients.IOClient {
  final String adminToken;

  AdminHTTPClient({required this.adminToken});

  @override
  Future<clients.IOStreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll({"x-hasura-admin-secret": adminToken});
    return super.send(request);
  }
}