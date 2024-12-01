import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class DatabaseReset {
  static final DatabaseReset _instance = DatabaseReset._internal();
  static Database? _database;

  static DatabaseReset get instance => _instance;

  factory DatabaseReset() {
    return _instance;
  }

  DatabaseReset._internal();

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
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    // Ouvre la base de données avec des options appropriées
    return await openDatabase(
      path,
      version: 1, // Mettez à jour la version si nécessaire
      onOpen: (db) {
        // Actions à effectuer lors de l'ouverture de la base de données
      },
    );
  }

  /// Méthode pour vider plusieurs tables et réinitialiser leurs IDs
  Future<void> truncateAllTables() async {
    final db = await database;

    try {
      await db.transaction((txn) async {
        // Liste des tables à vider, ajoutez 'cars' si nécessaire
        List<String> tables = [
          'planning_ramassage',
          'planning_depot',
          'pointage_ramassage',
          'pointage_depot',
          'pointage_usagers_imprevu',
          'btn',
          'km_matin',
          'km_soir',
        ];

        // Supprimer toutes les lignes de chaque table
        for (String table in tables) {
          await txn.delete(table);
        }

        // Vérifier si la table sqlite_sequence existe
        List<Map<String, dynamic>> seqResult = await txn.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='sqlite_sequence'",
        );

        if (seqResult.isNotEmpty) {
          // Réinitialiser les séquences pour les tables avec AUTOINCREMENT
          for (String table in tables) {
            await txn.rawDelete(
              'DELETE FROM sqlite_sequence WHERE name = ?',
              [table],
            );
          }
        } else {
          print('La table sqlite_sequence n\'existe pas. Aucune séquence à réinitialiser.');
        }
      });
    } catch (e) {
      print('Erreur lors de la troncature des tables: $e');
      throw Exception('Échec de la réinitialisation de la base de données.');
    }
  }
}
