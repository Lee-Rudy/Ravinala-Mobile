import 'package:flutter/material.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/models/pointage/pointage_depot/pointage_depot.dart';
import 'package:transportflutter/models/pointage/pointage_imprevu/pointage_imprevu.dart';
import 'package:intl/intl.dart';
import 'package:transportflutter/models/km/km_soir.dart';

class ArchiveScreenDepot extends StatefulWidget {
  @override
  _ArchiveScreenDepotState createState() => _ArchiveScreenDepotState();
}

class _ArchiveScreenDepotState extends State<ArchiveScreenDepot> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  late Future<Map<String, List<dynamic>>> _archivesFuture;

  @override
  void initState() {
    super.initState();
    _archivesFuture = fetchArchives();
  }

  Future<Map<String, List<dynamic>>> fetchArchives() async {
    final db = await dbHelper.database;

    // Récupération des données de pointage_depot
    final pdRecords = await db.query('pointage_depot');
    final List<PointageDepot> pointageDepotList =
        pdRecords.map((map) => PointageDepot.fromMap(map)).toList();

    // Récupération des données de pointage_usagers_imprevu
    final piRecords = await db.query('pointage_usagers_imprevu');
    final List<PointageImprevu> pointageImprevuList =
        piRecords.map((map) => PointageImprevu.fromMap(map)).toList();

    // Récupération des données du bouton (horaires de départ et d'arrivée)
    final btnRecords = await db.query('btn');
    final List<Map<String, dynamic>> btnList = btnRecords.toList();

    // Récupération des données de km_soir
    final kmSoirRecords = await db.query('km_soir');
    final List<KMsoir> kmSoirList =
        kmSoirRecords.map((map) => KMsoir.fromMap(map)).toList();

    // Groupement par date
    Map<String, List<dynamic>> archivesMap = {};

    // Regrouper km_soir par date
    for (var kmRecord in kmSoirList) {
      String dateKey = 'Inconnue';
      if (kmRecord.datetimeSoir.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(kmRecord.datetimeSoir);
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

    // Regrouper pointage_depot par date
    for (var record in pointageDepotList) {
      String dateKey = 'Inconnue';
      if (record.datetimeDepot.isNotEmpty) {
        try {
          DateTime dt = DateTime.parse(record.datetimeDepot);
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

  // Méthode pour construire les éléments de la liste pour PointageDepot
  Widget _buildDepotListTile(PointageDepot pointage) {
    final statusText = pointage.estPresent == 1 ? 'Présent' : 'Absent';
    final statusColor = pointage.estPresent == 1 ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color:
            pointage.estPresent == 1 ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
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
            if (pointage.estPresent == 1 && pointage.datetimeDepot.isNotEmpty)
              ...[
                Text(
                    'Date de pointage: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(pointage.datetimeDepot))}'),
                Text(
                    'Heure de pointage: ${DateFormat('HH:mm:ss').format(DateTime.parse(pointage.datetimeDepot))}'),
              ],
            if (pointage.estPresent == 0 && pointage.datetimeDepot.isNotEmpty)
              ...[
                Text(
                    'Date d\'absence: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(pointage.datetimeDepot))}'),
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
            if (imprevu.datetimeImprevu.isNotEmpty)
              ...[
                Text(
                    'Nom: ${imprevu.nom}'),
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

  // Méthode pour construire les éléments de la liste pour KMsoir
  Widget _buildKMsoirListTile(KMsoir kmSoir) {
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
          'Kilométrage Soir',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KM Départ: ${kmSoir.depart}'),
            Text('KM Fin: ${kmSoir.fin}'),
            Text('Car: ${kmSoir.nomVoiture}'),
            if (kmSoir.datetimeSoir.isNotEmpty)
              ...[
                Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(kmSoir.datetimeSoir))}'),
                Text(
                    'Heure: ${DateFormat('HH:mm:ss').format(DateTime.parse(kmSoir.datetimeSoir))}'),
              ],
          ],
        ),
        trailing: Text(
          'KM Soir',
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
            if (datetimeDepart != null && datetimeDepart.isNotEmpty)
              ...[
                Text(
                  'Départ:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(datetimeDepart))}'),
                Text(
                    'Heure: ${DateFormat('HH:mm:ss').format(DateTime.parse(datetimeDepart))}'),
              ],
            if (datetimeArrivee != null && datetimeArrivee.isNotEmpty)
              ...[
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
          'Archives de dépôts',
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
                final pointageDepotRecords = dateRecords
                    .where((record) => record is PointageDepot)
                    .toList();
                final pointageImprevuRecords = dateRecords
                    .where((record) => record is PointageImprevu)
                    .toList();
                final btnRecords = dateRecords
                    .where((record) => record is Map<String, dynamic>)
                    .toList();
                final kmSoirRecords =
                    dateRecords.where((record) => record is KMsoir).toList();

                // Combiner les enregistrements pointage_depot et pointage_imprevu
                List<dynamic> combinedPointageRecords = [];
                combinedPointageRecords.addAll(pointageDepotRecords);
                combinedPointageRecords.addAll(pointageImprevuRecords);

                // Trier les enregistrements combinés par matricule ou autre critère
                combinedPointageRecords.sort((a, b) {
                  String aMatricule;
                  String bMatricule;

                  if (a is PointageDepot) {
                    aMatricule = a.matricule;
                  } else if (a is PointageImprevu) {
                    aMatricule = a.matricule;
                  } else {
                    aMatricule = '';
                  }

                  if (b is PointageDepot) {
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
                      // Affichage des informations de déplacement (btnRecords et kmSoirRecords)
                      if (btnRecords.isNotEmpty || kmSoirRecords.isNotEmpty) ...[
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
                        ...kmSoirRecords.map((kmRecord) {
                          return _buildKMsoirListTile(kmRecord as KMsoir);
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
                          if (record is PointageDepot) {
                            return _buildDepotListTile(record);
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
