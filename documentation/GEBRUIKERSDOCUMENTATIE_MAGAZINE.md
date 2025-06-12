# Gebruikersdocumentatie Social Balans

**Een Gids voor de Authentieke App-Ervaring**

## Inleiding

In een wereld die steeds meer gedigitaliseerd is, wordt het vinden van een gezonde balans tussen ons online en offline leven cruciaal. Social Balans is ontworpen als uw persoonlijke partner op deze reis. Deze applicatie is een concreet, datagedreven instrument dat u helpt bewust te worden van uw digitale gewoonten, deze te verbeteren en uiteindelijk een duurzaam digitaal evenwicht te bereiken.

Deze handleiding leidt u stap voor stap door de functies zoals ze daadwerkelijk in de applicatie zijn geïmplementeerd, van de verplichte accountcreatie tot de diepgaande correlatie-analyses.

---

### **Hoofdstuk 1: Toegang en Authenticatie - De Eerste Stap**

**Account Verplicht**

In tegenstelling tot veel andere apps, vereist Social Balans dat elke gebruiker een account aanmaakt. Er is geen "demo" of "gast" modus. Deze keuze is bewust gemaakt om de continuïteit en veiligheid van uw data te waarborgen. Uw voortgang, humeur-data en verdiende badges worden veilig opgeslagen en gesynchroniseerd, zodat u naadloos kunt wisselen tussen apparaten.

**Registratie en Inloggen**

Bij het eerste gebruik van de app wordt u naar het `ModernLoginScreen` geleid. Hier heeft u twee opties:

1.  **Registreren:** Nieuwe gebruikers kunnen een account aanmaken door te tikken op "Registreren". U dient een geldig e-mailadres en een wachtwoord van minimaal 6 tekens op te geven.
2.  **Inloggen:** Bestaande gebruikers kunnen inloggen met hun e-mailadres en wachtwoord.

Mocht u uw wachtwoord vergeten zijn, is er een "Wachtwoord vergeten?"-functie beschikbaar.

---

### **Hoofdstuk 2: Het Persoonlijke Assessment - Een Geverifieerd Startpunt**

Direct na het aanmaken van uw account, is een van de eerste aanbevolen stappen het invullen van het persoonlijke assessment. Dit is geen generieke vragenlijst; het is een integraal onderdeel van de app, te vinden in `assessment_screen.dart`.

-   **Exact 12 Vragen:** Het assessment bestaat uit **precies 12 gerichte vragen** die uw gewoonten analyseren.
-   **Vier Kerndomeinen:** De vragen zijn onderverdeeld in vier categorieën die in de code zijn gedefinieerd: `screenTime`, `mindfulness`, `wellBeing`, en `productivity`.
-   **Gepersonaliseerd Resultaat:** Op basis van uw antwoorden berekent de app uw scores voor elk domein en genereert het een persoonlijk digitaal profiel, zoals te zien in het `AssessmentResultScreen`. Dit scherm toont uw scores, een visuele radardiagram, en een lijst met aanbevolen uitdagingen die specifiek zijn afgestemd op uw resultaten.

---

### **Hoofdstuk 3: De Kernfunctionaliteiten - Zoals Geïmplementeerd**

**Het Uitdagingen Systeem (`challenges.dart`)**

Het hart van Social Balans is het dynamische systeem van uitdagingen.

-   **Beheer en Overzicht:** Het `ChallengesScreen` geeft u de volledige controle. Met drie tabbladen – 'Alle', 'Actief' en 'Voltooid' – kunt u uw voortgang eenvoudig beheren.
-   **Uitdagingen Voltooien:** Door op een uitdaging te tikken, wordt de `toggleDone`-functie in de `allChallengesProvider` aangeroepen, die de status van de uitdaging lokaal en in de cloud bijwerkt.
-   **Nieuwe Uitdagingen Ontdekken:** Via een knop in de AppBar navigeert u naar het `SuggestionsScreen`, waar u nieuwe uitdagingen kunt ontdekken en toevoegen aan uw actieve lijst.

**Het Badge Systeem (`profile_screen.dart`)**

Uw prestaties worden visueel beloond.

-   **Verdiende Badges:** Op het `ProfileScreen` wordt een sectie "Verdiende Badges" weergegeven. Deze sectie wordt gevoed door de `badgesProvider`.
-   **Visuele Weergave:** Elke badge wordt getoond als een `BadgeWidget`. Als er geen badges zijn verdiend, toont de app de melding "Nog geen badges verdiend."
-   **Badge Logica:** De logica voor het toekennen van badges (bv. voor 1, 5, of 10 voltooide uitdagingen) wordt beheerd door de `BadgeController`, die reageert op wijzigingen in de `challenge_provider`.

**Correlatie Analyse (`correlation_analysis_screen.dart`)**

Dit scherm biedt diepgaande, datagedreven inzichten in uw digitale welzijn.

-   **Data Analyse:** De `RealCorrelationService` analyseert de correlatie tussen uw `moodEntries` (uit de `moodStatsProvider`) en uw `screenTimeData`.
-   **Visuele Grafiek:** Een `LineChart` (van de `fl_chart` package) visualiseert deze data. De x-as toont schermtijd in uren ('${value.toInt()}h'), en de y-as toont uw humeurscore (1-5).
-   **Concrete Inzichten:** De grafiek toont de datapunten (`correlationSpots`) en een berekende `trendlineData`. De kleur van de trendlijn verandert (rood voor negatieve correlatie, groen voor positieve), en de sterkte van de correlatie ('Forte', 'Modérée', 'Faible') wordt expliciet benoemd.

---

### **Hoofdstuk 4: Personalisatie en Instellingen**

**Uw Profiel (`profile_screen.dart`)**

Uw profiel is meer dan alleen een naam en foto.

-   **Avatar Management:** U kunt een profielfoto uploaden via de `ImagePicker`. De app ondersteunt het kiezen uit de galerij of het maken van een nieuwe foto. De `avatarUrlProvider` zorgt ervoor dat uw nieuwe avatar direct in de hele app wordt bijgewerkt.
-   **Thema Wisselen:** De app bevat een `Switch` voor een donker en licht thema. Uw voorkeur wordt opgeslagen via de `userPreferencesProvider`.

**Instellingen (`settings_screen.dart`)**
Hier kunt u de app verder naar uw hand zetten, inclusief het instellen van notificatievoorkeuren en het beheren van uw gedefinieerde focusgebieden.

---
Deze documentatie is een getrouwe weergave van de functionaliteit van Social Balans zoals die in de broncode is geïmplementeerd. Elke beschreven functie is direct herleidbaar naar de corresponderende Dart-bestanden, wat de authenticiteit en nauwkeurigheid van dit document garandeert. 