class AppIcons {
  // Social
  static const String icInstagram = 'assets/icons/ic_instagram.svg';
  static const String icTwitter = 'assets/icons/ic_twitter.svg';
  static const String icYoutube = 'assets/icons/ic_youtube.svg';
  static const String icGoogle = 'assets/icons/ic_google.svg';
  static const String icApple = 'assets/icons/ic_apple.svg';

  // Sports
  static const String icSwimming = 'assets/icons/ic_ swimming.svg';
  static const String icAthletics = 'assets/icons/ic_athletics.svg';
  static const String icBasketball = 'assets/icons/ic_basketball.svg';
  static const String icChess = 'assets/icons/ic_chess.svg';
  static const String icHandball = 'assets/icons/ic_handball.svg';
  static const String icHorse = 'assets/icons/ic_horse.svg';
  static const String icSoccer = 'assets/icons/ic_soccer.svg';
  static const String icTableTenis = 'assets/icons/ic_table_tenis.svg';
  static const String icVolley = 'assets/icons/ic_volley.svg';

  // UI
  static const String icArrowRight = 'assets/icons/ic_arrow_right.svg';
  static const String icCalendar = 'assets/icons/ic_calendar.svg';
  static const String icClock = 'assets/icons/ic_clock.svg';
  static const String icHome = 'assets/icons/ic_home.svg';
  static const String icLocation = 'assets/icons/ic_location.svg';
  static const String icMedal = 'assets/icons/ic_medal.svg';
  static const String icRefresh = 'assets/icons/ic_refresh.svg';
  static const String icSearchPeople = 'assets/icons/ic_search_people.svg';
  static const String icSettings = 'assets/icons/ic_settings.svg';
  static const String icStatsSquare = 'assets/icons/ic_stats_square.svg';
  static const String icStats = 'assets/icons/ic_stats.svg';
  static const String icTrophy = 'assets/icons/ic_trophy.svg';

  static String getGameIcon(String modality) {
    final modalityLowerCase = modality.toLowerCase();
    if (modalityLowerCase.contains('natação')) {
      return AppIcons.icSwimming;
    } else if (modalityLowerCase.contains('futsal')) {
      return AppIcons.icSoccer;
    } else if (modalityLowerCase.contains('basquete')) {
      return AppIcons.icBasketball;
    } else if (modalityLowerCase.contains('atletismo') ||
        modalityLowerCase.contains('corrida')) {
      return AppIcons.icAthletics;
    } else if (modalityLowerCase.contains('xadrez')) {
      return AppIcons.icChess;
    } else if (modalityLowerCase.contains('vôlei')) {
      return AppIcons.icVolley;
    } else if (modalityLowerCase.contains('handebol')) {
      return AppIcons.icHandball;
    } else {
      return AppIcons.icTrophy;
    }
  }
}
