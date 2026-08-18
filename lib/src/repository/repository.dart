// Interface générique : T sera remplacé par Task quand on l'utilise.
// Ça permet de définir les opérations CRUD une seule fois, peu importe
// le type d'objet stocké.
abstract class Repository<T> {
  void add(T item);
  List<T> getAll();
  T getById(String id);
  void update(T item);
  void delete(String id);
}
