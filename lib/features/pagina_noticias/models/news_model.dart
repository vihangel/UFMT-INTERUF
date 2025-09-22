class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;

  const NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'image_url': imageUrl,
    };
  }
}
