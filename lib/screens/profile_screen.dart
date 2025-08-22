import 'dart:io'; // For File type
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // For ImagePicker
import '../core/design_system.dart'; // Import design system for new colors
import '../models/badge.dart';
import '../providers/auth_provider.dart';
import '../providers/badge_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../services/user_data_service.dart' hide userPreferencesProvider;
import '../widgets/badge_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added for User type

// Provider for the current user's avatar URL. This allows ProfileAvatar to update.
final avatarUrlProvider = StateProvider<String?>((ref) {
  // Initialize with the profile data if available
  return ref.watch(profileDataProvider).when(
        data: (profile) => profile['avatar_url'],
        loading: () => null,
        error: (_, __) => null,
      );
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileDataProvider);
    final user = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiel'),
        actions: [
          profileAsync.when(
            data: (profile) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to an edit screen, passing initial data
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EditProfileScreen(profileData: profile),
                ));
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          final avatarUrl = ref.watch(avatarUrlProvider);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(context, user, profile['name'], avatarUrl),
              const SizedBox(height: 32),
              _buildBadgesSection(ref),
              const SizedBox(height: 32),
              _buildSettingsSection(context),
              const SizedBox(height: 32),
              _buildQuickThemeToggle(context, ref),
              const SizedBox(height: 32),
              _buildSignOutButton(ref),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Fout bij laden van profiel: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, User? user, String? name, String? avatarUrl) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          name ?? (user?.email?.split('@').first ?? 'Utilisateur'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(WidgetRef ref) {
    final badges = ref.watch(badgesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verdiende Badges',
          style: Theme.of(ref.context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (badges.isEmpty)
          const Center(child: Text('Nog geen badges verdiend.'))
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: BadgeWidget(badge: badges[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notificatie instellingen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/notification-settings');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickThemeToggle(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);

    return GestureDetector(
      onTap: () {
        ref
            .read(userPreferencesProvider.notifier)
            .setDarkMode(!userPrefs.darkMode);
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppDesignSystem.neutral700
                : AppDesignSystem.neutral200,
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: userPrefs.darkMode
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppDesignSystem.secondaryBlue.withOpacity(0.3),
                      AppDesignSystem.secondaryBlueLight.withOpacity(0.2),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFA8E6CF).withOpacity(0.5),
                      const Color(0xFFDCEDC1).withOpacity(0.4),
                    ],
                  ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Icon(
                  userPrefs.darkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  key: ValueKey<bool>(userPrefs.darkMode),
                  color: userPrefs.darkMode
                      ? Colors.white
                      : AppDesignSystem.neutral800,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userPrefs.darkMode
                          ? 'Donkere modus ingeschakeld'
                          : 'Lichte modus ingeschakeld',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: userPrefs.darkMode
                                ? Colors.white
                                : AppDesignSystem.neutral800,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userPrefs.darkMode
                          ? 'Tik om lichte modus te activeren'
                          : 'Tik om donkere modus te activeren',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: userPrefs.darkMode
                                ? Colors.white.withOpacity(0.8)
                                : AppDesignSystem.neutral600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IgnorePointer(
                child: Switch(
                  value: userPrefs.darkMode,
                  onChanged: (value) {},
                  activeColor: AppDesignSystem.primaryGreenLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(WidgetRef ref) async {
    await ref.read(authServiceProvider).signOut();
  }

  Widget _buildSignOutButton(WidgetRef ref) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text('Uitloggen'),
      onPressed: () => _signOut(ref),
      style: ElevatedButton.styleFrom(
        foregroundColor: AppDesignSystem.error,
        backgroundColor: AppDesignSystem.error.withOpacity(0.1),
        elevation: 0,
      ),
    );
  }
}

// A new screen for editing the profile
class EditProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> profileData;
  const EditProfileScreen({super.key, required this.profileData});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  File? _selectedAvatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.profileData['name'] ?? '');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker()
          .pickImage(source: source, imageQuality: 80, maxWidth: 800);
      if (pickedFile != null) {
        setState(() {
          _selectedAvatarFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fout: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      String? newAvatarUrl;
      if (_selectedAvatarFile != null) {
        // First, delete old avatar if it exists
        final oldAvatarUrl = widget.profileData['avatar_url'];
        if (oldAvatarUrl != null) {
          await ref.read(userDataServiceProvider).deleteAvatar(oldAvatarUrl);
        }
        // Upload new one
        newAvatarUrl = await ref
            .read(userDataServiceProvider)
            .uploadAvatar(user.id, _selectedAvatarFile!);
      }

      await ref.read(userDataServiceProvider).updateProfile(
            userId: user.id,
            name: _nameController.text.trim(),
            avatarUrl:
                newAvatarUrl, // This will be null if no new avatar was picked
            explicitlyUpdateAvatar: _selectedAvatarFile != null,
          );

      // Refresh data and pop
      ref.invalidate(profileDataProvider);
      ref.read(avatarUrlProvider.notifier).state =
          newAvatarUrl ?? ref.read(avatarUrlProvider);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fout bij opslaan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiel Bewerken'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator(strokeWidth: 2)
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _selectedAvatarFile != null
                      ? FileImage(_selectedAvatarFile!)
                      : (widget.profileData['avatar_url'] != null
                          ? NetworkImage(widget.profileData['avatar_url'])
                          : null) as ImageProvider?,
                  child: _selectedAvatarFile == null &&
                          widget.profileData['avatar_url'] == null
                      ? Icon(Icons.person,
                          size: 50, color: Colors.grey.shade400)
                      : null,
                ),
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: PopupMenuButton<ImageSource>(
                    icon: const Icon(Icons.camera_alt, size: 20),
                    onSelected: _pickImage,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: ImageSource.gallery, child: Text('Galerij')),
                      const PopupMenuItem(
                          value: ImageSource.camera, child: Text('Camera')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Naam'),
          ),
        ],
      ),
    );
  }
}
