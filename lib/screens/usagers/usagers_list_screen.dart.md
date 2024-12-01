import 'package:flutter/material.dart';
import 'package:transportflutter/database/database_helper.dart';
import 'package:transportflutter/models/usagers/usagers_mobile.dart';

class UsagerListScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Usagers>> fetchUsagers() async {
    final db = await dbHelper.database;
    final usagers = await db.query('usagers_mobile');
    return usagers.map((usager) => Usagers.fromMap(usager)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des Usagers')),
      body: FutureBuilder<List<Usagers>>(
        future: fetchUsagers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun usager trouvé'));
          } else {
            return ListView(
              children: snapshot.data!.map((usager) {
              return ListTile(
                title: Text('${usager.nom} ${usager.prenom}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Matricule: ${usager.matricule}'),
                    Text('ID: ${usager.id}'),
                  ],
                ),
              );
            }).toList(),

            );
          }
        },
      ),
    );
  }
}
