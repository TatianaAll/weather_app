# Weather App

Un projet Flutter simple pour afficher la météo d’une ville.

## Prérequis

- Flutter installé sur votre machine
- Un SDK Dart compatible (installé avec Flutter)
- Un émulateur Android/iOS ou un appareil physique connecté
- Une clé API OpenWeatherMap

## Installation

1. Ouvrez un terminal dans le dossier du projet :  
   `cd /Users/tatiana/Documents/B3Dev/appmobile/weather_app`

2. Installez les dépendances Flutter :  
   `flutter pub get`

## Configuration de l’API

Ce projet charge une clé API depuis un fichier `.env`.

1. Créez un fichier `.env` à la racine du projet si ce n’est pas déjà fait.
2. Ajoutez la ligne suivante :

```env
API_WEATHER=VOTRE_CLE_API_OPENWEATHERMAP
```

3. Assurez-vous que le fichier `.env` est déclaré comme asset dans `pubspec.yaml` :  

```yaml
flutter:
  assets:
    - .env
```

## Lancer l’application

```bash
flutter run
```

## Utilisation

- Saisissez un nom de ville dans le champ de recherche
- Appuyez sur le bouton `Chercher la météo`
- L’application affiche les informations météo reçues depuis OpenWeatherMap

## Débogage et erreurs courantes

- Si l’application ne démarre pas :  
  `flutter clean` puis `flutter pub get` et `flutter run`
- Si l’erreur indique que le fichier `.env` est introuvable :  
  vérifiez que `.env` existe bien à la racine du projet et qu’il est listé sous `assets`.
- Si vous obtenez une erreur liée à la clé API :  
  vérifiez que votre clé est valide et que `API_WEATHER` est bien défini.

## Structure du projet

- `lib/main.dart` : point d’entrée, interface utilisateur et logique de recherche
- `lib/http/api_calling.dart` : appels API météo et gestion des erreurs
- `pubspec.yaml` : dépendances et configuration Flutter
- `.env` : clé API privée (à ne pas committer)
