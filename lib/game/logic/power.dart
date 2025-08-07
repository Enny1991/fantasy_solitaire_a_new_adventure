
enum PowerType {
  drawCard,
  shuffle,
  reveal,
  remove,
  undo,
  freeze,
}

class Power {
  final String name;
  final String description;
  final int manaCost;
  final PowerType type;

  Power({
    required this.name,
    required this.description,
    required this.manaCost,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'manaCost': manaCost,
        'type': type.toString(), // Store enum as string
      };

  factory Power.fromJson(Map<String, dynamic> json) => Power(
        name: json['name'],
        description: json['description'],
        manaCost: json['manaCost'],
        type: PowerType.values.firstWhere(
            (e) => e.toString() == json['type']), // Convert string back to enum
      );
}
