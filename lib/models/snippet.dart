import 'dart:convert';

class Snippet {
  final String id;
  String title;
  String code;
  String language;
  List<String> tags;
  bool isSaved;
  final DateTime createdAt;
  DateTime updatedAt;
  int copyCount;

  Snippet({
    required this.id,
    required this.title,
    required this.code,
    required this.language,
    required this.tags,
    this.isSaved = false,
    required this.createdAt,
    required this.updatedAt,
    this.copyCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'code': code,
        'language': language,
        'tags': tags,
        'isSaved': isSaved,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'copyCount': copyCount,
      };

  factory Snippet.fromJson(Map<String, dynamic> json) => Snippet(
        id: json['id'],
        title: json['title'],
        code: json['code'],
        language: json['language'],
        tags: List<String>.from(json['tags']),
        isSaved: json['isSaved'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        copyCount: json['copyCount'] ?? 0,
      );

  Snippet copyWith({
    String? title,
    String? code,
    String? language,
    List<String>? tags,
    bool? isSaved,
    DateTime? updatedAt,
    int? copyCount,
  }) =>
      Snippet(
        id: id,
        title: title ?? this.title,
        code: code ?? this.code,
        language: language ?? this.language,
        tags: tags ?? this.tags,
        isSaved: isSaved ?? this.isSaved,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        copyCount: copyCount ?? this.copyCount,
      );

  String get timeAgo {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
  }
}
