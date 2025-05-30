class Note {
  final int? id; 
  final String title;
  final String content;
  final String? imagePath; 
  final DateTime createdTime;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.imagePath,
    required this.createdTime,
  });

  // Konversi Note object ke Map object untuk disimpan ke DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'createdTime':
          createdTime
              .toIso8601String(), // Simpan DateTime sebagai String ISO8601
    };
  }

  // Konversi Map object dari DB ke Note object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      imagePath: map['imagePath'] as String?,
      createdTime: DateTime.parse(
        map['createdTime'] as String,
      ), // Parse String ke DateTime
    );
  }

  // Helper untuk debugging
  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, imagePath: $imagePath, createdTime: $createdTime}';
  }
}
