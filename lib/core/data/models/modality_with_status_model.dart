// lib/core/data/models/modality_with_status_model.dart

import 'package:interufmt/core/theme/app_icons.dart';

class ModalityWithStatus {
  final String id;
  final String name;
  final String gender;
  final String? icon;
  final String series;
  final String status;

  ModalityWithStatus({
    required this.id,
    required this.name,
    required this.gender,
    this.icon,
    required this.series,
    required this.status,
  });

  factory ModalityWithStatus.fromJson(Map<String, dynamic> json) {
    return ModalityWithStatus(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      icon: json['icon'] as String?,
      series: json['series'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'icon': icon,
      'series': series,
      'status': status,
    };
  }

  // Helper method to get the correct asset path for modality icons
  String get assetPath =>
      icon != null ? 'assets/icons/$icon' : 'assets/icons/ic_sports.svg';

  // Helper method to determine modality status based on game statuses
  static String getModalityStatus(List<String> gameStatuses) {
    if (gameStatuses.isEmpty) {
      return 'Não iniciada';
    }

    final uniqueStatuses = gameStatuses.toSet();

    if (uniqueStatuses.length == 1) {
      final status = uniqueStatuses.first;
      switch (status) {
        case 'scheduled':
          return 'Não iniciada';
        case 'finished':
          return 'Finalizada';
        case 'inProgress':
          return 'Em disputa';
        default:
          return 'Em disputa';
      }
    } else {
      // Mixed statuses means it's in progress
      return 'Em disputa';
    }
  }
}

// Model for aggregated modality data
class ModalityAggregated {
  final String id;
  final String name;
  final String gender;
  final String? icon;
  final String series;
  final List<String> gameStatuses;
  final String modalityStatus;

  ModalityAggregated({
    required this.id,
    required this.name,
    required this.gender,
    this.icon,
    required this.series,
    required this.gameStatuses,
    required this.modalityStatus,
  });

  factory ModalityAggregated.fromModalityWithStatusList(
    List<ModalityWithStatus> modalities,
  ) {
    if (modalities.isEmpty) {
      throw ArgumentError('Modalities list cannot be empty');
    }

    final first = modalities.first;
    final gameStatuses = modalities.map((m) => m.status).toList();
    final modalityStatus = ModalityWithStatus.getModalityStatus(gameStatuses);

    return ModalityAggregated(
      id: first.id,
      name: first.name,
      gender: first.gender,
      icon: first.icon,
      series: first.series,
      gameStatuses: gameStatuses,
      modalityStatus: modalityStatus,
    );
  }

  String get assetPath => AppIcons.getGameIcon(name);
}
