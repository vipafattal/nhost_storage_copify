class StorageFile {
  final String id;
  final String name;
  final String mimeType;

  StorageFile({
    required this.id,
    required this.name,
    required this.mimeType,
  });

  StorageFile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        mimeType = json['mimeType'],
        name = json['name'];

  Map<String, String> toJson() => {"id": id, "mimeType": mimeType, "name": name};
}
