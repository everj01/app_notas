class Note {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final int color;
  final DateTime updatedAt;

  const Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.color,
    required this.updatedAt,
  });

  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? color,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'color': color,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      color: map['color'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
