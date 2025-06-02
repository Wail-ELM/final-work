# 🌟 Social Balans - Digital Wellness App

![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-beta-yellow.svg)

## 📱 Aperçu

**Social Balans** est une application Flutter révolutionnaire qui aide les utilisateurs à améliorer leur bien-être digital en suivant leur humeur, en gérant leur temps d'écran et en relevant des défis personnalisés.

### ✨ Fonctionnalités Principales

#### 🎭 **Tracking d'Humeur Intelligent**
- Enregistrement quotidien de l'humeur avec 5 niveaux émotionnels
- Notes personnelles pour contextualiser les émotions
- Animations fluides et feedback instantané
- Synchronisation cloud + cache local pour offline

#### 🎯 **Système de Défis Gamifié**
- Création de défis personnalisés (temps d'écran, concentration, notifications)
- Suivi de progression en temps réel
- Système de badges et récompenses
- Durées flexibles (3 à 30 jours)

#### 📊 **Analytics & Insights**
- Dashboard interactif avec statistiques en temps réel
- Graphiques de tendances d'humeur
- Corrélations humeur/temps d'écran
- Suggestions personnalisées basées sur l'IA

#### 👤 **Profil Utilisateur**
- Gestion complète du profil
- Avatar personnalisable
- Statistiques personnelles
- Paramètres de confidentialité

## 🚀 Technologies Utilisées

- **Frontend**: Flutter 3.0+ avec Riverpod
- **Backend**: Supabase (PostgreSQL + Auth)
- **Cache Local**: Hive
- **Charts**: fl_chart
- **Animations**: Lottie + Custom Animations

## 🛠 Installation

```bash
# Cloner le repository
git clone https://github.com/yourusername/social-balans.git

# Installer les dépendances
cd social-balans
flutter pub get

# Générer les fichiers Hive
flutter packages pub run build_runner build

# Lancer l'app
flutter run
```

## 📁 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée
├── models/                   # Modèles de données
│   ├── mood_entry.dart      # Entrées d'humeur
│   ├── challenge.dart       # Défis
│   └── screen_time_entry.dart
├── screens/                  # Écrans de l'app
│   ├── dashboard.dart       # Dashboard principal
│   ├── mood_entry_screen.dart
│   ├── challenge_creation_screen.dart
│   ├── challenges.dart
│   ├── stats_screen.dart
│   └── profile_screen.dart
├── providers/               # State management
│   ├── mood_provider.dart
│   ├── challenge_provider.dart
│   └── auth_provider.dart
├── services/               # Services
│   ├── auth_service.dart
│   └── user_data_service.dart
└── widgets/               # Widgets réutilisables
```

## 🎨 Captures d'Écran

### Dashboard Principal
- Vue d'ensemble des statistiques
- Défis actifs
- Graphiques de tendances
- Citations motivantes

### Ajout d'Humeur
- Interface intuitive avec emojis
- Animations de confirmation
- Notes optionnelles
- Sauvegarde instantanée

### Création de Défis
- Formulaire guidé étape par étape
- Aperçu en temps réel
- Catégories personnalisables
- Durées flexibles

## 🔥 Fonctionnalités Avancées

### Synchronisation Offline/Online
- Cache local avec Hive pour utilisation offline
- Synchronisation automatique avec Supabase
- Résolution intelligente des conflits

### Animations Personnalisées
- Transitions fluides entre écrans
- Feedback visuel pour chaque action
- Animations de célébration pour les accomplissements

### Intelligence Artificielle
- Détection de patterns comportementaux
- Suggestions personnalisées
- Prédictions basées sur l'historique

## 📈 Roadmap

- [ ] Notifications push intelligentes
- [ ] Mode sombre complet
- [ ] Export de données (PDF/CSV)
- [ ] Intégration Apple Health/Google Fit
- [ ] Version web responsive
- [ ] API publique pour développeurs

## 🤝 Contribution

Les contributions sont les bienvenues ! Consultez notre guide de contribution pour commencer.

## 📄 License

Ce projet est sous license MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

- Flutter Team pour le framework incroyable
- Supabase pour le backend scalable
- La communauté open source

---

**Développé avec ❤️ pour améliorer le bien-être digital**