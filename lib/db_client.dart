import 'dart:async';

import 'package:graphql/client.dart';
import 'package:nhost_dart/nhost_dart.dart';

import 'models/gql_query.dart';
import 'models/network_process.dart';
import 'models/storage_file.dart';

class DbClient {
  late GraphQLClient _client;

  DbClient(NhostClient nhost) {
    _client = createNhostGraphQLClient(nhost);
  }

  Future<NetworkProcess<T>> _query<T>({
    required GQLQuery gqlQueryBody,
    required T Function(dynamic data) transform,
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(gqlQueryBody.query),
          variables: gqlQueryBody.variables ?? {},
        ),
      );
      if (result.hasException) {
        return NetworkProcess.failed(result.exception);
      }
      final data = result.data;
      return NetworkProcess.succeeded(newData: transform(data));
    } on Exception catch (e) {
      return NetworkProcess.failed(e);
    }
  }

  Future<NetworkProcess<List<StorageFile>>> getAllDbFiles() async {
    final gqlQuery = GQLQuery(query: """
              query {
                files {
                  id
                  name
                  mimeType
                }
              }
    """);

    return await _query(
      gqlQueryBody: gqlQuery,
      transform: (data) =>
          (data['files'] as List).map((e) => StorageFile.fromJson(e)).toList(),
    );
  }
}
