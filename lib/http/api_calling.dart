import 'dart:convert';
import 'dart:io';
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
    final rapidApiKey = dotenv.env['RAPIDAPI_KEY'];
    if (rapidApiKey == null || rapidApiKey.isEmpty) {
      throw Exception('Clé RapidAPI manquante. Ajoutez RAPIDAPI_KEY dans .env');
    }

    final url = Uri.parse(
      'https://country-codes3.p.rapidapi.com/search?short_name=$countryCode',
    );

    try {
      final response = await http
          .get(url, headers: {
            'X-RapidAPI-Key': rapidApiKey,
            'X-RapidAPI-Host': 'country-codes3.p.rapidapi.com',
            'Accept': 'application/json',
          })
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw SocketException('Connexion Internet perdue'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data['success'] == false) {
            return null;
          }

          final name = data['name'] ?? data['country_name'] ?? data['official_name'];
          if (name is String && name.isNotEmpty) {
            return name;
          }

          final nested = data['data'];
          if (nested is Map<String, dynamic>) {
            final nestedName = nested['name'] ?? nested['country_name'] ?? nested['official_name'];
            if (nestedName is String && nestedName.isNotEmpty) {
              return nestedName;
            }
          }
        }
        return null;
      }
      throw Exception('Erreur API RapidAPI: ${response.statusCode}');
    } on SocketException catch (e) {
      throw Exception('Pas de connexion Internet: ${e.message}');
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }
}
