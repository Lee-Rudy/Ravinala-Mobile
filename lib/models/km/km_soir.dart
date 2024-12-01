class KMsoir {
  int? id;
  String depart;
  String fin;
  String nomVoiture;
  String datetimeSoir;

  KMsoir({
    this.id,
    required this.depart,
    required this.fin,
    required this.nomVoiture,
    required this.datetimeSoir,
  });

  Map<String, dynamic> toMap()
  {
    return
    {
      // 'id' : id,
      'depart': depart,
      'fin': fin,
      'nomVoiture' : nomVoiture,
      // 'datetime_soir': DateTime.parse(datetimeSoir).toUtc().toIso8601String(),
      'datetime_soir': datetimeSoir,
      // 'datetime_soir' : datetimeSoir != null
      //     ? DateTime.parse(datetimeSoir!).toIso8601String()
      //     : null,
    };
  }

  factory KMsoir.fromMap(Map<String, dynamic> map)
  {
    return KMsoir(
      id: map['id'],
      depart : map['depart'] ?? 'Inconnu',
      fin : map['fin'] ?? 'Inconnu',
      nomVoiture: map['nomVoiture'] ?? 'Inconnu',
      datetimeSoir : map['datetime_soir'],
    );
  }
}