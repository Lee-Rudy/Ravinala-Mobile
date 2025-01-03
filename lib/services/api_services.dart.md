import 'package:dio/dio.dart';
import 'package:transportflutter/models/planning/planning_ramassage/planning_ramassage.dart';
import 'package:transportflutter/models/planning/planning_depot/planning_depot.dart';
import 'package:transportflutter/models/push/push_data.dart';

class ApiService {
  final String urlDotnet = '2d76-154-126-80-78.ngrok-free.app'; // ngrok pour le moment
  late final Dio dio;

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://$urlDotnet/api',
      connectTimeout: Duration(seconds: 120),
      receiveTimeout: Duration(seconds: 120),
    ));
  }

  Future<List<PlanningRamassage>> fetchPlanningRamassage(String nomCar) async {
    try {
      final response = await dio.get('/planning/liste_ramassage_mobile/$nomCar');
      List<dynamic> data = response.data;
      return data.map((pr) => PlanningRamassage.fromMap(pr)).toList();
    } catch (e) {
      print('Erreur : ${e.toString()}'); // Affiche l'erreur complète
      throw Exception(
          'lors de la récupération de données et vérifier la connexion du réseau');
    }
  }

  Future<List<PlanningDepot>> fetchPlanningDepot(String nomCar) async {
    try {
      final response = await dio.get('/planning/liste_depot_mobile/$nomCar');
      List<dynamic> data = response.data;
      return data.map((pd) => PlanningDepot.fromMap(pd)).toList();
    } catch (e) {
      print('Erreur : ${e.toString()}');
      throw Exception('Erreur lors de la récupération du planning de dépôt');
    }
  }

  //push
  Future<void> sendAllData(PushDataRequest pushData) async {
  try {
    // Conversion des données en JSON
    final Map<String, dynamic> dataToSend = pushData.toMap();

    // Envoyer les données au serveur
    print('Données envoyées au serveur : $dataToSend');
    final response = await dio.post('/push/sendAll', data: dataToSend);

    if (response.statusCode == 200) {
      print("Données envoyées avec succès : ${response.data}");
    } else {
      throw Exception('Erreur serveur : ${response.statusCode}');
    }
  } catch (e) {
    print('Erreur lors de l\'envoi des données : ${e.toString()}');
    throw Exception('Erreur réseau ou serveur.');
  }
}



  //simulation :
  //plannig_ramasage : 200 ok
  //planning_depot : error fails 
  // résultat -> le chargement annulera les chargements des données de ram et dépot
  Future<void> fetchPlannings(String nomCar) async {
    try {
      final List<PlanningRamassage> ramassages =
          await fetchPlanningRamassage(nomCar);
      try {
        final List<PlanningDepot> depots = await fetchPlanningDepot(nomCar);
        print("Données chargées avec succès :");
        print("Ramassages : ${ramassages.length}");
        print("Dépôts : ${depots.length}");
      } catch (e) {
        print('Erreur lors du chargement des dépôts : ${e.toString()}');
        throw Exception(
            'Interruption détectée : Annulation des données de ramassage');
      }
    } catch (e) {
      print('Erreur lors du chargement des ramassages : ${e.toString()}');
      throw Exception(
          'Interruption détectée : Échec du chargement des données.');
    }
  }


  //login cars
  Future<Map<String, dynamic>> login(String nomCarLogin, String motDePasse) async {
    try {
      final response = await dio.post(
        '/cars/auth',
        data: {
          'nom_car_login': nomCarLogin,
          'mot_de_passe': motDePasse,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
          'user': response.data['user'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Erreur inconnue.',
        };
      }
    } on DioError catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        // Erreur venant du serveur
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Erreur du serveur.',
        };
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.sendTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        // Timeout
        return {
          'success': false,
          'message': 'La requête a expiré. Veuillez réessayer.',
        };
      } else {
        // Autres erreurs (réseau, etc.)
        return {
          'success': false,
          'message': 'Une erreur est survenue. Veuillez réessayer.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur est survenue. Veuillez réessayer.',
      };
    }
  }
}