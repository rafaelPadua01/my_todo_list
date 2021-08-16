class Todo {
  final int? id;
  final String description;
  final int? checked;
  final String date;
  final String time;
  final int fk_id_group;

  Todo({
    this.id,
    required this.description,
    this.checked,
    required this.date,
    required this.time,
    required this.fk_id_group,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'checked': checked,
      'date': date,
      'time': time,
      'fk_id_group': fk_id_group,
    };
  }

  @override
  String toString() {
    return 'Todo(id: $id, description: $description, checked: $checked, date: $date, time: $time, fk_id_group: $fk_id_group)';
  }
}
