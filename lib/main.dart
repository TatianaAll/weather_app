import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // convertion des réponses JSON des API
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
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: .fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const MyHomePage(title: 'My weather app'),
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
  // on déclare mon controller pour récupérer le champs texte
  TextEditingController inputCity = TextEditingController();
  String results = "";
  // on met en async
  Future<void> handleClick() async {
    // récupération du nom de ville
    final city = inputCity.text;
    // on récupère la ville pour retourner les longitudes/latitudes

    // On génère l'URL de l'appel API avec le nom de la ville
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$city',
    );
    // Appel à l'api
    final response = await http.get(url);
    // Gestion des erreurs
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        results = data.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0), // ajout de padding
              child: TextField(
                obscureText: false,
                controller:
                    inputCity, // ajout d'un controller pour récupérer la value
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Renseignez votre ville',
                ),
              ),
            ),
            ElevatedButton(onPressed: handleClick, child: Text('Chercher')),
            Row(children: [Center(child: Text(results))]),
          ],
        ),
      ),
    );
  }
}
