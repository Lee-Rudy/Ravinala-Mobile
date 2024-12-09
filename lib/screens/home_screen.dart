import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showDescription = false;

  final List<Map<String, dynamic>> values = [
    {
      "title": "Bienveillance",
      "icon": Icons.favorite,
      "detail": "Favoriser la gentillesse et l'entraide pour des relations harmonieuses.",
    },
    {
      "title": "Ambition",
      "icon": Icons.trending_up,
      "detail": "Viser l'excellence et innover constamment.",
    },
    {
      "title": "Sens du travail",
      "icon": Icons.work,
      "detail": "Valoriser l'effort et l'organisation pour des résultats optimaux.",
    },
    {
      "title": "Engagement",
      "icon": Icons.handshake,
      "detail": "Respecter les promesses et rester fidèle aux valeurs.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Partie supérieure
            Flexible(
              flex: 2,
              child: Row(
                children: [
                  // Partie gauche
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Color(0xFF45B48E),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ajout du logo
                          Image.asset(
                            'lib/assets/images/ravicheck.png',
                            height: screenWidth * 0.2, // Ajustez la taille en fonction de l'écran
                            width: screenWidth * 0.2,
                          ),
                          SizedBox(height: 1), // Espacement entre l'image et le texte
                          Text(
                            "",//RaviCheck
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE8F3E8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "by Ravinala Airports",
                            style: TextStyle(
                              fontSize: screenWidth * 0.02,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE8F3E8).withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Votre application de pointage pour ramassage et dépôt.",
                            style: TextStyle(
                              fontSize: screenWidth * 0.012,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE8F3E8).withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Partie droite
                  Expanded(
                    flex: 2,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: showDescription
                          ? _buildDescriptionSection()
                          : _buildValuesGrid(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showDescription = !showDescription;
          });
        },
        backgroundColor: const Color.fromARGB(255, 28, 28, 28),
        child: Icon(
          Icons.help_outline,
          color: Color(0xFFE8F3E8),
        ),
        tooltip: "Comment utiliser RaviCheck ?",
      ),
    );
  }

  Widget _buildValuesGrid() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values[index];
          return Container(
            decoration: BoxDecoration(
              color: Color(0xFFE8F3E8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  value["icon"] as IconData,
                  size: 48,
                  color: Color(0xFF45B48E),
                ),
                SizedBox(height: 8),
                Text(
                  value["title"] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  value["detail"] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionSection() {
  // Liste des étapes avec des descriptions corrigées et icônes
  List<Map<String, dynamic>> steps = [
    {
      'title': 'Étape 1',
      'description': 'Supprimez les données si ils sont déjà été envoyés',
      'icon': Icons.delete_forever,
    },
    {
      'title': 'Étape 2',
      'description': 'Récupérez les nouvelles données à traiter.',
      'icon': Icons.download,
    },
    {
      'title': 'Étape 3',
      'description': 'Enregistrez les pointages matinaux et du soir.',
      'icon': Icons.check_circle_outline,
    },
    {
      'title': 'Étape 4',
      'description': 'Envoyez les données et répétez l’opération.',
      'icon': Icons.send,
    },
  ];

  return Container(
    color: Colors.grey[50],
    padding: EdgeInsets.all(16),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre principal
          Text(
            "Comment utiliser RaviCheck ?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          // Sous-titre
          Text(
            "contactez-nous au : 034 12 345 67.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),

          // Étapes dynamiques avec icônes
          Column(
            children: steps.map((step) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(
                    step['icon'],
                    color: Color(0xFF45B48E),
                    size: 32,
                  ),
                  title: Text(
                    step['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    step['description']!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32),

          // Bouton Retour
          ElevatedButton(
            onPressed: () {
              setState(() {
                showDescription = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 28, 28, 28),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Retour"),
          ),
        ],
      ),
    ),
  );
}


}
