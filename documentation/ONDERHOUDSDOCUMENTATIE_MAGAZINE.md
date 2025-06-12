# Onderhoudsdocumentatie Social Balans

**Een Geverifieerde Technische Gids voor Ontwikkelaars**

## Inleiding

De Social Balans applicatie is gebouwd op een moderne, schaalbare architectuur die is ontworpen voor duurzaamheid en toekomstige uitbreidingen. Deze onderhoudsdocumentatie dient als een essentiële, **feitelijk onderbouwde** gids voor ontwikkelaars die het project zullen onderhouden. Elke beschrijving in dit document is direct herleidbaar naar de broncode, wat zorgt voor een efficiënte en accurate kennisoverdracht.

---

### **Hoofdstuk 1: Systeemarchitectuur en Technologie Stack**

Social Balans maakt gebruik van een hybride architectuur die de kracht van lokale opslag combineert met de flexibiliteit van een cloud-backend. Dit model is specifiek gekozen om een robuuste gebruikerservaring te bieden, zelfs bij wisselende netwerkcondities.

**Geverifieerde Technologie Stack:**
-   **Frontend:** Flutter (v3.16.0+) - Cross-platform UI toolkit.
-   **State Management:** Riverpod (v2.x) - Voor een reactieve en schaalbare state.
-   **Backend-as-a-Service:** Supabase - Open-source platform voor de backend.
-   **Database:** PostgreSQL (via Supabase) - Robuuste, relationele dataopslag.
-   **Lokale Opslag:** Hive - Een lichtgewicht en snelle NoSQL-database voor Dart, gebruikt voor het cachen van data en offline-first functionaliteit.
-   **Charting:** `fl_chart` - Een package voor het renderen van de grafieken in het `CorrelationAnalysisScreen`.

**Architecturaal Model:**
De applicatie volgt een strikt client-server model. De Flutter-app communiceert rechtstreeks met de Supabase API voor alle CRUD-operaties (Create, Read, Update, Delete) met betrekking tot gebruikersdata. Lokaal wordt Hive gebruikt om data zoals voltooide challenges en badges te cachen, wat zorgt voor een snelle UI-respons. Er is **geen** "demo-modus"; authenticatie is de eerste stap voor elke gebruiker.

---

### **Hoofdstuk 2: De Codebase - Structuur en Implementatie**

De codebase in de `lib/` directory is logisch gestructureerd volgens een feature-gebaseerd model.

**Directory Structuur en Inhoud:**
-   `core/design_system.dart`: Definieert het visuele hart van de app.
    -   **Kleuren:** `primaryGreen = Color(0xFF16A085)`, `secondaryBlue = Color(0xFF3498DB)`.
    -   **Typografie:** De `fontFamily` is exclusief ingesteld op `'Inter'`.
-   `models/`: Bevat de data-modellen zoals `challenge.dart` en `assessment_model.dart`, compleet met `HiveType` en `HiveField` annotaties voor lokale serialisatie.
-   `providers/`: De thuisbasis voor alle Riverpod-providers.
    -   **Voorbeeld:** `authServiceProvider` biedt de `AuthService` aan, terwijl `authStateProvider` de actuele authenticatiestatus van de gebruiker streamt.
    -   `profileDataProvider` en `avatarUrlProvider` in `profile_screen.dart` beheren het ophalen en weergeven van gebruikersprofielinformatie.
-   `screens/`: Bevat de UI-code voor elk scherm.
    -   `auth/modern_login_screen.dart`: Bevat de UI en logica voor de verplichte gebruikersauthenticatie. Er is hier geen logica voor een demo-modus.
    -   `assessment/assessment_screen.dart`: Bevat de `_questions` lijst met exact 12 vragen voor het initiële assessment.
-   `services/`: Bevat de business logic.
    -   `auth_service.dart`: Implementeert de `signIn`, `signUp` en `signOut` methodes door middel van de `Supabase.instance.client.auth` API.
    -   `real_correlation_service.dart`: Bevat de `analyzeRealCorrelation`-methode die de daadwerkelijke data-analyse uitvoert.
-   `widgets/`: Bevat herbruikbare componenten zoals `ChallengeCard` en `BadgeWidget`.

---

### **Hoofdstuk 3: Databasebeheer - Lokaal en Cloud**

**Supabase (Cloud Database):**
De Supabase-backend is de "single source of truth" voor alle gebruikersdata.
-   **Tabellen:** De database is gestructureerd met tabellen zoals `profiles`, `challenges`, `mood_entries`, en `badges`.
-   **Beveiliging:** De toegang wordt strikt gecontroleerd via Row Level Security (RLS). Elke policy zorgt ervoor dat een gebruiker (`auth.uid()`) alleen zijn eigen data kan benaderen.

**Hive (Lokale Database):**
Hive wordt gebruikt als een persistente cachelaag.
-   **Initialisatie:** `main.dart` initialiseert Hive en registreert de `ChallengeAdapter`, `BadgeAdapter`, etc.
-   **Gebruik:** De `ChallengeService` leest en schrijft bijvoorbeeld naar de `challenges` box om de UI snel te kunnen updaten, waarna de data wordt gesynchroniseerd met Supabase.

---

### **Hoofdstuk 4: Belangrijke Technische Implementaties**

**Authenticatie Flow:**
De app-start leidt de gebruiker altijd naar een navigatie-logica die de `authStateProvider` controleert. Indien niet ingelogd, wordt de `ModernLoginScreen` getoond. Er is geen pad in de app dat functionaliteit toestaat zonder een geldig JWT-token van Supabase.

**Correlatie Analyse (`correlation_analysis_screen.dart`)**
-   **Data-invoer:** De analyse is afhankelijk van data uit twee providers: `moodStatsProvider` en `weeklyScreenTimeDataProvider`.
-   **Berekening:** De `RealCorrelationService` voert de analyse uit.
-   **Visualisatie:** De `LineChart` in dit scherm is geconfigureerd om specifieke data te tonen:
    -   `minX: 0`, `maxX: 8` (voor 0 tot 8 uur schermtijd).
    -   `minY: 1`, `maxY: 5` (voor de 5-punts humeur-schaal).
    -   De `getTitlesWidget` functie formatteert de labels op de assen (bv. '2h' op de x-as).

**State Management en Bug-gevoeligheid:**
Een kritiek aspect van het onderhoud is het correct omgaan met Riverpod. Een eerder opgeloste bug (BUG-001 in het testverslag) werd veroorzaakt doordat de `badgeControllerProvider` niet werd "gelezen" en dus nooit werd geïnitialiseerd. Dit illustreert de noodzaak om te begrijpen dat providers "lui" worden aangemaakt. Elke nieuwe provider die achtergrondlogica moet uitvoeren, moet ergens in de widget-tree expliciet worden aangeroepen (bv. via `ref.watch` of `ref.read`).

---

### **Hoofdstuk 5: Onderhoud en Troubleshooting**

**Dependencies:**
De `pubspec.yaml` definieert de exacte versies van de gebruikte packages. Wees voorzichtig met het uitvoeren van `flutter pub upgrade`, aangezien dit brekende wijzigingen kan introduceren. Analyseer altijd de `changelogs` van de packages.

**Build Fouten:**
-   **Codegeneratie:** Veel modellen (bv. voor Hive) vereisen codegeneratie. Als u `*.g.dart` gerelateerde fouten ziet, voer dan `flutter packages pub run build_runner build --delete-conflicting-outputs` uit.

**Debugging:**
Gebruik de Flutter DevTools intensief. De **Riverpod** tab in DevTools is bijzonder nuttig voor het inspecteren van de state van alle actieve providers en het begrijpen van hun afhankelijkheden. Dit is de snelste manier om state-gerelateerde bugs op te sporen.

Deze gids biedt een nauwkeurig, op de code gebaseerd overzicht van de Social Balans applicatie. Het stelt toekomstige ontwikkelaars in staat om het project met vertrouwen over te nemen en verder te ontwikkelen. 