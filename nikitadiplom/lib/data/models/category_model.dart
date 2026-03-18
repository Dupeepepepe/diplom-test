class CategoryModel {
  final String id;
  final String name;
  final int icon;
  final int color;
  final String type; // 'income' or 'expense'

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  CategoryModel copyWith({
    String? name,
    int? icon,
    int? color,
    String? type,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as int,
      color: map['color'] as int,
      type: map['type'] as String,
    );
  }
}
