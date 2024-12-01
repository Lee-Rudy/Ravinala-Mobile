import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/models/planning/planning_ramassage/planning_ramassage.dart';
import 'package:transportflutter/models/pointage/pointage_imprevu/pointage_imprevu.dart';

class ListRamassageScreen extends StatefulWidget {
  @override
  _ListRamassageScreenState createState() => _ListRamassageScreenState();
}

class _ListRamassageScreenState extends State<ListRamassageScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  late Future<List<dynamic>> _combinedListFuture; // Liste combinée (PlanningRamassage + PointageImprevu)
  final PageStorageBucket _bucket = PageStorageBucket();


  // Variables d'état pour stocker les données de session
  Map<int, bool?> _presenceStatus = {}; // true: présent, false: absent, null: non défini
  Map<int, DateTime?> _pointageDates = {}; // Heure de pointage pour chaque usager (id)
  DateTime? _datetimeDepart;
  DateTime? _datetimeArrivee;
  String? _nomCar; // Nom de la voiture
  TextEditingController _matriculeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _combinedListFuture = fetchCombinedList();
  }

  // Méthode pour récupérer et combiner les données de planning_ramassage et pointage_usagers_imprevu
  Future<List<dynamic>> fetchCombinedList() async {
    final db = await dbHelper.database;

    // Récupération de planning_ramassage
    final pr = await db.query('planning_ramassage');
    final List<PlanningRamassage> ramassageList = pr.map((map) => PlanningRamassage.fromMap(map)).toList();

    // Récupération de pointage_usagers_imprevu
    final pi = await db.query('pointage_usagers_imprevu');
    final List<PointageImprevu> imprevuList = pi.map((map) => PointageImprevu.fromMap(map)).toList();

    // Combiner les deux listes
    List<dynamic> combinedList = [];
    combinedList.addAll(ramassageList);
    combinedList.addAll(imprevuList);

    return combinedList;
  }

  Future<void> _savePointage() async {
    final db = await dbHelper.database;

    // Insertion des pointages dans la table pointage_ramassage
    for (var entry in _presenceStatus.entries) {
      int idUsager = entry.key;
      bool? presenceValue = entry.value;
      if (presenceValue != null) {
        bool estPresent = presenceValue;
        DateTime? pointageDatetime = _pointageDates[idUsager];

        final usager = await db.query(
          'planning_ramassage',
          where: 'id = ?',
          whereArgs: [idUsager],
        );

        if (usager.isNotEmpty) {
          final matricule = usager[0]['matricule'] as String?;
          final nomUsager = usager[0]['nomUsager'] as String?;
          final nomVoiture = usager[0]['nom_voie'] as String?;

          await db.insert(
            'pointage_ramassage',
            {
              'matricule': matricule,
              'nomUsager': nomUsager,
              'nom_car': nomVoiture,
              'datetime_ramassage': estPresent && pointageDatetime != null
                  ? DateFormat("yyyy-MM-dd HH:mm:ss").format(pointageDatetime)
                  : null,
              'est_present': estPresent ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace, //éviter les doublons
          );
        }
      }
    }

    // Insertion des informations de départ/arrivée dans la table btn
    if (_datetimeDepart != null && _datetimeArrivee != null && _nomCar != null) {
      await db.insert(
        'btn',
        {
          'datetime_depart': DateFormat("yyyy-MM-dd HH:mm:ss").format(_datetimeDepart!),
          'datetime_arrivee': DateFormat("yyyy-MM-dd HH:mm:ss").format(_datetimeArrivee!),
          'nom_car': _nomCar,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Réinitialiser l'état après sauvegarde
    setState(() {
      _presenceStatus.clear();
      _pointageDates.clear();
      _datetimeDepart = null;
      _datetimeArrivee = null;
      _nomCar = null;
      _combinedListFuture = fetchCombinedList(); // Recharger la liste
    });

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Données enregistrées avec succès !')),
    );
  }

  // Méthode pour ajouter un pointage imprevu dans la base
  Future<void> _addImprevu(String matricule) async {
    final db = await dbHelper.database;

    String currentDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    await db.insert(
      'pointage_usagers_imprevu',
      {
        'matricule': matricule,
        'datetime_imprevu': currentDateTime,
        'nom_car': _nomCar ?? 'Inconnu',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Mettre à jour la liste combinée
    setState(() {
      _combinedListFuture = fetchCombinedList();
    });
  }

  // Méthode pour afficher un popover (dialogue) pour saisir le matricule
  void _showAddImprevuDialog() {
    showDialog(
      context: context,
      builder: (context) {
        _matriculeController.clear();
        return AlertDialog(
          title: Text('Ajouter un Matricule Imprévu'),
          content: TextField(
            controller: _matriculeController,
            decoration: InputDecoration(hintText: "Entrez le matricule"),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                String matricule = _matriculeController.text.trim();
                if (matricule.isNotEmpty) {
                  _addImprevu(matricule);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez entrer un matricule valide.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _markPresence(int idUsager) {
    setState(() {
      _presenceStatus[idUsager] = true; // Marque l'usager comme présent
      _pointageDates[idUsager] = DateTime.now(); // Heure de pointage
    });
  }

  void _markAbsence(int idUsager) {
    setState(() {
      _presenceStatus[idUsager] = false; // Marque l'usager comme absent
      _pointageDates[idUsager] = null; // Pas d'heure de pointage pour absents
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste de ramassage',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            color: Colors.deepPurple,
            onPressed: _showAddImprevuDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _combinedListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune donnée disponible'));
          } else {
            final combinedList = snapshot.data!;

            // Initialiser le nom de la voiture si nécessaire
            if (_nomCar == null && combinedList.isNotEmpty) {
              // Chercher la première entrée de type PlanningRamassage pour obtenir le nomVoiture
              for (var item in combinedList) {
                if (item is PlanningRamassage && item.nomVoiture != null) {
                  _nomCar = item.nomVoiture;
                  break;
                } else if (item is PointageImprevu && item.nom_car.isNotEmpty) {
                  _nomCar = item.nom_car;
                  break;
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Boutons Départ et Arrivée
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _datetimeDepart == null
                            ? () {
                                setState(() {
                                  _datetimeDepart = DateTime.now();
                                });
                              }
                            : null,
                        child: Text(
                          _datetimeDepart != null
                              ? 'Départ : ${DateFormat("HH:mm:ss").format(_datetimeDepart!)}'
                              : 'Départ',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _datetimeArrivee == null
                            ? () {
                                setState(() {
                                  _datetimeArrivee = DateTime.now();
                                });
                              }
                            : null,
                        child: Text(
                          _datetimeArrivee != null
                              ? 'Arrivée : ${DateFormat("HH:mm:ss").format(_datetimeArrivee!)}'
                              : 'Arrivée',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Liste combinée des usagers présents, absents et imprevu
                  Expanded(
                    child: ListView.builder(
                      itemCount: combinedList.length,
                      itemBuilder: (context, index) {
                        final item = combinedList[index];
                        if (item is PlanningRamassage) {
                          final idUsager = item.id!;
                          final presenceValue = _presenceStatus[idUsager];
                          return _buildPlanningRamassageItem(item, idUsager, presenceValue);
                         }
                         //eto 
                        else if (item is PointageImprevu) {
                          return _buildPointageImprevuItem(item);
                        } 
                        //katreto
                        else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  // Bouton pour enregistrer toutes les données
                  ElevatedButton(
                    onPressed: () async {
                      await _savePointage();
                    },
                    child: Text('Tout enregistrer'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Construction de l'item pour PlanningRamassage
  Widget _buildPlanningRamassageItem(PlanningRamassage prItem, int idUsager, bool? presenceValue) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations de l'usager
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prItem.matricule ?? ''}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Nom Usager: ${prItem.nomUsager ?? ''}'),
                Text('Nom car: ${prItem.nomVoiture ?? ''}'),
                Text('Fokontany: ${prItem.fokontany ?? ''}'),
                Text('Lieu: ${prItem.lieu ?? ''}'),
                Text(
                  'Heure: ${prItem.heure != null ? DateFormat("HH:mm:ss").format(prItem.heure) : ''}',
                  style: TextStyle(
                    color: Color.fromARGB(255, 125, 125, 125),
                  ),
                ),
                if (presenceValue == true && _pointageDates[idUsager] != null)
                  Text(
                    'Pointage: ${DateFormat("yyyy-MM-dd HH:mm:ss").format(_pointageDates[idUsager]!)}',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          // Boutons "P" et "A" pour marquer Présent ou Absent
          Column(
            children: [
              IconButton(
                onPressed: presenceValue != true
                    ? () {
                        _markPresence(idUsager);
                      }
                    : null,
                icon: CircleAvatar(
                  backgroundColor: presenceValue == true
                      ? Colors.green
                      : const Color.fromARGB(255, 181, 107, 251),
                  radius: 25,
                  child: Text(
                    'P',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                ),
              ),
              SizedBox(height: 10),
              IconButton(
                onPressed: presenceValue != false
                    ? () {
                        _markAbsence(idUsager);
                      }
                    : null,
                icon: CircleAvatar(
                  backgroundColor: presenceValue == false
                      ? Colors.red
                      : Colors.grey,
                  radius: 25,
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
//eto 
  //Construction de l'item pour PointageImprevu
  Widget _buildPointageImprevuItem(PointageImprevu piItem) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations du pointage imprevu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${piItem.matricule}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Nom car: ${piItem.nom_car}'),
                Text('Date: ${DateFormat("yyyy-MM-dd").format(DateTime.parse(piItem.datetime_imprevu))}'),
                Text('Heure: ${DateFormat("HH:mm:ss").format(DateTime.parse(piItem.datetime_imprevu))}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  //katreto
}
