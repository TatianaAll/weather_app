import 'package:flutter/material.dart';
import 'package:weather_app/http/api_calling.dart'; // convertion des réponses JSON des API
// d0b05df87a6186c2a0296fef2e59b2da

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application météo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: .fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const MyHomePage(title: 'Application météo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiCalling _apiCalling = ApiCalling();
  // on déclare mon controller pour récupérer le champs texte
  final TextEditingController inputCity = TextEditingController();

  // préparation de mes données
  String message = '';
  bool isLoading = false;
  String? cityName;
  String? country;
  String? description;
  String? iconCode;
  double? temp;
  double? feelsLike;
  double? wind;

  // FONCTION POUR GERER LA RECHERCHE METEO SELON LA VILLE
  Future<void> handleClick() async {
    final city = inputCity.text.trim();
    // si pas de ville renseigné =>
    if (city.isEmpty) {
      setState(() {
        message = 'Veuillez renseigner une ville.';
        cityName = null;
      });
      return;
    }

    // appel de la méthode getCoordinates puis getWeather
    try {
      // appel de la méthode
      final finalCity = await _apiCalling.getCoordinates(city);
      // Récupération de la latitude et longitude de la ville renseignée
      final latValue = finalCity['latitude'];
      final lonValue = finalCity['longitude'];
      
      // fallback ==> si ça n'est pas des valeur numériques on lève une exception
      if (latValue is! num || lonValue is! num) {
        throw Exception('Coordonnées invalides reçues');
      }

      // Appel de la méthode pour avoir la météo en rensignant le longitude et latitude obtenue précédemment
      final weatherJson = await _apiCalling.getWeather(
        latValue.toDouble(),
        lonValue.toDouble(),
      );

      // On met à jour le carton avec les informations reçu de l'appel API
      setState(() {
        // typage sécurisé + nullable
        // as 	Typecast (also used to specify library prefixes ) => https://dart.dev/language/operators
        cityName = weatherJson['name'] as String?;
        country = weatherJson['sys']?['country'] as String?;
        description = weatherJson['weather']?[0]?['description'] as String?;
        iconCode = weatherJson['weather']?[0]?['icon'] as String?;
        temp = (weatherJson['main']?['temp'] as num?)?.toDouble();
        feelsLike = (weatherJson['main']?['feels_like'] as num?)?.toDouble();
        wind = (weatherJson['wind']?['speed'] as num?)?.toDouble();
        message = '';
      });
    } catch (error) {
      setState(() {
        message = 'Erreur: ${error.toString()}';
        cityName = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildWeatherCard() {
    if (cityName == null) {
      return const SizedBox.shrink();
    }

    final iconUrl = iconCode != null
        ? 'https://openweathermap.org/img/wn/$iconCode@2x.png'
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (iconUrl != null)
                  Image.network(iconUrl, width: 80, height: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$cityName, ${country ?? ''}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _weatherStat('Temp', temp, '°C'),
                _weatherStat('Ressenti', feelsLike, '°C'),
                _weatherStat('Vent', wind, 'm/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherStat(String label, double? value, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Text(
          value != null ? '${value.toStringAsFixed(1)}$suffix' : '--',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Cherchez la météo de votre ville',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: inputCity,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => handleClick(),
                  decoration: InputDecoration(
                    hintText: 'Entrez Paris, Lyon, Marseille...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleClick,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Chercher la météo'),
                ),
              ),
              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              _buildWeatherCard(),
            ],
          ),
        ),
      ),
    );
  }
}
