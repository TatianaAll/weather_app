import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // pour récupérer mes variables d'environnement

// Class statefull pour appel de l'API pour récupérer les longitudes et latitudes à partir d'un nom de ville
// dynamic pour indiquer que le nombre de résultats n'est pas important
class ApiCalling {
  // 1- méthode pour récupérer les coordonnées à partir du nom d'une ville
  // Future pour dire qu'on est en async, MAP pour une liste de String et dynamic = peu impôrte la taille
  Future<Map<String, dynamic>> getCoordinates(String city) async {
    // on formatte l'URL pour l'appel à mon API
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1',
    );

    try {
      // Appel à l'api
      final responseCity = await http
          .get(url)
          .timeout(
            // si + de 10s ==> pas d'internet pour faire péter l'erreur
            const Duration(seconds: 10),
            onTimeout: () => throw SocketException('Connexion Internet perdue'),
          );

      if (responseCity.statusCode == 200) {
        final dataCoordinates = jsonDecode(responseCity.body);
        final results = dataCoordinates['results'];
        if (results is List && results.isNotEmpty) {
          final first = results[0];
          if (first is Map<String, dynamic>) {
            return first;
          }
        }
        throw Exception('Ville introuvable');
      }

      throw Exception('Erreur API ${responseCity.statusCode}');
    } on SocketException catch (e) {
      throw Exception('Pas de connexion Internet: ${e.message}');
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getWeather(double lat, double long) async {
    final apiKey = dotenv.env['API_WEATHER'];

    final urlWeather = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$apiKey&units=metric',
    );

    try {
      final response = await http
          .get(urlWeather)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw SocketException('Connexion Internet perdue'),
          );

      // Gestion des erreurs
      if (response.statusCode == 200) {
        final finalData = jsonDecode(response.body);
        return finalData;
      }
      throw Exception('Erreur API: ${response.statusCode}');
    } on SocketException catch (e) {
      throw Exception('Pas de connexion Internet: ${e.message}');
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<String?> getCountryName(String countryCode) async {
    try {
      // import du JSON trouvé sur GitHub avec la correspondance code alpha-2 => nom du pays
      final rawJson = await rootBundle.loadString('assets/ISO3166-1.alpha2.json');
      // on transforme en Map lisible par flutter
      final data = jsonDecode(rawJson);
      if (data is Map<String, dynamic>) {
        // on récupère le code alpha-2
        final code = countryCode.toUpperCase();
        // on recherche le nom correspondant au code passé
        final name = data[code];
        // on renvoi le nom du pays trouvé (en anglais mais vazy c'est bon)
        if (name is String && name.isNotEmpty) {
          return name;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Impossible de lire le fichier de pays: ${e.toString()}');
    }
  }
}
