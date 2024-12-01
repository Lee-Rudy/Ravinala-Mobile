import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showDescription = false; // Contrôle si on affiche la description

  final List<Map<String, dynamic>> values = [
  {
    "title": "Bienveillance",
    "icon": Icons.favorite,
    "detail": "Favoriser la gentillesse et l'entraide. Cela signifie adopter une attitude positive, aider les autres lorsqu'ils en ont besoin et créer un environnement où chacun se sent valorisé et respecté. La bienveillance est essentielle pour cultiver des relations harmonieuses et renforcer la cohésion d'équipe.",
  },
  {
    "title": "Ambition",
    "icon": Icons.trending_up,
    "detail": "Toujours viser l'excellence. L'ambition est le moteur du progrès. Elle nous pousse à aller au-delà de nos limites, à innover et à atteindre nos objectifs avec détermination. Elle implique également une volonté de se développer constamment, tant au niveau personnel que professionnel.",
  },
  {
    "title": "Sens du travail",
    "icon": Icons.work,
    "detail": "Valoriser l'effort et l'organisation. Le sens du travail signifie être rigoureux, efficace et organisé dans ses tâches quotidiennes. Cela inclut également le respect des délais, la collaboration avec les collègues et le fait de donner le meilleur de soi-même pour atteindre des résultats optimaux.",
  },
  {
    "title": "Engagement",
    "icon": Icons.handshake,
    "detail": "Respecter nos promesses et nos valeurs. L'engagement reflète notre fiabilité et notre intégrité. Cela signifie tenir parole, soutenir les projets collectifs et rester fidèle aux principes fondamentaux qui guident notre organisation. Un fort engagement inspire confiance et renforce la crédibilité.",
  },
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFF45B48E),
      //   title: Text(
      //     "Nos valeurs",
      //     style: TextStyle(color: Color(0xFFE8F3E8)),
      //   ),
      //   centerTitle: true,
      // ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Partie gauche
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Color(0xFF45B48E),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "RaviCheck",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE8F3E8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "by Ravinala Airports",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE8F3E8).withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "votre application de pointage pour ramassage et dépôt",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showDescription = !showDescription;
          });
        },
        backgroundColor: Color.fromARGB(255, 28, 28, 28),
        
        child: Icon(
          Icons.help_outline, // Icône pour distinguer le bouton
          color: Color(0xFFE8F3E8),
        ),
        tooltip: "Comment utiliser RaviCheck ?", //maintenir le bouton 
      ),
    );
  }

  Widget _buildValuesGrid() {
    return Container(
      padding: EdgeInsets.all(50),
      color: Colors.grey[100],
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      color: Colors.grey[50],
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Comment utiliser RaviCheck ?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "RaviCheck est un outil simple pour promouvoir l'optimisation des ponctualités. "
            "Cliquez sur une valeur pour en savoir plus, et utilisez nos ressources "
            "pour les intégrer dans votre quotidien professionnel.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
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
    );
  }
}
