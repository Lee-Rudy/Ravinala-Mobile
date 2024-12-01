import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';


import 'package:transportflutter/models/cars/cars.dart';
import 'package:transportflutter/models/planning/planning_ramassage/planning_ramassage.dart';
import 'package:transportflutter/models/planning/planning_depot/planning_depot.dart';

import 'package:transportflutter/models/pointage/pointage_ramassage/pointage_ramassage.dart';
import 'package:transportflutter/models/pointage/pointage_depot/pointage_depot.dart';

import 'package:transportflutter/models/pointage/pointage_imprevu/pointage_imprevu.dart';

import 'package:transportflutter/models/bouton/bouton.dart';

import 'package:transportflutter/models/km/km_matin.dart';
import 'package:transportflutter/models/km/km_soir.dart';



class DatabaseHelper 
{
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static DatabaseHelper get instance => _instance; //utilisé dans data_loader_screen

  factory DatabaseHelper() 
  {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async 
  {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async 
  {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'bdd.db');

    // Vérifie si la base de données existe déjà dans le répertoire cible
    if (!await File(path).exists()) 
    {
      // Copie la base de données depuis les assets vers le répertoire cible
      ByteData data = await rootBundle.load('lib/assets/database/bdd.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    // Ouvre la base de données
    return await openDatabase(path);
  }

//===========================================================================================
//----------------------------------------------------------------------
  //get liste cars
    // Méthode pour récupérer tous les Usagers
  Future<List<Cars>> fetchAllUsagers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cars');
    return List.generate(maps.length, (i) 
    {
      return Cars.fromMap(maps[i]);
    });
  }

  //insert cars
  // Méthode pour insérer ou mettre à jour un Car
  Future<void> insertOrUpdateCar(Cars car) async 
  {
    final db = await database;
    await db.insert(
      'cars',
      car.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

//----------------------------------------------------------------------
//insert planning ramassage
  Future<void> insertOrUpdatePlanningRamassage(PlanningRamassage pr) async 
  {
    final db = await database;
    await db.insert(
      'planning_ramassage',
      pr.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, //pour éviter les doublons
    );
  }

//get list planning ramassage
 Future<List<PlanningRamassage>> fetchAllPlanningRamassage() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('planning_ramassage');
    return List.generate(maps.length, (i) 
    {
      return PlanningRamassage.fromMap(maps[i]);
    });
  }

//---------------------------------------------------------------------
//insert planning depot
Future<void> insertOrUpdatePlanningDepot(PlanningDepot pd) async 
  {
    final db = await database;
    await db.insert(
      'planning_depot',
      pd.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //get list planning ramassage
 Future<List<PlanningDepot>> fetchAllPlanningDepot() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('planning_depot');
    return List.generate(maps.length, (i) 
    {
      return PlanningDepot.fromMap(maps[i]);
    });
  }


  //-------------------------------------
  //pointage ramassage 
   Future<void> insertOrUpdatePointageRamassage(PointageRamassage pr) async {
    final db = await database;
    await db.insert(
      'pointage_ramassage',
      pr.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //get liste pointage ramassage
   Future<List<PointageRamassage>> fetchAllPointageRamassage() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pointage_ramassage');
    return List.generate(maps.length, (i) {
      return PointageRamassage.fromMap(maps[i]);
    });
  }


  //-------------------------------------
  //pointage depot
   Future<void> insertOrUpdatePointageDepot(PointageRamassage pr) async {
    final db = await database;
    await db.insert(
      'pointage_depot',
      pr.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //get liste pointage depot
   Future<List<PointageDepot>> fetchAllPointageDepot() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pointage_depot');
    return List.generate(maps.length, (i) {
      return PointageDepot.fromMap(maps[i]);
    });
  }

  //-----------------------------------------------------
  //pointage imprevu ramassage et depot
  Future<void> insertOrUpdatePointageImprevu(PointageImprevu pi) async {
    final db = await database;
    await db.insert(
      'pointage_usagers_imprevu',
      pi.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //get all pointage imprevu
  Future<List<PointageImprevu>> fetchAllPointageImprevu() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pointage_usagers_imprevu');
    return List.generate(maps.length, (i) {
      return PointageImprevu.fromMap(maps[i]);
    });
  }

  //get all btn
 Future<List<CarButton>> fetchAllCarButton() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('btn');

  return List.generate(maps.length, (i) {
    final map = maps[i];
    // Vérifier que les clés existent dans le map
    final datetimeDepart = map['datetime_depart'] as String?;
    final datetimeArrivee = map['datetime_arrivee'] as String?;

    // Si les valeurs sont nulles, gérer en conséquence
    return CarButton(
      id: map['id'] as int?,
      nomVoiture: map['nomVoiture'] as String? ?? 'Inconnu',
      datetimeDepart: datetimeDepart ?? '',
      datetimeArrivee: datetimeArrivee ?? '',
    );
  });
}


//insert km matin
Future<void> insertOrUpdateKMmatin(KMmatin kmm) async {
    final db = await database;
    await db.insert(
      'km_matin',
      kmm.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

//get km matin
  Future<List<KMmatin>> fetchAllKMmatin() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('km_matin');
  return List.generate(maps.length, (i) {
    return KMmatin.fromMap(maps[i]);
  });
}


//insert km soir
  Future<void> insertOrUpdateKMsoir(KMsoir kms) async {
    final db = await database;
    await db.insert(
      'km_soir',
      kms.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //get km soir
  Future<List<KMsoir>> fetchAllKMsoir() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('km_soir');
  return List.generate(maps.length, (i) {
    return KMsoir.fromMap(maps[i]);
  });
}

}


