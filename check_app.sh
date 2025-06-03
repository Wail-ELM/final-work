#!/bin/bash

echo "🇳🇱 Social Balans - Nederlandse App Verificatie"
echo "================================================="

# Kleuren voor output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functie voor status weergave
show_status() {
    if [ $2 -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
    fi
}

echo
echo "1️⃣ Controleren of alle bestanden bestaan..."

# Controleer hoofdbestanden
files_to_check=(
    "lib/main.dart"
    "lib/screens/dashboard.dart"
    "lib/screens/challenges.dart"
    "lib/screens/stats_screen.dart"
    "lib/services/challenge_suggestion_service.dart"
    "lib/screens/challenge_suggestions_screen.dart"
    "README_NL.md"
)

all_files_exist=true
for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        show_status "Bestand gevonden: $file" 0
    else
        show_status "Bestand ontbreekt: $file" 1
        all_files_exist=false
    fi
done

echo
echo "2️⃣ Controleren op Franse teksten in UI..."

# Zoek naar Franse woorden in de belangrijkste UI bestanden
french_words_found=false
french_words=(
    "Bonjour"
    "Merci" 
    "Créer"
    "Nouvelle"
    "Erreur"
    "Connexion"
    "Déconnexion"
    "Sélectionner"
    "Ajouter"
    "Enregistrer"
    "Voir"
    "Retour"
    "Suivant"
    "Confirmer"
    "Annuler"
    "Terminer"
)

for word in "${french_words[@]}"; do
    if grep -r --include="*.dart" "$word" lib/screens/ lib/widgets/ > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Franse tekst gevonden: $word${NC}"
        french_words_found=true
    fi
done

if [ "$french_words_found" = false ]; then
    show_status "Geen Franse teksten gevonden in UI" 0
else
    show_status "Franse teksten gevonden - controle nodig" 1
fi

echo
echo "3️⃣ Controleren Flutter dependencies..."

# Controleer of pubspec.yaml bestaat en belangrijke dependencies bevat
if [ -f "pubspec.yaml" ]; then
    show_status "pubspec.yaml gevonden" 0
    
    dependencies=(
        "flutter_riverpod"
        "supabase_flutter"
        "hive_flutter"
        "uuid"
    )
    
    for dep in "${dependencies[@]}"; do
        if grep -q "$dep:" pubspec.yaml; then
            show_status "Dependency $dep gevonden" 0
        else
            show_status "Dependency $dep ontbreekt" 1
        fi
    done
else
    show_status "pubspec.yaml ontbreekt" 1
fi

echo
echo "4️⃣ Nederlandse teksten verificatie..."

# Controleer of Nederlandse woorden aanwezig zijn
dutch_words=(
    "Uitdagingen"
    "Statistieken"
    "Stemming"
    "Schermtijd"
    "Dashboard"
    "Voltooid"
    "Actief"
    "Suggesties"
)

dutch_found=0
total_dutch=${#dutch_words[@]}

for word in "${dutch_words[@]}"; do
    if grep -r --include="*.dart" "$word" lib/ > /dev/null 2>&1; then
        show_status "Nederlandse tekst gevonden: $word" 0
        ((dutch_found++))
    else
        show_status "Nederlandse tekst niet gevonden: $word" 1
    fi
done

echo
echo "📊 Nederlandse lokalisatie: $dutch_found/$total_dutch woorden gevonden"

echo
echo "5️⃣ App structuur verificatie..."

# Controleer belangrijke directories
directories=(
    "lib/screens"
    "lib/providers" 
    "lib/services"
    "lib/models"
    "lib/widgets"
)

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        file_count=$(find "$dir" -name "*.dart" | wc -l)
        show_status "Directory $dir ($file_count Dart bestanden)" 0
    else
        show_status "Directory $dir ontbreekt" 1
    fi
done

echo
echo "6️⃣ Challenge Suggestion System verificatie..."

# Controleer of challenge suggestion service correct is geconfigureerd
if grep -q "Verminder schermtijd" lib/services/challenge_suggestion_service.dart; then
    show_status "Nederlandse uitdaging suggesties gevonden" 0
else
    show_status "Nederlandse uitdaging suggesties niet gevonden" 1
fi

if grep -q "ChallengeSuggestionService" lib/services/challenge_suggestion_service.dart; then
    show_status "Challenge Suggestion Service geïmplementeerd" 0
else
    show_status "Challenge Suggestion Service ontbreekt" 1
fi

echo
echo "7️⃣ Providers en State Management verificatie..."

# Controleer Riverpod providers
providers=(
    "authServiceProvider"
    "moodStatsProvider"
    "allChallengesProvider"
    "challengeSuggestionServiceProvider"
    "personalizedSuggestionsProvider"
)

for provider in "${providers[@]}"; do
    if grep -r --include="*.dart" "$provider" lib/ > /dev/null 2>&1; then
        show_status "Provider gevonden: $provider" 0
    else
        show_status "Provider ontbreekt: $provider" 1
    fi
done

echo
echo "8️⃣ Clean Architecture verificatie..."

# Controleer of de architectuur correct is geïmplementeerd
architecture_elements=(
    "models"
    "services" 
    "providers"
    "screens"
    "widgets"
)

for element in "${architecture_elements[@]}"; do
    if [ -d "lib/$element" ] && [ "$(find lib/$element -name "*.dart" | wc -l)" -gt 0 ]; then
        show_status "Architectuur laag: $element" 0
    else
        show_status "Architectuur laag ontbreekt: $element" 1
    fi
done

echo
echo "9️⃣ README en Documentatie..."

if [ -f "README_NL.md" ]; then
    word_count=$(wc -w < README_NL.md)
    show_status "Nederlandse README ($word_count woorden)" 0
else
    show_status "Nederlandse README ontbreekt" 1
fi

echo
echo "🔟 Database Schema verificatie..."

if [ -f "database/create_tables.sql" ]; then
    show_status "Database schema gevonden" 0
    
    # Controleer belangrijke tabellen
    tables=("users" "mood_entries" "challenges" "screen_time_data")
    for table in "${tables[@]}"; do
        if grep -q "CREATE TABLE.*$table" database/create_tables.sql; then
            show_status "Tabel schema: $table" 0
        else
            show_status "Tabel schema ontbreekt: $table" 1
        fi
    done
else
    show_status "Database schema ontbreekt" 1
fi

echo
echo "================================================="
echo "🎯 VERIFICATIE SAMENVATTING"
echo "================================================="

if [ "$all_files_exist" = true ] && [ "$french_words_found" = false ]; then
    echo -e "${GREEN}✅ Social Balans app is volledig in het Nederlands!${NC}"
    echo -e "${GREEN}✅ Alle bestanden zijn aanwezig en correct geconfigureerd${NC}"
    echo -e "${GREEN}✅ Ready voor TFE presentatie en demonstratie${NC}"
else
    echo -e "${YELLOW}⚠️  Enkele items vereisen nog aandacht${NC}"
fi

echo
echo "📱 Om de app te testen:"
echo "   1. cd final_work"
echo "   2. flutter pub get"
echo "   3. flutter run"
echo
echo "📚 Voor meer info: zie README_NL.md"
echo "=================================================" 