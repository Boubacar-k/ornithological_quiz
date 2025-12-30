class QuizDefinition {
  final String filePath;
  final String category;
  final String name;
  final List<String> directories;
  final List<String> birdKeys;

  QuizDefinition({
    required this.filePath,
    required this.category,
    required this.name,
    required this.directories,
    this.birdKeys = const [],
  });

  factory QuizDefinition.fromJson(Map<String, dynamic> json) {
    return QuizDefinition(
      filePath: json['filePath'],
      category: json['category'],
      name: json['name'],
      directories: List<String>.from(json['directories']),
      birdKeys: List<String>.from(json['birdKeys'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'category': category,
      'name': name,
      'directories': directories,
      'birdKeys': birdKeys,
    };
  }

  String get displayName {
    if (category == 'NOCAT') {
      return name;
    }
    return '$category: $name';
  }

  bool get isValid => directories.isNotEmpty;

  @override
  String toString() {
    return 'QuizDefinition{category: $category, name: $name, directories: ${directories.length}}';
  }
}