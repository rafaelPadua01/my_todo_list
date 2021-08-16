class Groups {
  int? id;
  String name;
  String create_at;
  String? update_at;

  Groups({
    this.id,
    required this.name,
    required this.create_at,
    this.update_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'create_at': create_at,
      'update_at': update_at,
    };
  }

  @override
  String toString() {
    return 'Group(id: $id, name: $name, create_at: $create_at, update_at: $update_at)';
  }
}
