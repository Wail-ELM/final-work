# Guide d'Installation - Social Balans

## Prérequis

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Un compte Supabase
- Android Studio ou VS Code avec extensions Flutter

## Installation

### 1. Cloner le projet
```bash
git clone <repository-url>
cd final_work
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Configuration Supabase

1. Créez un nouveau projet sur [supabase.com](https://supabase.com)
2. Copiez les clés d'API
3. Créez un fichier `.env` à la racine du projet :

```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 4. Configuration de la base de données

Exécutez les scripts SQL dans l'ordre suivant dans votre dashboard Supabase :

1. `supabase/schema.sql` - Création des tables
2. `supabase/functions.sql` - Fonctions utilitaires

### 5. Lancer l'application

```bash
# Pour le développement web
flutter run -d chrome

# Pour Android
flutter run -d android

# Pour iOS
flutter run -d ios
```

## Structure du projet

```
lib/
├── constants/     # Constantes de l'application
├── models/        # Modèles de données
├── providers/     # Providers Riverpod
├── screens/       # Écrans de l'application
├── services/      # Services (API, auth, etc.)
├── theme.dart     # Thème de l'application
└── main.dart      # Point d'entrée
```

## Dépannage

### Erreur d'authentification
- Vérifiez que les clés Supabase sont correctes
- Assurez-vous que les tables sont créées
- Vérifiez que l'inscription est activée dans Supabase

### Erreur de compilation
```bash
flutter clean
flutter pub get
```

## Support

Pour toute question, consultez la documentation ou créez une issue sur le repository. 