import 'dart:convert';
import 'dart:typed_data';

import 'package:nhost_dart/nhost_dart.dart';

class Storage {
  late NhostStorageClient _client;

  Storage(NhostClient nhost) {
    _client = nhost.storage;
  }

  Future<String?> upload({
    required String fileId,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    final int uploadRetryCount = 0,
  }) async {
    try {
      final result = await _client.uploadBytes(
        fileName: fileName,
        fileId: fileId,
        mimeType: mimeType,
        fileContents: bytes,
      );
      print("Uploading $fileName success!");
      return result.id;
    } on ApiException catch (e) {
      final Map error = json.decode(e.body['error']['message']);
      final gqlError = error['graphqlErrors'];

      if (gqlError != null) {
        final String errorMessage = (gqlError as List).first['message'];
        if (e.statusCode == 400 &&
            errorMessage.contains("duplicate key value violates unique")) {
          return null;
        }
      }

      if (uploadRetryCount == 2) rethrow;
      await Future.delayed(Duration(seconds: 1 * uploadRetryCount));

      print(
        "Uploading $fileName failed with exception (${e.toString()}), retying ($uploadRetryCount) ... ",
      );

      await Future.delayed(Duration(seconds: 1 * uploadRetryCount));

      return upload(
        fileId: fileId,
        fileName: fileName,
        mimeType: mimeType,
        bytes: bytes,
        uploadRetryCount: uploadRetryCount + 1,
      );
    }
  }

  Future<Uint8List?> download(String fileId,
      [final int downloadRetry = 0]) async {
    try {
      final result = await _client.downloadFile(fileId);
      print("Download completed with ${result.statusCode}");
      return result.bodyBytes;
    } on ApiException catch (e) {
      //Means file doesn't exists
      if (e.statusCode == 500) return null;

      if (downloadRetry == 20) rethrow;
      await Future.delayed(Duration(seconds: 1 * downloadRetry));
      print(
        "Downloading $fileId failed with exception (${e.toString()}), retying ($downloadRetry) ... ",
      );
      return download(fileId, downloadRetry + 1);
    }
  }

  Future<void> delete(String fileId, [final int deleteRetryCount = 0]) async {
    try {
      print("Deleting file with id $fileId");
      await _client.delete(fileId);
      print("Deleted $fileId");
    } catch (e) {
      if (deleteRetryCount == 20) rethrow;
      print(
          "Deleting $fileId failed with exception (${e.toString()}), retying ($deleteRetryCount) ... ");
      delete(fileId, deleteRetryCount + 1);
    }
  }
}
