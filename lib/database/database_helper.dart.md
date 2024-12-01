import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:transportflutter/models/cars/cars_mobile.dart';
import 'package:transportflutter/models/usagers/usagers_mobile.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static DatabaseHelper get instance => _instance; //utilisé dans data_loader_screen

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'bdd.db');

    // Vérifie si la base de données existe déjà dans le répertoire cible
    if (!await File(path).exists()) {
      // Copie la base de données depuis les assets vers le répertoire cible
      ByteData data = await rootBundle.load('lib/assets/database/bdd.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    // Ouvre la base de données
    return await openDatabase(path);
  }

//Car
  // Méthode pour insérer ou mettre à jour un Car
  Future<void> insertOrUpdateCar(Car car) async {
    final db = await database;
    await db.insert(
      'cars_mobile',
      car.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Méthode pour récupérer tous les Cars
  Future<List<Car>> fetchAllCars() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cars_mobile');
    return List.generate(maps.length, (i) {
      return Car.fromMap(maps[i]);
    });
  }


//Usagers
  // Méthode pour insérer ou mettre à jour un Usager
  Future<void> insertOrUpdateUsager(Usagers usager) async {
    final db = await database;
    await db.insert(
      'usagers_mobile',
      usager.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Méthode pour récupérer tous les Usagers
  Future<List<Usagers>> fetchAllUsagers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('usagers_mobile');
    return List.generate(maps.length, (i) {
      return Usagers.fromMap(maps[i]);
    });
  }
}
