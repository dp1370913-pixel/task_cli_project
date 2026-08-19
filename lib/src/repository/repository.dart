// Interface générique : T sera remplacé par Task quand on l'utilise.
// Ça permet de définir les opérations CRUD une seule fois, peu importe
// le type d'objet stocké. Les opérations sont asynchrones car une
// implémentation persiste typiquement sur disque (I/O non bloquant).
abstract class Repository<T> {
  Future<void> add(T item);
  Future<List<T>> getAll();
  Future<T> getById(String id);
  Future<void> update(T item);
  Future<void> delete(String id);
}
