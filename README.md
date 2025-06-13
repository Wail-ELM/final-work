# Social Balans - Een App voor Digitaal Welzijn

**Social Balans** is een mobiele applicatie, ontwikkeld als een bachelorproef-project, met als doel gebruikers te helpen een gezondere en bewustere relatie met hun digitale apparaten op te bouwen. De app biedt tools voor het volgen van schermtijd en humeur, gepersonaliseerde analyses en uitdagingen om digitale gewoonten te verbeteren.


---

##  Kernfunctionaliteiten

-   **Gebruikersauthenticatie:** Veilig in- en uitloggen en profielbeheer via Supabase.
-   **Gepersonaliseerd Dashboard:** Een overzicht van de belangrijkste inzichten, inclusief wekelijkse schermtijd en humeurtrends.
-   **Humeur Tracking:** Gebruikers kunnen dagelijks hun humeur vastleggen, wat de basis vormt voor latere analyses.
-   **Schermtijd Analyse (Android):** Automatische tracking van de schermtijd op Android-apparaten via `app_usage`.
-   **Correlatieanalyse:** Een geavanceerd scherm dat de correlatie tussen schermtijd en humeur visualiseert, met gepersonaliseerde inzichten en aanbevelingen.
-   **Uitdagingen Systeem:** Een gamified systeem waar gebruikers uitdagingen kunnen aangaan om hun digitale gewoonten te verbeteren (bv. "Digitale Detox").
-   **Badge Systeem:** Gebruikers verdienen badges voor het voltooien van uitdagingen en het bereiken van mijlpalen.
-   **Gepersonaliseerde Instellingen:** Volledige controle over notificaties (dagelijkse herinneringen, challenge-updates) en app-thema (licht/donker).
-   **Lokale Data Persistentie:** Efficiënt gebruik van Hive voor het cachen van data zoals uitdagingen en humeur-entries, wat zorgt voor een snelle en offline-first ervaring.

---

##  Technische Architectuur & Stack

Dit project is gebouwd met een moderne en robuuste technische stack, gericht op schaalbaarheid en onderhoudbaarheid.

### **Technologieën**

-   **Framework:** [Flutter](https://flutter.dev/) (Cross-platform voor iOS & Android)
-   **Backend-as-a-Service (BaaS):** [Supabase](https://supabase.io/) (Authenticatie, Database, Opslag voor avatars)
-   **State Management:** [Riverpod](https://riverpod.dev/) (Een reactieve en robuuste oplossing voor state management)
-   **Lokale Database:** [Hive](https://docs.hivedb.dev/) (Een lichtgewicht en snelle NoSQL-database voor on-device opslag)
-   **Notificaties:** `flutter_local_notifications` voor geplande en on-demand meldingen.
-   **Grafieken & Visualisaties:** `fl_chart` voor het weergeven van data op een intuïtieve manier.
-   **Schermtijd Tracking (Android):** `app_usage`
-   **Codekwaliteit:** Strikte analyse-opties en een focus op professionele best practices.

### **Projectstructuur**

De codebase is georganiseerd volgens de feature-first benadering, wat de scheiding van verantwoordelijkheden bevordert.

```
/lib
|-- /core
|   |-- design_system.dart     # Thema's, kleuren, typografie
|-- /models                    # Data modellen (Challenge, MoodEntry, etc.)
|-- /providers                 # Riverpod providers (State Management)
|-- /screens                   # UI-schermen van de app
|   |-- /auth
|   |-- /settings
|   |-- modern_dashboard.dart
|   |-- ...
|-- /services                  # Business logic (NotificationService, AuthService, etc.)
|-- /widgets                   # Herbruikbare UI componenten (ChallengeCard, etc.)
|-- main.dart                  # Hoofdingang van de applicatie
```

---

## Installatie & Opstarten

Volg deze stappen om het project lokaal op te zetten en uit te voeren.

### **Vereisten**

-   Flutter SDK (v3.x.x of hoger)
-   Een Supabase-project (gratis tier is voldoende)
-   Android Studio of VS Code met de Flutter-plugin

### **Configuratie**

1.  **Clone de repository:**
    ```bash
    git clone https://your-git-repository-url.com/social-balans.git
    cd social-balans
    ```

2.  **Installeer de afhankelijkheden:**
    ```bash
    flutter pub get
    ```

3.  **Stel de omgevingsvariabelen in:**
    Maak een `.env` bestand aan in de root van het project en voeg je Supabase credentials toe. Deze worden gebruikt voor de communicatie met je backend.

    ```dotenv
    SUPABASE_URL=jouw-supabase-url
    SUPABASE_ANON_KEY=jouw-supabase-anon-key
    ```

4.  **Database Migraties (Supabase):**
    Zorg ervoor dat je Supabase-database de nodige tabellen bevat (`profiles`, `badges`, etc.). Voer de SQL-migraties uit die beschikbaar zijn in de `/supabase` map van dit project (indien van toepassing).

### **Uitvoeren van de Applicatie**

-   **Selecteer een emulator of een fysiek apparaat.**
-   **Voer de app uit vanuit je IDE of via de terminal:**
    ```bash
    flutter run
    ```
-   Om de app in debug-modus uit te voeren:
    ```bash
    flutter run --debug
    ```
---

##  Architecturale Beslissingen & Justificatie

-   **Riverpod als State Manager:** Gekozen vanwege de compile-time safety, de schaalbaarheid (providers kunnen andere providers lezen) en de duidelijke scheiding tussen UI en business logic. Het helpt complexe afhankelijkheden (zoals tussen instellingen en de notificatie service) op een elegante manier te beheren.
-   **Hive voor Lokale Cache:** Gekozen vanwege de uitzonderlijke snelheid en het minimale resourcegebruik in vergelijking met SQLite. Perfect voor het cachen van data die vaak wordt gelezen, zoals uitdagingen en humeur-entries, wat resulteert in een vlottere gebruikerservaring.
-   **Supabase als Backend:** Een all-in-one oplossing die de ontwikkeling versnelt door ingebouwde authenticatie, een realtime database en file storage te bieden. Dit stelde ons in staat om ons te concentreren op de app-logica in plaats van op backend-infrastructuur.
-   **Service-Oriented Architectuur:** De `services` laag bevat de kernlogica (bv. `NotificationService`, `AppUsageService`). Dit maakt de code testbaarder en zorgt ervoor dat de providers slank blijven en voornamelijk dienen als een brug tussen de UI en de services.

