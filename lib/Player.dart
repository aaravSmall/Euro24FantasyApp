class Player {
  final String playerName;
  final String position;
  final String goals;
  final String assists;
  final String cleanSheets;
  final String points;
  final String price;
  final String redCards;
  final String team;
  final String yellowCards;

  Player({
    required this.playerName,
    required this.position,
    required this.goals,
    required this.assists,
    required this.cleanSheets,
    required this.points,
    required this.price,
    required this.redCards,
    required this.team,
    required this.yellowCards,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'position': position,
      'goals': goals,
      'assists': assists,
      'cleanSheets': cleanSheets,
      'points': points,
      'price': price,
      'redCards': redCards,
      'team': team,
      'yellowCards': yellowCards,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerName: json['playerName'],
      position: json['position'],
      goals: json['goals'],
      assists: json['assists'],
      cleanSheets: json['cleanSheets'],
      points: json['points'],
      price: json['price'],
      redCards: json['redCards'],
      team: json['team'],
      yellowCards: json['yellowCards'],
    );
  }
}
