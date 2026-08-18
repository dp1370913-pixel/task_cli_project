// Interface : toute classe qui l'implémente doit fournir toJson().
abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}
