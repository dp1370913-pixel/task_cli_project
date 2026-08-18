/// A generic CRUD contract, reusable for any entity identified by a
/// [String] id.
abstract interface class Repository<T> {
  void add(T item);
  List<T> getAll();
  T getById(String id);
  void update(T item);
  void delete(String id);
}
