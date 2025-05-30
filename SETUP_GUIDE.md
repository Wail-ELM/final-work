# 🚀 Guide de Configuration Social Balans

## 📝 Étape 1 : Créer le fichier .env

1. Créez un fichier `.env` à la racine du projet `final_work/`
2. Ajoutez vos clés Supabase :

```
SUPABASE_URL=https://[VOTRE-PROJET-ID].supabase.co
SUPABASE_ANON_KEY=[VOTRE-ANON-KEY]
```

## 🗄️ Étape 2 : Configurer Supabase

### 2.1 Créer un compte et un projet
1. Allez sur [app.supabase.com](https://app.supabase.com)
2. Créez un nouveau projet "social-balans"
3. Attendez que le projet soit prêt (2-3 minutes)

### 2.2 Récupérer vos clés
1. Settings → API
2. Copiez `Project URL` et `anon public`
3. Mettez-les dans votre `.env`

### 2.3 Exécuter les scripts SQL
1. Dans Supabase Dashboard, allez dans SQL Editor
2. Créez une nouvelle requête
3. Copiez-collez le contenu de `supabase/create_tables.sql`
4. Exécutez (Run)
5. Faites de même avec `supabase/functions.sql`

## 📱 Étape 3 : Préparer l'application Flutter

### 3.1 Installer les dépendances
```bash
cd final_work
flutter pub get
```

### 3.2 Ajouter le logo Google
Téléchargez une image du logo Google et placez-la dans :
```
assets/images/google_logo.png
```

### 3.3 Vérifier la configuration
```bash
flutter doctor
```

## 🏃 Étape 4 : Lancer l'application

### 4.1 Sur émulateur/simulateur
```bash
flutter run
```

### 4.2 Sur appareil physique
1. Activez le mode développeur sur votre téléphone
2. Connectez-le par USB
3. ```bash
   flutter run
   ```

## 🔧 Étape 5 : Configuration Google Sign-In (Optionnel)

### 5.1 Android
1. Générez un SHA-1 :
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Ajoutez dans Firebase Console ou Supabase Dashboard

### 5.2 iOS
1. Configurez dans Xcode
2. Ajoutez URL scheme dans Info.plist

## ✅ Étape 6 : Tester l'application

### Flux de test recommandé :
1. **Inscription** : Créez un compte test
2. **Connexion** : Vérifiez la connexion
3. **Humeur** : Ajoutez quelques entrées d'humeur
4. **Défis** : Créez un défi personnel
5. **Statistiques** : Vérifiez les graphiques

## 🛠️ Étape 7 : Debugging

### Problèmes courants :

**Erreur de connexion Supabase :**
- Vérifiez vos clés dans `.env`
- Assurez-vous que RLS est activé

**Build échoue :**
```bash
flutter clean
flutter pub get
flutter run
```

**Hot reload ne fonctionne pas :**
- Redémarrez l'app complètement (R majuscule)

## 📊 Étape 8 : Monitorer avec Supabase

1. **Logs** : Database → Logs pour voir les requêtes
2. **Auth** : Authentication → Users pour voir les utilisateurs
3. **Data** : Table Editor pour voir les données

## 🎯 Prochaines étapes

### Fonctionnalités à ajouter :
1. **Notifications push** avec OneSignal
2. **Export de données** en CSV/PDF
3. **Mode sombre** (déjà préparé !)
4. **Widgets** pour l'écran d'accueil

### Optimisations :
1. **Cache** : Implémenter plus de cache Hive
2. **Images** : Compression des avatars
3. **Performance** : Lazy loading des listes

## 💡 Tips de développement

### Structure recommandée pour nouvelles fonctionnalités :
```
lib/
  features/
    nouvelle_feature/
      models/
      screens/
      widgets/
      providers/
```

### Tests :
```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/
```

## 🚀 Déploiement

### Android :
```bash
flutter build apk --release
# ou pour un bundle :
flutter build appbundle --release
```

### iOS :
```bash
flutter build ios --release
# Puis upload avec Xcode
```

### Web :
```bash
flutter build web --release
# Deploy sur Netlify/Vercel
```

## 📞 Support

- Documentation Flutter : [flutter.dev](https://flutter.dev)
- Documentation Supabase : [supabase.com/docs](https://supabase.com/docs)
- Votre code est dans : `C:\Users\wail1\Desktop\final_work\final_work`

Bonne chance avec Social Balans ! 🎉 