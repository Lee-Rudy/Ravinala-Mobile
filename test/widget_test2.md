import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transportflutter/main.dart';

void main() {
  testWidgets('Test de chargement de l\'application et affichage de la page d\'accueil', (WidgetTester tester) async {
    // Construire notre application et déclencher un frame.
    await tester.pumpWidget(MyApp());

    // Vérifiez que le texte de la page d'accueil s'affiche correctement.
    expect(find.text('Flutter Routing Example'), findsNothing); // Titre de l'application dans MyApp
    expect(find.byType(HomeScreen), findsOneWidget); // S'assure que HomeScreen est affiché
  });
}
