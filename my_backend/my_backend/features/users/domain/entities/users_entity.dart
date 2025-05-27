class UsersEntity {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  UsersEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsersEntity.fromJson(Map<String, dynamic> json) {
    return UsersEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() => 'UsersEntity(id: $id)';
}
