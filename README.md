# Social Balans

Une application Flutter pour gérer l'équilibre entre vie sociale et temps d'écran.

## Configuration

1. Créez un fichier `.env` à la racine du projet avec les variables suivantes :

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

2. Installez les dépendances :

```bash
flutter pub get
```

3. Lancez l'application :

```bash
flutter run
```

## Fonctionnalités

- Suivi de l'humeur quotidienne
- Gestion des défis personnels
- Statistiques détaillées
- Suggestions personnalisées

## Architecture : Pourquoi Supabase ?

Nous avons choisi **Supabase** plutôt que Firebase pour les raisons suivantes :

### ✅ Avantages de Supabase pour ce projet

1. **Base de données relationnelle (PostgreSQL)**
   - Parfait pour les relations complexes (users → moods → challenges)
   - Requêtes SQL puissantes pour les statistiques

2. **Open Source**
   - Possibilité de self-host pour les données sensibles de santé mentale
   - Pas de vendor lock-in

3. **Row Level Security (RLS)**
   - Sécurité granulaire native au niveau base de données
   - Les utilisateurs ne voient que leurs propres données

4. **Coûts prévisibles**
   - Modèle de pricing transparent
   - Gratuit pour les petits projets

5. **Stockage intégré**
   - Pour les avatars et futures images

### 🔥 Quand choisir Firebase ?

Firebase serait préférable si vous aviez besoin de :
- Analytics et Crashlytics intégrés
- Notifications push natives
- ML Kit pour l'IA on-device
- Écosystème Google complet

## Structure des données

```sql
-- Utilisateurs (géré par Supabase Auth)
-- Profils
profiles (id, name, email, avatar_url, created_at, updated_at)

-- Entrées d'humeur
mood_entries (id, user_id, mood_value, note, created_at)

-- Temps d'écran
screen_time_entries (id, user_id, app_name, duration, date, created_at)

-- Défis
challenges (id, user_id, title, description, category, start_date, end_date, is_done, created_at, updated_at)
```

## Erreurs corrigées

- ✅ Correction des imports Supabase
- ✅ Mise à jour des types User (uid → id)
- ✅ Correction des propriétés MoodEntry
- ✅ Remplacement de withOpacity par withValues
- ✅ Création des dossiers d'assets
- ✅ Correction des imports de test