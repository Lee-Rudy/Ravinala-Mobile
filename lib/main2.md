import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
// import 'screens/loader/data_loader_screen.dart.md';
// import 'screens/car/cars_list_screen.dart.txt';
// import 'screens/usagers/usagers_list_screen.dart.md';
// import 'screens/car/data_list_screen.dart.md';
import 'screens/login/login_screen.dart';
import 'screens/car/cars_list_screen.dart';
import 'screens/loader/loader_planning/loader_planning_screen.dart';
import 'screens/planning/list_ramassage/list_ramassage.dart';
import 'screens/planning/list_depot/list_depot.dart';
import 'screens/archive/archivescreen_ramassage.dart';
import 'screens/archive/archivescreen_depot.dart';
import 'screens/reset/reset_screen.dart';

import 'screens/push/push_screen.dart';

// import 'screens/disconnect/disconnect.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisez la base de données pour vérifier qu'elle est bien accessible
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.database;

  // Lancez l'application après avoir vérifié la base de données
  runApp(MyApp());

  // Affiche l'alerte de chargement de la base de données une seule fois
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Succès"),
          content: Text("Base de données chargée avec succès!"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme l'alerte
              },
            ),
          ],
        );
      },
    );
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Routing Example',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 48, 50, 52),
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/login', // Définit la route par défaut (login)
      routes: {
        '/': (context) => MyHomePage(
              title: 'Accueil',
              child: HomeScreen(),
            ),
        '/login': (context) => MyHomePage(
              title: '',
              child: LoginScreen(),
              showDrawer: false, // Masque le Drawer sur la page de login
            ),
        '/details': (context) => MyHomePage(
              title: 'Détails',
              child: DetailScreen(),
            ),
        '/car_list': (context) => MyHomePage(
              title: 'Liste des cars',
              child: CarListScreen(),
            ),
        '/planning': (context) => MyHomePage(
              title: 'Charger les plannings',
              child: Loader_planning_screen(),
            ),
        '/list_ramassage': (context) => MyHomePage(
              title: '',
              child: ListRamassageScreen(),
            ),
        '/list_depot': (context) => MyHomePage(
              title: '',
              child: ListDepotScreen(),
            ),
        '/archive_ramassage': (context) => MyHomePage(
              title: '',
              child: ArchiveScreenRamassage(),
            ),
        '/archive_depot': (context) => MyHomePage(
              title: '',
              child: ArchiveScreenDepot(),
            ),
        '/send_data': (context) => MyHomePage(
              title: '',
              child: PushDataScreen(),
            ),
        '/reset_data': (context) => MyHomePage(
              title: '',
              child: ResetScreen(),
            ),
        // Ajoutez les autres routes ici
      },
    );
  }
}

//menu navbar 
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.child,
    this.showDrawer = true, // Nouveau paramètre
  });

  final String title;
  final Widget child;
  final bool showDrawer; // Déclaration du paramètre

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //manala an'ilay flèche retour kely iny
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(widget.title),
        toolbarHeight: 39.0,
      ),
      drawer: widget.showDrawer
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 251, 247, 255),
                    ),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 23, 23, 23),
                        fontSize: 24,
                      ),
                    ),
                  ),
                  // Ajouter les éléments du menu ici
                  ListTile(
                    leading: Icon(Icons.add_home_rounded),
                    iconColor: Color(0xFF45B48E),
                    title: Text('Accueil'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time),
                    iconColor: Color(0xFF45B48E),
                    title: Text('Planning'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/planning');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.cloud_sync),
                    iconColor: Color(0xFF45B48E),
                    title: Text('send data'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/send_data');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.refresh),
                    iconColor: Color(0xFF45B48E),
                    title: Text('Suppression des données'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/reset_data');
                    },
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.checklist_rounded),
                    iconColor: Color(0xFF45B48E),
                    title: Text('Pointage'),
                    children: [
                      ListTile(
                        leading: Icon(Icons.chevron_right),
                        iconColor: Color(0xFF45B48E),
                        title: Text('Pointage de ramassage'),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/list_ramassage');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.chevron_right),
                        iconColor: Color(0xFF45B48E),
                        title: Text('Pointage de dépôt'),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/list_depot');
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.archive),
                    iconColor: Color(0xFF45B48E),
                    title: Text('Historiques'),
                    children: [
                      ListTile(
                        leading: Icon(Icons.chevron_right),
                        iconColor: Color(0xFF45B48E),
                        title: Text('Historique de ramassage'),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/archive_ramassage');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.chevron_right),
                        iconColor: Color(0xFF45B48E),
                        title: Text('Historique de dépôt'),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/archive_depot');
                        },
                      ),
                    ],
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    iconColor: Color(0xFF45B48E),
                    title: Text('Se déconnecter'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/disconnect');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    iconColor: Color(0xFF45B48E),
                    title: Text('Se connecter'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            )
          : null, // Pas de Drawer si showDrawer est false
      body: widget.child,
    );
  }
}
