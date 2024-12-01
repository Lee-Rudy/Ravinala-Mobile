import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/models/planning/planning_ramassage/planning_ramassage.dart';
import 'package:transportflutter/models/pointage/pointage_imprevu/pointage_imprevu.dart';
import 'package:transportflutter/models/km/km_matin.dart';

class ListRamassageScreen extends StatefulWidget {
  @override
  _ListRamassageScreenState createState() => _ListRamassageScreenState();
}

class RamassageSession {
  static final RamassageSession _instance = RamassageSession._internal();

  factory RamassageSession() {
    return _instance;
  }

  RamassageSession._internal();

  // Variables d'état pour stocker les données de session
  Map<int, bool?> presenceStatus = {}; // true: présent, false: absent, null: non défini
  Map<int, DateTime?> pointageDates = {}; // Heure de pointage pour chaque usager (id)
  DateTime? datetimeDepart;
  DateTime? datetimeArrivee;
  String? nomCar; // Nom de la voiture

  void reset() {
    presenceStatus.clear();
    pointageDates.clear();
    datetimeDepart = null;
    datetimeArrivee = null;
    nomCar = null;
  }
}

class _ListRamassageScreenState extends State<ListRamassageScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  late Future<List<dynamic>> _combinedListFuture; // Liste combinée (PlanningRamassage + PointageImprevu)
  final PageStorageBucket _bucket = PageStorageBucket();

  TextEditingController _departKMController = TextEditingController();
  TextEditingController _finKMController = TextEditingController();
  TextEditingController _matriculeController = TextEditingController();

  String _selectedUserType = 'Stagiaire'; // Par défaut

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
    final List<PlanningRamassage> ramassageList =
        pr.map((map) => PlanningRamassage.fromMap(map)).toList();

    // Récupération de pointage_usagers_imprevu
    final pi = await db.query('pointage_usagers_imprevu');
    final List<PointageImprevu> imprevuList =
        pi.map((map) => PointageImprevu.fromMap(map)).toList();

    // Combiner les deux listes
    List<dynamic> combinedList = [];
    combinedList.addAll(ramassageList);
    combinedList.addAll(imprevuList);

    return combinedList;
  }

  Future<void> _savePointage() async {
    final db = await dbHelper.database;

    // Insertion des pointages dans la table pointage_ramassage
    for (var entry in RamassageSession().presenceStatus.entries) {
      int idUsager = entry.key;
      bool? presenceValue = entry.value;
      if (presenceValue != null) {
        bool estPresent = presenceValue;
        DateTime? pointageDatetime = RamassageSession().pointageDates[idUsager];

        final usager = await db.query(
          'planning_ramassage',
          where: 'id = ?',
          whereArgs: [idUsager],
        );

        if (usager.isNotEmpty) {
          final matricule = usager[0]['matricule'] as String?;
          final nomUsager = usager[0]['nomUsager'] as String?;
          final nomVoiture = usager[0]['nomVoiture'] as String?;

          // Enregistrement selon la présence
          await db.insert(
            'pointage_ramassage',
            {
              'matricule': matricule,
              'nomUsager': nomUsager,
              'nomVoiture': nomVoiture,
              'datetime_ramassage': estPresent
                  ? (pointageDatetime != null
                      ? DateFormat("yyyy-MM-dd HH:mm:ss")
                          .format(pointageDatetime)
                      : null)
                  : DateFormat("yyyy-MM-dd").format(DateTime.now()), // Date d'absence pour les absents
              'est_present': estPresent ? 1 : 0,
            },
            conflictAlgorithm:
                ConflictAlgorithm.replace, //éviter les doublons
          );
        }
      }
    }

    // Insertion des informations de départ/arrivée dans la table btn
    if (RamassageSession().datetimeDepart != null &&
        RamassageSession().datetimeArrivee != null &&
        RamassageSession().nomCar != null) {
      await db.insert(
        'btn',
        {
          'datetime_depart':
              DateFormat("yyyy-MM-dd HH:mm:ss").format(RamassageSession().datetimeDepart!),
          'datetime_arrivee':
              DateFormat("yyyy-MM-dd HH:mm:ss").format(RamassageSession().datetimeArrivee!),
          'nomVoiture': RamassageSession().nomCar,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Insertion des kilométrages matin dans la table km_matin
    try {
      if (_departKMController.text.isNotEmpty &&
          _finKMController.text.isNotEmpty) {
        final kmMatin = KMmatin(
          depart: _departKMController.text.trim(),
          fin: _finKMController.text.trim(),
          nomVoiture: RamassageSession().nomCar ?? 'Inconnu',
          datetimeMatin:
              DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        );

        await db.insert(
          'km_matin',
          kmMatin.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Réinitialiser les champs après insertion
        _departKMController.clear();
        _finKMController.clear();
      } else {
        // Si les champs ne sont pas remplis, afficher une boîte de dialogue d'erreur
        _showErrorDialog('Veuillez remplir les champs kilométrage départ et fin.');
        return;
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de l\'enregistrement des kilométrages: $e');
      return;
    }

    // Réinitialiser l'état après sauvegarde
    setState(() {
      RamassageSession().reset();
      _combinedListFuture = fetchCombinedList(); // Recharger la liste
    });

    // Afficher un message de succès
    _showSuccessDialog('Données enregistrées avec succès !');
  }

  Future<bool> _onWillPop() async {
    // Vérifier s'il y a des données non enregistrées
    if (RamassageSession().presenceStatus.isNotEmpty ||
        RamassageSession().datetimeDepart != null ||
        RamassageSession().datetimeArrivee != null ||
        _departKMController.text.isNotEmpty ||
        _finKMController.text.isNotEmpty) {
      // Demander une confirmation avant de quitter la page
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Êtes-vous sûr ?'),
              content: Text(
                  'Vous avez des modifications non enregistrées. Voulez-vous vraiment quitter la page sans sauvegarder ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Non'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Oui'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  // Méthode pour ajouter un pointage imprevu dans la base
  Future<void> _addImprevu(String matricule) async {
    final db = await dbHelper.database;

    String currentDateTime =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    await db.insert(
      'pointage_usagers_imprevu',
      {
        'matricule': matricule,
        'datetime_imprevu': currentDateTime,
        'nomVoiture': RamassageSession().nomCar ?? 'Inconnu',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Mettre à jour la liste combinée
    setState(() {
      _combinedListFuture = fetchCombinedList();
    });

    // Afficher un message de succès
    _showSuccessDialog('Pointage imprévu ajouté avec succès !');
  }

  // Méthode pour afficher un popover (dialogue) pour saisir le matricule
  void _showAddImprevuDialog() {
    _matriculeController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un Matricule'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _selectedUserType,
                    items: ['Stagiaire', 'Employé']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUserType = value!;
                        _matriculeController.clear();
                      });
                    },
                  ),
                  TextField(
                    controller: _matriculeController,
                    keyboardType: _selectedUserType == 'Employé'
                        ? TextInputType.number
                        : TextInputType.number,
                    decoration: InputDecoration(
                      hintText:
                          _selectedUserType == 'Stagiaire' ? 'ST-' : 'Matricule',
                    ),
                  ),
                ],
              );
            },
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
                if (_selectedUserType == 'Stagiaire' && !matricule.startsWith('ST-')) {
                  matricule = 'ST-$matricule';
                }
                if (matricule.isNotEmpty) {
                  _addImprevu(matricule);
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog('Veuillez entrer un matricule valide.');
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
      RamassageSession().presenceStatus[idUsager] = true; // Marque l'usager comme présent
      RamassageSession().pointageDates[idUsager] = DateTime.now(); // Heure de pointage
    });
  }

  void _markAbsence(int idUsager) {
    setState(() {
      RamassageSession().presenceStatus[idUsager] = false; // Marque l'usager comme absent
      RamassageSession().pointageDates[idUsager] = null; // Pas d'heure de pointage pour absents
    });
  }

  // Méthode pour afficher une boîte de dialogue d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher une boîte de dialogue de succès
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher une boîte de dialogue de confirmation avant l'enregistrement
  Future<void> _showConfirmationDialog() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer l\'enregistrement'),
          content: Text('Voulez-vous vraiment enregistrer les données ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _savePointage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          // Ferme le clavier lorsqu'on touche en dehors des champs
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Liste de ramassage',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF45B48E),
            elevation: 0,
            centerTitle: true,
            actions: [
              Container(
                margin: EdgeInsets.only(
                    top: 0.0, bottom: 0.0, left: 10.0, right: 20.0),
                child: IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 30.0,
                  ),
                  color: Colors.white,
                  onPressed: _showAddImprevuDialog,
                ),
              ),
            ],
          ),
          body: PageStorage(
            bucket: _bucket,
            child: FutureBuilder<List<dynamic>>(
              future: _combinedListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF45B48E)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucune donnée disponible'));
                } else {
                  final combinedList = snapshot.data!;

                  // Initialiser le nom de la voiture si nécessaire
                  if (RamassageSession().nomCar == null && combinedList.isNotEmpty) {
                    // Chercher la première entrée de type PlanningRamassage pour obtenir le nomVoiture
                    for (var item in combinedList) {
                      if (item is PlanningRamassage && item.nomVoiture != null) {
                        RamassageSession().nomCar = item.nomVoiture;
                        break;
                      } else if (item is PointageImprevu &&
                          item.nomVoiture.isNotEmpty) {
                        RamassageSession().nomCar = item.nomVoiture;
                        break;
                      }
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView(
                      children: [
                        // Boutons Départ et Arrivée
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 16.0,
                                    left: 0.0,
                                    right: 8.0),
                                child: SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF45B48E),
                                    ),
                                    onPressed: RamassageSession().datetimeDepart == null
                                        ? () {
                                            setState(() {
                                              RamassageSession().datetimeDepart =
                                                  DateTime.now();
                                            });
                                          }
                                        : null,
                                    child: Text(
                                      RamassageSession().datetimeDepart != null
                                          ? 'Départ : ${DateFormat("HH:mm:ss").format(RamassageSession().datetimeDepart!)}'
                                          : 'Départ',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 16.0,
                                    left: 8.0,
                                    right: 0.0),
                                child: SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF45B48E),
                                    ),
                                    onPressed: RamassageSession().datetimeArrivee == null
                                        ? () {
                                            setState(() {
                                              RamassageSession().datetimeArrivee =
                                                  DateTime.now();
                                            });
                                          }
                                        : null,
                                    child: Text(
                                      RamassageSession().datetimeArrivee != null
                                          ? 'Arrivée : ${DateFormat("HH:mm:ss").format(RamassageSession().datetimeArrivee!)}'
                                          : 'Arrivée',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Kilométrages matin
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _departKMController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Kilométrage départ',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _finKMController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Kilométrage fin',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Liste combinée des usagers présents, absents et imprevu
                        ListView.builder(
                          key: PageStorageKey<String>('list_ramassage_key'),
                          itemCount: combinedList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final item = combinedList[index];
                            if (item is PlanningRamassage) {
                              final idUsager = item.id!;
                              final presenceValue =
                                  RamassageSession().presenceStatus[idUsager];
                              return _buildPlanningRamassageItem(
                                  item, idUsager, presenceValue);
                            } else if (item is PointageImprevu) {
                              return _buildPointageImprevuItem(item);
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                        // Bouton pour enregistrer toutes les données
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(vertical: 15.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              await _showConfirmationDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF45B48E),
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: Text(
                              'Tout enregistrer',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // Construction de l'item pour PlanningRamassage
  Widget _buildPlanningRamassageItem(
      PlanningRamassage prItem, int idUsager, bool? presenceValue) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: presenceValue == true
            ? Color(0xFFE8F5E9)
            : presenceValue == false
                ? Color(0xFFFFEBEE)
                : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: presenceValue == true
              ? Colors.green
              : presenceValue == false
                  ? Colors.red
                  : Colors.grey.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                if (presenceValue == true &&
                    RamassageSession().pointageDates[idUsager] != null)
                  Text(
                    'Pointage: ${DateFormat("yyyy-MM-dd HH:mm:ss").format(RamassageSession().pointageDates[idUsager]!)}',
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
                      : Color(0xFF45B48E),
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

  // Construction de l'item pour PointageImprevu
  Widget _buildPointageImprevuItem(PointageImprevu piItem) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Nom car: ${piItem.nomVoiture}'),
                Text(
                    'Date: ${DateFormat("yyyy-MM-dd").format(DateTime.parse(piItem.datetimeImprevu))}'),
                Text(
                    'Heure: ${DateFormat("HH:mm:ss").format(DateTime.parse(piItem.datetimeImprevu))}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
