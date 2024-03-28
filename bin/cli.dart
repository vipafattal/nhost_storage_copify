import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cli/client/nhost_client.dart';
import 'package:cli/db_client.dart';
import 'package:cli/models/config.dart';
import 'package:cli/models/storage_file.dart';
import 'package:cli/storage_client.dart';

final downloadFails = <StorageFile>[];
final uploadFails = <StorageFile>[];

void main() async {
  final config = Config.getConfig();

  final sourceClient = createNhostClient(config.source);
  final targetClient = createNhostClient(config.target);

  final sourceStorage = Storage(sourceClient);
  final targetStorage = Storage(targetClient);
  final sourceDb = DbClient(sourceClient);

  final dbFileProcess = await sourceDb.getAllDbFiles();
  final dbFiles = dbFileProcess.data!;
  final numberOfFiles = dbFiles.length;

  for (int i = 0; i < numberOfFiles; i++) {
    final file = dbFiles[i];

    print("Downloading file number ${i + 1} out of $numberOfFiles");
    final bytes = await sourceStorage.download(file.id);

    if (bytes == null) {
      downloadFails.add(file);
      continue;
    }

    //TODO optional argument to enable/disable write file to local machine.
    saveIntoUserMachine(file, bytes);

    print("Uploading file number ${i + 1} out of $numberOfFiles");
    final newUploadedFile = await targetStorage.upload(
      fileId: file.id,
      fileName: file.name,
      mimeType: file.mimeType,
      bytes: bytes,
    );
    if (newUploadedFile == null) uploadFails.add(file);
    print(
        "=========================================================================");
  }

  reportLogs(numberOfFiles);
}

void saveIntoUserMachine(StorageFile file, Uint8List bytes) {
  RandomAccessFile outputFile = File(
    "resources/output/${file.name}",
  ).openSync(mode: FileMode.write);

  outputFile.writeFromSync(bytes);
}

void reportLogs(int numberOfFiles) {
  print(
      "===========================================================================");
  final numberOfDownloadFails = downloadFails.length;
  final numberOfUploadFails = uploadFails.length;

  print(
    "total download fails:$numberOfDownloadFails of $numberOfFiles. (because file doesn't exits in CDN storage)",
  );
  if (numberOfUploadFails == 0 && numberOfDownloadFails == 0) {
    print("All files uploaded to the target successfully");
    return;
  }

  if (numberOfDownloadFails > 0) {
    writeLogs(filesToLog: downloadFails, fileName: "download_failed_files_log");
    print(
      "total download fails:$numberOfDownloadFails of $numberOfFiles. (because file doesn't exits in CDN storage)",
    );
  }
  if (numberOfUploadFails > 0) {
    writeLogs(filesToLog: uploadFails, fileName: "upload_failed_files_log");
    print(
      "total upload fails:$numberOfUploadFails of $numberOfFiles. (because file already exits in CDN storage)",
    );
  }
  print("See failed files in the logs at resources/logs/");
}

void writeLogs({
  required List<StorageFile> filesToLog,
  required String fileName,
}) {
  //TODO save exception with logs
  final logs = json.encode(filesToLog.map((e) => e.toJson()).toList());
  final logFile =
      File("resources/logs/$fileName.json").openSync(mode: FileMode.write);
  logFile.writeStringSync(logs);
}
