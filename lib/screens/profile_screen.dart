import 'dart:io'; // For File type
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // For ImagePicker
import 'package:social_balans/models/badge.dart';
import 'package:social_balans/providers/badge_provider.dart';
import 'package:social_balans/widgets/badge_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added for User type
import '../providers/auth_provider.dart';
import '../services/user_data_service.dart';
import '../widgets/profile_avatar.dart';
import '../providers/challenge_provider.dart';
import '../providers/user_objective_provider.dart';
import '../models/challenge.dart'; // Import Challenge model for explicit typing

// Provider for the current user's avatar URL. This allows ProfileAvatar to update.
// It would typically fetch the URL from UserDataService or listen to profile changes.
// For now, it's a simple StateProvider, will be refined.
final avatarUrlProvider = StateProvider<String?>((ref) => null);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  File? _selectedAvatarFile;
  String? _initialName;
  String? _initialAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      try {
        final profileData =
            await ref.read(userDataServiceProvider).getProfile(user.id);
        _initialName = profileData['name'] ?? '';
        _nameController.text = _initialName!;
        _emailController.text = user.email ?? '';
        _initialAvatarUrl = profileData['avatar_url'];
        ref.read(avatarUrlProvider.notifier).state = _initialAvatarUrl;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fout bij laden profiel: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gebruiker niet gevonden")));
      return;
    }

    bool nameChanged = _initialName != _nameController.text.trim();
    bool avatarChanged = _selectedAvatarFile != null;

    if (_isEditing &&
        _formKey.currentState != null &&
        !_formKey.currentState!.validate()) {
      return; // Name form is active and invalid
    }

    if (!nameChanged && !avatarChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Geen wijzigingen om op te slaan.")));
      setState(() => _isEditing = false);
      return;
    }

    setState(() => _isLoading = true);
    String? newAvatarUrl = ref.read(avatarUrlProvider);
    bool avatarUpdateAttempted = false;

    try {
      if (avatarChanged) {
        avatarUpdateAttempted = true;
        // 1. Delete old avatar if exists
        final currentAvatarUrl = _initialAvatarUrl;
        if (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty) {
          try {
            await ref
                .read(userDataServiceProvider)
                .deleteAvatar(currentAvatarUrl);
          } catch (e) {
            debugPrint("Failed to delete old avatar: $e");
            // Non-critical, proceed with upload
          }
        }
        // 2. Upload new avatar
        newAvatarUrl = await ref
            .read(userDataServiceProvider)
            .uploadAvatar(user.id, _selectedAvatarFile!);
      }

      // 3. Update profile (name and/or new avatar URL)
      // We pass explicitlyUpdateAvatar only if an avatar operation (new upload or removal via _removeAvatar) was intended.
      // If only name changes, we don't want to accidentally nullify avatar_url if newAvatarUrl is null here.
      bool shouldUpdateProfileAvatar = avatarUpdateAttempted;

      // Only update name if it actually changed
      String? nameToSend = nameChanged ? _nameController.text.trim() : null;

      await ref.read(userDataServiceProvider).updateProfile(
            userId: user.id,
            name: nameToSend,
            avatarUrl:
                newAvatarUrl, // This will be the new URL if uploaded, or existing if only name changed (and no removal)
            explicitlyUpdateAvatar:
                shouldUpdateProfileAvatar, // True if we attempted an avatar change
          );

      ref.read(avatarUrlProvider.notifier).state = newAvatarUrl;
      _initialAvatarUrl = newAvatarUrl; // Update initial for next save
      _initialName =
          _nameController.text.trim(); // Update initial for next save
      _selectedAvatarFile = null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profiel succesvol bijgewerkt!')),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij opslaan profiel: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
          source: source, imageQuality: 80, maxWidth: 800, maxHeight: 800);
      if (pickedFile != null) {
        setState(() {
          _selectedAvatarFile = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Nieuwe avatar geselecteerd. Druk op Opslaan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij kiezen afbeelding: $e')),
        );
      }
    }
  }

  void _removeAvatar() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final String? currentAvatarUrl = ref.read(avatarUrlProvider);
    if (currentAvatarUrl == null || currentAvatarUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Geen avatar om te verwijderen.")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Delete from storage
      await ref.read(userDataServiceProvider).deleteAvatar(currentAvatarUrl);

      // 2. Update profile to set avatar_url to null
      await ref.read(userDataServiceProvider).updateProfile(
          userId: user.id, avatarUrl: null, explicitlyUpdateAvatar: true);

      ref.read(avatarUrlProvider.notifier).state = null;
      _initialAvatarUrl = null; // Update initial for next save
      _selectedAvatarFile = null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar succesvol verwijderd.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Fout bij verwijderen avatar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uitloggen'),
        content: const Text('Weet je zeker dat je wilt uitloggen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Uitloggen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authServiceProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for real-time updates
    final allChallenges = ref.watch(allChallengesProvider);
    final completedChallenges = allChallenges.where((c) => c.isDone).toList();
    final userObjective = ref.watch(userObjectiveProvider);
    final avatarUrl = ref.watch(avatarUrlProvider);
    // Initialize badge controller logic
    ref.watch(badgeControllerProvider);
    // Get the list of earned badges
    final earnedBadges = ref.watch(badgesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiel'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveProfile,
            ),
          ],
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar et informations de base
            _buildProfileHeader(ref.watch(authServiceProvider).currentUser),
            const SizedBox(height: 32),

            // Formulaire de profil
            _buildProfileForm(),
            const SizedBox(height: 32),

            // Statistiques utilisateur
            _buildUserStats(context),
            const SizedBox(height: 32),

            // Paramètres et actions
            _buildSettingsSection(),
            const SizedBox(height: 32),

            // Bouton de déconnexion
            _buildSignOutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    final currentAvatarUrlFromProvider = ref.watch(avatarUrlProvider);

    ImageProvider? backgroundImage;
    if (_selectedAvatarFile != null) {
      backgroundImage = FileImage(_selectedAvatarFile!);
    } else if (currentAvatarUrlFromProvider != null &&
        currentAvatarUrlFromProvider.isNotEmpty) {
      backgroundImage = NetworkImage(currentAvatarUrlFromProvider);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? () => _showAvatarOptions() : null,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: backgroundImage,
                child: backgroundImage == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _nameController.text.isEmpty
                  ? (user?.email?.split('@').first ?? 'Gebruiker')
                  : _nameController.text,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Foto wijzigen'),
                onPressed: _showAvatarOptions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Persoonlijke informatie',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Volledige naam',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Naam is verplicht';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              enabled: false, // Email kan niet worden gewijzigd
              decoration: const InputDecoration(
                labelText: 'E-mailadres',
                prefixIcon: Icon(Icons.email),
                helperText: 'E-mailadres kan niet worden gewijzigd',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(BuildContext context) {
    // Correctly watch the providers. Only activeDaysProvider is an AsyncValue.
    final List<Challenge> challenges = ref.watch(allChallengesProvider);
    final int streakCount = ref.watch(userStreakProvider);
    final AsyncValue<int> activeDaysAsyncValue = ref.watch(activeDaysProvider);

    // Calculate completed challenges directly from the state.
    final int challengeCount = challenges.where((c) => c.isDone).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _StatItem(
                label: 'Voltooid',
                value: challengeCount.toString(),
              ),
            ),
            const SizedBox(
              height: 40,
              child: VerticalDivider(),
            ),
            Expanded(
              child: _StatItem(
                label: 'Streak',
                value: streakCount.toString(),
              ),
            ),
            const SizedBox(
              height: 40,
              child: VerticalDivider(),
            ),
            // activeDaysAsyncValue is the only one that needs a .when() builder
            Expanded(
              child: activeDaysAsyncValue.when(
                data: (days) => _StatItem(
                  label: 'Dagen actief',
                  value: days.toString(),
                ),
                loading: () => const _StatItem(
                  label: 'Dagen actief',
                  value: '-',
                  isLoading: true,
                ),
                error: (err, stack) => const _StatItem(
                  label: 'Dagen actief',
                  value: '!',
                  hasError: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instellingen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaties'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to notification settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to privacy settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to help
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Over de app'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show about dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Uitloggen'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _signOut,
      ),
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Nieuwe foto maken'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Kies uit galerij'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (ref.watch(avatarUrlProvider) != null ||
                _selectedAvatarFile !=
                    null) // Show remove only if there is an avatar
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Avatar verwijderen',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesGrid(List<Badge> badges) {
    if (badges.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Voltooi uitdagingen om je eerste badge te verdienen!',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return BadgeWidget(badge: badges[index]);
      },
    );
  }

  Widget _buildStatsCard(
      int challengesCompleted, String objective, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistieken',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Voltooide uitdagingen: $challengesCompleted',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Doel: $objective',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isLoading;
  final bool hasError;

  const _StatItem({
    required this.label,
    required this.value,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget valueWidget;
    if (isLoading) {
      valueWidget = SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      );
    } else {
      valueWidget = Text(
        hasError ? '!' : value,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasError ? Colors.redAccent : null,
            ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        valueWidget,
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
