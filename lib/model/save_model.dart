class Save {
  final int? id;
  final int fk_id_todo;
  final int fk_id_group;
  final String fk_description;
  final int fk_checked;
  final String fk_date;
  final String fk_time;
  final String create_at;
  final String? update_at;

  Save(
      {this.id,
      required this.fk_id_todo,
      required this.fk_id_group,
      required this.fk_description,
      required this.fk_checked,
      required this.fk_date,
      required this.fk_time,
      required this.create_at,
      this.update_at});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fk_id_todo': fk_id_todo,
      'fk_id_group': fk_id_group,
      'fk_description': fk_description,
      'fk_checked': fk_checked,
      'fk_date': fk_date,
      'fk_time': fk_time,
      'create_at': create_at,
      'update_at': update_at,
    };
  }

  @override
  String toString() {
    return 'Save(id: $id, fk_id_todo: $fk_id_todo, fk_id_group: $fk_id_group, fk_checked: $fk_checked, fk_date: $fk_date, fk_time: $fk_time)';
  }
}
