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

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'icon': icon,
        'leaning': leaning,
      };

  factory AlterEgo.fromJson(Map<String, dynamic> json) => AlterEgo(
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? '•',
        leaning: (json['leaning'] as num).toDouble(),
      );
}
