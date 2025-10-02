class AthleteDetail {
  final String fullName;
  final String course;
  final int age;
  final int shirtNumber;
  final String series;
  final String modalityName;
  final String gender;
  final List<AthleteStatistic> statistics;

  AthleteDetail({
    required this.fullName,
    required this.course,
    required this.age,
    required this.shirtNumber,
    required this.series,
    required this.modalityName,
    required this.gender,
    required this.statistics,
  });

  factory AthleteDetail.fromJson(Map<String, dynamic> json) {
    final statisticsJson = json['statistics'] as List<dynamic>?;
    final statistics = statisticsJson != null
        ? statisticsJson
              .map(
                (stat) =>
                    AthleteStatistic.fromJson(stat as Map<String, dynamic>),
              )
              .toList()
        : <AthleteStatistic>[];

    // Sort statistics by order
    statistics.sort((a, b) => a.order.compareTo(b.order));

    return AthleteDetail(
      fullName: json['full_name'] as String? ?? '',
      course: json['course'] as String? ?? '',
      age: int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      shirtNumber: json['shirt_number'] as int? ?? 0,
      series: json['series'] as String? ?? '',
      modalityName: json['name'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      statistics: statistics,
    );
  }

  String get modalityWithGender => '$modalityName $gender';
}

class AthleteStatistic {
  final String code;
  final String name;
  final int value;
  final int order;

  AthleteStatistic({
    required this.code,
    required this.name,
    required this.value,
    required this.order,
  });

  factory AthleteStatistic.fromJson(Map<String, dynamic> json) {
    return AthleteStatistic(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      value: json['value'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
    );
  }
}
