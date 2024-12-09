import 'package:flutter/material.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/models/pointage/pointage_ramassage/pointage_ramassage.dart';
import 'package:transportflutter/models/pointage/pointage_imprevu/pointage_imprevu.dart';
import 'package:intl/intl.dart';
import 'package:transportflutter/models/km/km_matin.dart';

class ArchiveScreenRamassage extends StatefulWidget {
  @override
  _ArchiveScreenRamassageState createState() => _ArchiveScreenRamassageState();
}

class _ArchiveScreenRamassageState extends State<ArchiveScreenRamassage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  late Future<Map<String, List<dynamic>>> _archivesFuture;

  @override
  void initState() {
    super.initState();
    _archivesFuture = fetchArchives();
  }

  Future<Map<String, List<dynamic>>> fetchArchives() async {
    final db = await dbHelper.database;

    // Récupération des données de pointage_ramassage
    final prRecords = await db.query('pointage_ramassage');
    final List<PointageRamassage> pointageRamassageList =
        prRecords.map((map) => PointageRamassage.fromMap(map)).toList();

    // Récupération des données de pointage_usagers_imprevu
    final piRecords = await db.query('pointage_usagers_imprevu');
    final List<PointageImprevu> pointageImprevuList =
        piRecords.map((map) => PointageImprevu.fromMap(map)).toList();

    // Récupération des données du bouton (horaires de départ et d'arrivée + motif)
    final btnRecords = await db.query('btn');
    final List<Map<String, dynamic>> btnList = btnRecords.toList();

    // Récupération des données de km_matin
    final kmMatinRecords = await db.query('km_matin');
    final List<KMmatin> kmMatinList =
        kmMatinRecords.map((map) => KMmatin.fromMap(map)).toList();

    // Groupement par date
    Map<String, List<dynamic>> archivesMap = {};

    // Regrouper km_matin par date
    for (var kmRecord in kmMatinList) {
      String dateKey = 'Inconnue';
      if (kmRecord.datetimeMatin.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(kmRecord.datetimeMatin);
          dateKey = DateFormat('yyyy-MM-dd').format(dt);
        } catch (e) {
          // Gérer les erreurs de parsing si nécessaire
        }
      }

      if (!archivesMap.containsKey(dateKey)) {
        archivesMap[dateKey] = [];
      }
      archivesMap[dateKey]!.add(kmRecord);
    }

    // Regrouper pointage_ramassage par date
    for (var record in pointageRamassageList) {
      String dateKey = 'Inconnue';
      if (record.datetimeRamassage.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(record.datetimeRamassage);
          dateKey = DateFormat('yyyy-MM-dd').format(dt);
        } catch (e) {
          // Gérer les erreurs de parsing si nécessaire
        }
      }

      if (!archivesMap.containsKey(dateKey)) {
        archivesMap[dateKey] = [];
      }
      archivesMap[dateKey]!.add(record);
    }

    // Regrouper pointage_imprevu par date
    for (var record in pointageImprevuList) {
      String dateKey = 'Inconnue';
      if (record.datetimeImprevu.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(record.datetimeImprevu);
          dateKey = DateFormat('yyyy-MM-dd').format(dt);
        } catch (e) {
          // Gérer les erreurs de parsing si nécessaire
        }
      }

      if (!archivesMap.containsKey(dateKey)) {
        archivesMap[dateKey] = [];
      }
      archivesMap[dateKey]!.add(record);
    }

    // Regrouper les enregistrements du bouton par date
    for (var btnRecord in btnList) {
      final datetimeDepart = btnRecord['datetime_depart'] as String?;
      final datetimeArrivee = btnRecord['datetime_arrivee'] as String?;

      String dateKey = 'Inconnue';
      if (datetimeDepart != null && datetimeDepart.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(datetimeDepart);
          dateKey = DateFormat('yyyy-MM-dd').format(dt);
        } catch (e) {
          // Gérer les erreurs de parsing si nécessaire
        }
      } else if (datetimeArrivee != null && datetimeArrivee.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(datetimeArrivee);
          dateKey = DateFormat('yyyy-MM-dd').format(dt);
        } catch (e) {
          // Gérer les erreurs de parsing si nécessaire
        }
      }

      if (!archivesMap.containsKey(dateKey)) {
        archivesMap[dateKey] = [];
      }
      archivesMap[dateKey]!.add(btnRecord);
    }

    return archivesMap;
  }

  // Méthode pour construire les éléments de la liste pour PointageRamassage
  Widget _buildRamassageListTile(PointageRamassage pointage) {
    final statusText = pointage.estPresent == 1 ? 'Présent' : 'Absent';
    final statusColor = pointage.estPresent == 1 ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: pointage.estPresent == 1 ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Text(
            pointage.estPresent == 1 ? 'P' : 'A',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${pointage.nomUsager} - ${pointage.matricule}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Car: ${pointage.nomVoiture}'),
            if (pointage.estPresent == 1 &&
                pointage.datetimeRamassage.isNotEmpty) ...[
              Text(
                  'Date de pointage: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(pointage.datetimeRamassage))}'),
              Text(
                  'Heure de pointage: ${DateFormat('HH:mm:ss').format(DateTime.parse(pointage.datetimeRamassage))}'),
            ],
            if (pointage.estPresent == 0 &&
                pointage.datetimeRamassage.isNotEmpty) ...[
              Text(
                  'Date d\'absence: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(pointage.datetimeRamassage))}'),
            ],
          ],
        ),
        trailing: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Méthode pour construire les éléments de la liste pour PointageImprevu
  Widget _buildImprevuListTile(PointageImprevu imprevu) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text(
            'I',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${imprevu.matricule}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Car: ${imprevu.nomVoiture}'),
            if (imprevu.datetimeImprevu.isNotEmpty) ...[
              Text('Nom: ${imprevu.nom}'),
              Text(
                  'Date imprévu: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(imprevu.datetimeImprevu))}'),
              Text(
                  'Heure imprévu: ${DateFormat('HH:mm:ss').format(DateTime.parse(imprevu.datetimeImprevu))}'),
            ],
          ],
        ),
        trailing: Text(
          'Imprévu',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Méthode pour construire les éléments de la liste pour KMmatin
  Widget _buildKMmatinListTile(KMmatin kmMatin) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            'KM',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          'Kilométrage Matin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KM Départ: ${kmMatin.depart}'),
            Text('KM Fin: ${kmMatin.fin}'),
            Text('Car: ${kmMatin.nomVoiture}'),
            if (kmMatin.datetimeMatin.isNotEmpty) ...[
              Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(kmMatin.datetimeMatin))}'),
              Text(
                  'Heure: ${DateFormat('HH:mm:ss').format(DateTime.parse(kmMatin.datetimeMatin))}'),
            ],
          ],
        ),
        trailing: Text(
          'KM Matin',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Méthode pour construire les éléments de la liste pour les informations de déplacement (btnRecords)
  Widget _buildBtnListTile(Map<String, dynamic> btnRecord) {
    final datetimeDepart = btnRecord['datetime_depart'];
    final datetimeArrivee = btnRecord['datetime_arrivee'];
    final nomCar = btnRecord['nomVoiture'] ?? 'Inconnu';
    final motif = (btnRecord['motif'] == null || (btnRecord['motif'] as String).trim().isEmpty)
        ? 'rien à signaler'
        : btnRecord['motif'];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.tealAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal),
      ),
      child: ListTile(
        leading: Icon(Icons.directions_car, color: Colors.teal),
        title: Text(
          'Car: $nomCar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Motif: $motif'),
            if (datetimeDepart != null && datetimeDepart.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Départ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(datetimeDepart))}'),
              Text(
                  'Heure: ${DateFormat('HH:mm:ss').format(DateTime.parse(datetimeDepart))}'),
            ],
            if (datetimeArrivee != null && datetimeArrivee.isNotEmpty) ...[
              SizedBox(height: 8), // Espace entre Départ et Arrivée
              Text(
                'Arrivée:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(datetimeArrivee))}'),
              Text(
                  'Heure: ${DateFormat('HH:mm:ss').format(DateTime.parse(datetimeArrivee))}'),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Archives du Ramassage',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF45B48E),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _archivesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFF45B48E)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune archive disponible.'));
          } else {
            final archivesData = snapshot.data!;
            // Trie les dates en ordre décroissant
            final sortedDates = archivesData.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return ListView.builder(
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDates[index];
                final dateRecords = archivesData[dateKey]!;

                // Séparation des enregistrements
                final pointageRamassageRecords = dateRecords
                    .where((record) => record is PointageRamassage)
                    .toList();
                final pointageImprevuRecords = dateRecords
                    .where((record) => record is PointageImprevu)
                    .toList();
                final btnRecords = dateRecords
                    .where((record) => record is Map<String, dynamic>)
                    .toList();
                final kmMatinRecords =
                    dateRecords.where((record) => record is KMmatin).toList();

                // Combiner les enregistrements pointage_ramassage et pointage_imprevu
                List<dynamic> combinedPointageRecords = [];
                combinedPointageRecords.addAll(pointageRamassageRecords);
                combinedPointageRecords.addAll(pointageImprevuRecords);

                // Trier les enregistrements combinés par matricule
                combinedPointageRecords.sort((a, b) {
                  String aMatricule;
                  String bMatricule;

                  if (a is PointageRamassage) {
                    aMatricule = a.matricule;
                  } else if (a is PointageImprevu) {
                    aMatricule = a.matricule;
                  } else {
                    aMatricule = '';
                  }

                  if (b is PointageRamassage) {
                    bMatricule = b.matricule;
                  } else if (b is PointageImprevu) {
                    bMatricule = b.matricule;
                  } else {
                    bMatricule = '';
                  }

                  return aMatricule.compareTo(bMatricule);
                });

                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      dateKey != 'Inconnue' ? 'Date: $dateKey' : 'Date inconnue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF45B48E),
                      ),
                    ),
                    children: [
                      // Affichage des informations de déplacement (btnRecords et kmMatinRecords)
                      if (btnRecords.isNotEmpty || kmMatinRecords.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Informations de déplacement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF45B48E),
                            ),
                          ),
                        ),
                        // Affichage des enregistrements de déplacement
                        ...btnRecords.map((btnRecord) {
                          return _buildBtnListTile(btnRecord);
                        }).toList(),
                        // Affichage des enregistrements de kilométrage
                        ...kmMatinRecords.map((kmRecord) {
                          return _buildKMmatinListTile(kmRecord as KMmatin);
                        }).toList(),
                      ],
                      // Affichage des enregistrements de pointage combinés (présents, absents, imprévus)
                      if (combinedPointageRecords.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            'Pointages',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF45B48E),
                            ),
                          ),
                        ),
                        ...combinedPointageRecords.map((record) {
                          if (record is PointageRamassage) {
                            return _buildRamassageListTile(record);
                          } else if (record is PointageImprevu) {
                            return _buildImprevuListTile(record);
                          } else {
                            return SizedBox.shrink();
                          }
                        }).toList(),
                      ],
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
