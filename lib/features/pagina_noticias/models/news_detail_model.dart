class NewsDetailModel {
  final String title;
  final String summary;
  final String body;
  final DateTime publishedAt;
  final String? sourceUrl;

  const NewsDetailModel({
    required this.title,
    required this.summary,
    required this.body,
    required this.publishedAt,
    this.sourceUrl,
  });

  factory NewsDetailModel.fromJson(Map<String, dynamic> json) {
    return NewsDetailModel(
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      body: json['body'] as String? ?? '',
      publishedAt: DateTime.parse(json['published_at'] as String),
      sourceUrl: json['source_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'body': body,
      'published_at': publishedAt.toIso8601String(),
      'source_url': sourceUrl,
    };
  }
}