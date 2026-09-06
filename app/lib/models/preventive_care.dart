class PreventiveCare {
  final int? id;
  final String category;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  PreventiveCare({
    this.id,
    required this.category,
    required this.title,
    required this.content,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PreventiveCare.fromMap(Map<String, dynamic> map) {
    return PreventiveCare(
      id: map['id'] as int?,
      category: map['category'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  PreventiveCare copyWith({
    int? id,
    String? category,
    String? title,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return PreventiveCare(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
