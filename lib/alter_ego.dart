class AlterEgo {
  final String name;
  final String description;
  final String icon;
  final double leaning;

  AlterEgo({
    required this.name,
    required this.description,
    required this.icon,
    required this.leaning,
  });

  // Serialization methods
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'icon': icon,
        'leaning': leaning,
      };

  factory AlterEgo.fromJson(Map<String, dynamic> json) => AlterEgo(
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        leaning: json['leaning'],
      );
}
