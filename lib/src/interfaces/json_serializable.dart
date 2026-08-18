/// Interface implemented by every model that can be persisted as JSON.
abstract interface class JsonSerializable {
  Map<String, dynamic> toJson();
}
