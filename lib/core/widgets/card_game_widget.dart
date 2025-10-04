import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:interufmt/core/theme/app_icons.dart';
import 'package:interufmt/core/widgets/row_2team_stats_widget.dart';
import 'package:interufmt/core/widgets/row_multi_teams_logos_widget.dart';
import 'package:interufmt/features/users/games/game_detail_page.dart';
import 'package:interufmt/features/users/games/tournament_game_detail_page.dart';

class CardGame extends StatelessWidget {
  final String status;
  final String statusDisplayText;
  final String startTimeDateFormatted;
  final String gameIcon;
  final String modalityPhase;
  final String? venueName;
  final String gameId;
  final String modalityId;
  final String series;
  final bool isTwoTeamGame;
  final bool isMultiTeamGame;
  final String? teamALogo;
  final String? teamBLogo;
  final int? scoreA;
  final int? scoreB;
  final int? displayScoreA;
  final int? displayScoreB;
  final List<String>? multiTeamLogos;
  final VoidCallback? onTap;
  const CardGame({
    super.key,
    required this.status,
    required this.statusDisplayText,
    required this.startTimeDateFormatted,
    required this.gameIcon,
    required this.modalityPhase,
    this.venueName,
    required this.gameId,
    required this.modalityId,
    required this.series,
    required this.isTwoTeamGame,
    required this.isMultiTeamGame,
    this.teamALogo,
    this.teamBLogo,
    this.scoreA,
    this.scoreB,
    this.displayScoreA,
    this.displayScoreB,
    this.multiTeamLogos,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: _getStatusColor(status), width: 6),
          ),
          borderRadius: BorderRadius.circular(6),
        ),

        child: Card(
          color: AppColors.white,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              if (isTwoTeamGame) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TournamentGameDetailPage(gameId: gameId),
                  ),
                );
              } else if (isMultiTeamGame) {
                final modalityName = modalityPhase.split(' - ').first;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameDetailPage(
                      modalityId: modalityId,
                      modalityName: modalityName,
                      series: series,
                    ),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusDisplayText,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _RowIconLabel(
                    AppIcons.icClock,
                    startTimeDateFormatted,
                    isBold: true,
                  ),
                  const SizedBox(height: 6),

                  _RowIconLabel(gameIcon, modalityPhase),

                  if (venueName != null) ...[
                    const SizedBox(height: 6),
                    _RowIconLabel(AppIcons.icLocation, venueName!),
                  ],
                  const SizedBox(height: 6),

                  if (isTwoTeamGame)
                    Row2teamStatsWidget(
                      teamALogo: teamALogo,
                      teamBLogo: teamBLogo,
                      scoreA: scoreA,
                      scoreB: scoreB,
                      displayScoreA: displayScoreA,
                      displayScoreB: displayScoreB,
                    )
                  else if (isMultiTeamGame)
                    RowMultiTeamsLogosWidget(logos: multiTeamLogos!)
                  else
                    _buildUnknownGameContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnknownGameContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.help_outline, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            'Informações dos participantes não disponíveis',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppColors.error;
      case 'inprogress':
      case 'in_progress':
        return AppColors.warning;
      case 'finished':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }
}

class _RowIconLabel extends StatelessWidget {
  final String icon;
  final String label;
  final bool isBold;
  const _RowIconLabel(this.icon, this.label, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            AppColors.primaryText,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
