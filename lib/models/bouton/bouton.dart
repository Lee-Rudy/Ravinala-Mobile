class CarButton {
  int? id; // Conserver pour usage local
  String nomVoiture;
  String datetimeDepart; // Date en String
  String datetimeArrivee; // Date en String

  CarButton({
    this.id,
    required this.nomVoiture,
    required this.datetimeDepart,
    required this.datetimeArrivee,
  });

  Map<String, dynamic> toMap() {
    return {
      'NomVoiture': nomVoiture,            // PascalCase
      'DatetimeDepart': datetimeDepart,    // PascalCase
      'DatetimeArrivee': datetimeArrivee,  // PascalCase
    };
  }

  factory CarButton.fromMap(Map<String, dynamic> map) {
    print('Récupération de CarButton depuis la base de données : $map');
    return CarButton(
      id: map['id'],
      nomVoiture: map['NomVoiture'] ?? 'Inconnu',
      datetimeDepart: map['DatetimeDepart'] ?? '',
      datetimeArrivee: map['DatetimeArrivee'] ?? '',
    );
  }
}
