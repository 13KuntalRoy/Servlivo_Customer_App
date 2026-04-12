import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
          ),
          body: switch (state) {
            ProfileLoading() => const Center(child: CircularProgressIndicator()),
            ProfileError(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileCubit>().loadProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ProfileLoaded(:final profile) => _ProfileBody(profile: profile),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

class _ProfileBody extends StatefulWidget {
  final dynamic profile;

  const _ProfileBody({required this.profile});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  late final _nameCtrl = TextEditingController(text: widget.profile.name);
  late final _emailCtrl = TextEditingController(text: widget.profile.email);
  late final _phoneCtrl = TextEditingController(text: widget.profile.phone);
  bool _serviceAlertsEnabled = true;
  String _selectedLanguage = 'English';

  static const _prefKeyAlerts = 'service_alerts_enabled';
  static const _prefKeyLanguage = 'preferred_language';

  final _languages = const ['English', 'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Marathi'];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serviceAlertsEnabled = prefs.getBool(_prefKeyAlerts) ?? true;
      _selectedLanguage = prefs.getString(_prefKeyLanguage) ?? 'English';
    });
  }

  Future<void> _saveAlerts(bool value) async {
    setState(() => _serviceAlertsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyAlerts, value);
  }

  Future<void> _saveLanguage(String lang) async {
    setState(() => _selectedLanguage = lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyLanguage, lang);
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ..._languages.map((lang) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(lang),
                  trailing: _selectedLanguage == lang
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    _saveLanguage(lang);
                    Navigator.of(context).pop();
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Your profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Keep your contact details, address, and household preferences updated for faster bookings.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Verification badge — shown only when actually verified
          if (profile.isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 16, color: AppColors.secondary),
                  SizedBox(width: 6),
                  Text(
                    'Verified account',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_outlined, size: 16, color: Colors.orange),
                  SizedBox(width: 6),
                  Text(
                    'Account not verified',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          if (profile.referralCode.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.card_giftcard_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Referral code: ${profile.referralCode}',
                  style: const TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.divider,
                  backgroundImage: profile.avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(profile.avatarUrl)
                      : null,
                  child: profile.avatarUrl.isEmpty
                      ? Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 32, color: AppColors.textSecondary),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => context.read<ProfileCubit>().pickAndUploadAvatar(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Update profile photo',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),

          // Form fields
          _FormField(label: 'FULL NAME', icon: Icons.person_outline, controller: _nameCtrl),
          const SizedBox(height: 16),
          _FormField(label: 'EMAIL ADDRESS', icon: Icons.email_outlined, controller: _emailCtrl, readOnly: true),
          const SizedBox(height: 16),

          // Phone with verified badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PHONE NUMBER',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🇮🇳', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 4),
                              Text('+91', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 0),
                      ),
                    ),
                  ),
                  if (profile.isVerified) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.secondary),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check, size: 12, color: AppColors.secondary),
                          SizedBox(width: 4),
                          Text('Verified', style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Save button
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              return ElevatedButton.icon(
                onPressed: state is ProfileUpdating
                    ? null
                    : () => context.read<ProfileCubit>().updateProfile(
                          name: _nameCtrl.text.trim(),
                          phone: _phoneCtrl.text.trim(),
                        ),
                icon: state is ProfileUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const SizedBox.shrink(),
                label: const Text('Save changes →'),
              );
            },
          ),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.address),
            icon: const Icon(Icons.location_on_outlined),
            label: const Text('Manage saved addresses'),
          ),

          const Divider(height: 40),

          // Preferences
          Text('PREFERENCES', style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.5,
          )),
          const SizedBox(height: 12),

          _PrefItem(
            icon: Icons.language_outlined,
            label: 'Language',
            value: _selectedLanguage,
            onTap: _showLanguagePicker,
          ),
          const Divider(),
          _PrefItem(
            icon: Icons.notifications_outlined,
            label: 'Service alerts',
            trailing: Switch.adaptive(
              value: _serviceAlertsEnabled,
              onChanged: _saveAlerts,
              activeColor: AppColors.primary,
            ),
          ),

          const Divider(height: 40),

          // Logout
          TextButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool readOnly;

  const _FormField({
    required this.label,
    required this.icon,
    required this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            fillColor: readOnly ? AppColors.background : AppColors.surface,
          ),
        ),
      ],
    );
  }
}

class _PrefItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _PrefItem({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label),
      subtitle: value != null ? Text(value!, style: const TextStyle(color: AppColors.textSecondary)) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
