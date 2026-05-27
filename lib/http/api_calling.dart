import 'dart:convert';
import 'package:http/http.dart' as http;

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
    // Appel à l'api
    final responseCity = await http.get(url);

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
  }

  Future<Map<String, dynamic>> getWeather(double lat, double long) async {
    final urlWeather = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=d0b05df87a6186c2a0296fef2e59b2da&units=metric',
    );

    final response = await http.get(urlWeather);

    // Gestion des erreurs
    if (response.statusCode == 200) {
      final finalData = jsonDecode(response.body);
      return finalData;
    }
    return throw Exception();
  }
}
