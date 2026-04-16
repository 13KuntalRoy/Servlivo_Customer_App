import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../cubit/profile_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: switch (state) {
          ProfileLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          ProfileError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<ProfileCubit>().loadProfile()),
          ProfileLoaded(:final profile) => _ProfileBody(profile: profile),
          _ => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileBody extends StatefulWidget {
  final ProfileEntity profile;
  const _ProfileBody({required this.profile});

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  late final _nameCtrl  = TextEditingController(text: widget.profile.name);
  late final _emailCtrl = TextEditingController(text: widget.profile.email);
  // Strip country code so it doesn't duplicate the +91 prefix pill
  late final _phoneCtrl = TextEditingController(
      text: _stripCountryCode(widget.profile.phone));

  bool   _serviceAlerts    = true;
  String _selectedLanguage = 'English';

  static const _prefAlerts   = 'service_alerts_enabled';
  static const _prefLanguage = 'preferred_language';
  static const _languages    = [
    'English', 'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Marathi'
  ];

  static String _stripCountryCode(String phone) {
    if (phone.startsWith('+91')) return phone.substring(3).trim();
    if (phone.startsWith('91') && phone.length > 10) {
      return phone.substring(2).trim();
    }
    return phone;
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _serviceAlerts    = p.getBool(_prefAlerts)    ?? true;
      _selectedLanguage = p.getString(_prefLanguage) ?? 'English';
    });
  }

  Future<void> _saveAlerts(bool v) async {
    setState(() => _serviceAlerts = v);
    (await SharedPreferences.getInstance()).setBool(_prefAlerts, v);
  }

  Future<void> _saveLanguage(String lang) async {
    setState(() => _selectedLanguage = lang);
    (await SharedPreferences.getInstance()).setString(_prefLanguage, lang);
  }

  void _pickLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguageSheet(
        languages: _languages,
        selected: _selectedLanguage,
        onSelect: (l) { _saveLanguage(l); Navigator.pop(context); },
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text(
          "You'll need to log in again to book services.",
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
              style: TextStyle(fontFamily: 'Poppins',
                  color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign out',
              style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p        = widget.profile;
    final hasPrime = p.primeTier.isNotEmpty &&
        p.primeTier.toLowerCase() != 'none';
    final topPad   = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Header ──────────────────────────────────────────────────────
          _buildHeader(p, hasPrime, topPad),

          // ── Body ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Personal info
                _SectionTitle('PERSONAL INFO'),
                const SizedBox(height: 12),
                _StyledField(
                  icon: Icons.person_outline_rounded,
                  label: 'Full name',
                  ctrl: _nameCtrl,
                ),
                const SizedBox(height: 12),
                _StyledField(
                  icon: Icons.email_outlined,
                  label: 'Email address',
                  ctrl: _emailCtrl,
                  locked: true,
                ),
                const SizedBox(height: 12),
                _StyledPhoneField(
                  ctrl: _phoneCtrl,
                  verified: p.isVerified,
                ),

                const SizedBox(height: 14),

                // Save button
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (ctx, st) {
                    final busy = st is ProfileUpdating;
                    return _GradientButton(
                      label: 'Save changes',
                      icon: Icons.check_rounded,
                      busy: busy,
                      onTap: busy ? null : () =>
                          ctx.read<ProfileCubit>().updateProfile(
                            name:  _nameCtrl.text.trim(),
                            phone: _phoneCtrl.text.trim(),
                          ),
                    );
                  },
                ),

                // Referral
                if (p.referralCode.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionTitle('REFERRAL'),
                  const SizedBox(height: 10),
                  _ReferralCard(
                    code: p.referralCode,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: p.referralCode));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Code copied!',
                          style: TextStyle(fontFamily: 'Poppins')),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.primary,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ));
                    },
                  ),
                ],

                // Membership
                const SizedBox(height: 28),
                _SectionTitle('MEMBERSHIP'),
                const SizedBox(height: 10),
                _MembershipCard(
                  profile: p, hasPrime: hasPrime,
                  onTap: () => context.push(AppRoutes.prime),
                ),

                // Preferences
                const SizedBox(height: 28),
                _SectionTitle('PREFERENCES'),
                const SizedBox(height: 10),
                _WhiteCard(children: [
                  _NavRow(
                    icon: Icons.language_rounded,
                    bg: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF2E7D32),
                    label: 'Language',
                    value: _selectedLanguage,
                    onTap: _pickLanguage,
                  ),
                  _RowDivider(),
                  _ToggleRow(
                    icon: Icons.notifications_outlined,
                    bg: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFE65100),
                    label: 'Service alerts',
                    sub: 'OTP, bookings, expert updates',
                    value: _serviceAlerts,
                    onChanged: _saveAlerts,
                  ),
                ]),

                // Account
                const SizedBox(height: 28),
                _SectionTitle('ACCOUNT'),
                const SizedBox(height: 10),
                _WhiteCard(children: [
                  _NavRow(
                    icon: Icons.location_on_outlined,
                    bg: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1565C0),
                    label: 'Saved addresses',
                    onTap: () => context.push(AppRoutes.address),
                  ),
                  _RowDivider(),
                  _NavRow(
                    icon: Icons.card_membership_rounded,
                    bg: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFF6A1B9A),
                    label: 'My subscriptions',
                    onTap: () => context.push(AppRoutes.subscriptions),
                  ),
                  _RowDivider(),
                  _NavRow(
                    icon: Icons.logout_rounded,
                    bg: const Color(0xFFFFEBEE),
                    iconColor: AppColors.error,
                    label: 'Sign out',
                    labelColor: AppColors.error,
                    onTap: _confirmLogout,
                  ),
                ]),

                const SizedBox(height: 24),
                Center(
                  child: Text('Servlivo v1.0.0',
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 11,
                      color: AppColors.textHint)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(ProfileEntity p, bool hasPrime, double topPad) {
    return Container(
      decoration: BoxDecoration(
        gradient: hasPrime
            ? const LinearGradient(
                colors: [Color(0xFF1A0533), Color(0xFF3D1270)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)
            : const LinearGradient(
                colors: [Color(0xFFFF6B2C), Color(0xFFFF9A5C)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32)),
      ),
      child: Stack(children: [
        // Decorative circles
        Positioned(top: -20, right: -20,
          child: _Circle(140, Colors.white.withValues(alpha: 0.07))),
        Positioned(bottom: 30, left: -50,
          child: _Circle(160, Colors.white.withValues(alpha: 0.05))),

        // Content — NOT clipped so nothing gets cut
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(children: [
              // Top bar
              Row(children: [
                _GlassBtn(Icons.person_rounded),
                const Spacer(),
                const Text('My Profile',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 16,
                    fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
                _GlassBtn(Icons.more_horiz_rounded),
              ]),

              const SizedBox(height: 28),

              // Avatar
              GestureDetector(
                onTap: () => context.read<ProfileCubit>().pickAndUploadAvatar(),
                child: Stack(clipBehavior: Clip.none, children: [
                  // Glowing ring
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasPrime
                          ? const LinearGradient(
                              colors: [Colors.amber, Color(0xFFFFD700)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)
                          : const LinearGradient(
                              colors: [Colors.white, Color(0xFFFFDDCC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                  ),
                  Positioned(
                    top: 3, left: 3,
                    child: Container(
                      width: 90, height: 90,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: ClipOval(
                        child: p.avatarUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: p.avatarUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    _AvatarFallback(p.name, hasPrime),
                                errorWidget: (_, __, ___) =>
                                    _AvatarFallback(p.name, hasPrime),
                              )
                            : _AvatarFallback(p.name, hasPrime),
                      ),
                    ),
                  ),
                  // Camera badge
                  Positioned(
                    bottom: 1, right: 1,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: hasPrime ? Colors.amber : AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 13, color: Colors.white),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // Name
              Text(
                p.name.isNotEmpty ? p.name : 'Your Name',
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 22,
                  fontWeight: FontWeight.w800, color: Colors.white,
                  letterSpacing: -0.3),
              ),
              const SizedBox(height: 4),
              Text(p.email,
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.75))),
              const SizedBox(height: 16),

              // Single status row — just two clean pills
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Pill(
                  icon: p.isVerified
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  label: p.isVerified ? 'Verified' : 'Unverified',
                  iconColor: p.isVerified
                      ? const Color(0xFF4ADE80)
                      : Colors.orangeAccent,
                ),
                if (hasPrime) ...[
                  const SizedBox(width: 8),
                  _Pill(
                    icon: Icons.workspace_premium_rounded,
                    label: p.primeTier,
                    iconColor: Colors.amber,
                  ),
                ],
                const SizedBox(width: 8),
                _Pill(
                  icon: Icons.calendar_today_rounded,
                  label: 'Since ${_since(p.createdAt)}',
                  iconColor: Colors.white70,
                ),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }

  static String _since(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Completion card
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// Referral card
// ─────────────────────────────────────────────────────────────────────────────

class _ReferralCard extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;
  const _ReferralCard({required this.code, required this.onCopy});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7F4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      boxShadow: [BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.06),
        blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFF6B2C), Color(0xFFFF9800)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: const Icon(Icons.card_giftcard_rounded,
            color: Colors.white, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Share & earn rewards',
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 11,
              color: AppColors.textSecondary)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35))),
            child: Text(code,
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 2.0)),
          ),
        ]),
      ),
      const SizedBox(width: 12),
      GestureDetector(
        onTap: onCopy,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: const Icon(Icons.copy_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Membership card
// ─────────────────────────────────────────────────────────────────────────────

class _MembershipCard extends StatelessWidget {
  final ProfileEntity profile;
  final bool hasPrime;
  final VoidCallback onTap;
  const _MembershipCard({
      required this.profile, required this.hasPrime, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF120428), Color(0xFF2D1266), Color(0xFF3D1888)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: const Color(0xFF2D1266).withValues(alpha: 0.45),
          blurRadius: 18, offset: const Offset(0, 7))],
      ),
      child: Stack(children: [
        // Stars
        Positioned(top: 8,  right: 50,
          child: _Circle(5, Colors.white.withValues(alpha: 0.3))),
        Positioned(top: 24, right: 24,
          child: _Circle(3, Colors.amber.withValues(alpha: 0.5))),
        Positioned(bottom: 12, right: 70,
          child: _Circle(4, Colors.white.withValues(alpha: 0.2))),
        Positioned(bottom: 8, left: 130,
          child: _Circle(6, Colors.amber.withValues(alpha: 0.15))),

        Row(children: [
          // Icon
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              gradient: hasPrime
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)])
                  : LinearGradient(
                      colors: [Colors.white.withValues(alpha: 0.12),
                               Colors.white.withValues(alpha: 0.06)]),
              shape: BoxShape.circle,
              boxShadow: hasPrime ? [BoxShadow(
                color: Colors.amber.withValues(alpha: 0.4),
                blurRadius: 10, offset: const Offset(0, 3))] : null,
            ),
            child: Icon(Icons.workspace_premium_rounded,
              color: hasPrime ? const Color(0xFF1A0533) : Colors.white60,
              size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              hasPrime
                  ? '${profile.primeTier} Member'
                  : 'Free Member',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 17,
                fontWeight: FontWeight.w800,
                color: hasPrime ? Colors.amber.shade200 : Colors.white)),
            const SizedBox(height: 3),
            Text(
              hasPrime
                  ? (profile.primeExpiresAt != null
                      ? 'Expires ${_fmt(profile.primeExpiresAt!)}'
                      : 'Active membership')
                  : 'Upgrade for priority slots & lower fees',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6))),
          ])),
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle),
            child: const Icon(Icons.chevron_right_rounded,
                color: Colors.white60, size: 18),
          ),
        ]),
      ]),
    ),
  );

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient button
// ─────────────────────────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback? onTap;
  const _GradientButton({
      required this.label, required this.icon,
      required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        gradient: busy ? null : const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
          begin: Alignment.centerLeft, end: Alignment.centerRight),
        color: busy ? const Color(0xFFDDDDDD) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: busy ? null : [BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.4),
          blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Center(
        child: busy
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(label,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 15,
                    fontWeight: FontWeight.w700, color: Colors.white,
                    letterSpacing: 0.2)),
              ]),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Form rows
// ─────────────────────────────────────────────────────────────────────────────

class _StyledField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController ctrl;
  final bool locked;

  const _StyledField({
    required this.icon, required this.label,
    required this.ctrl, this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
    );

    return TextField(
      controller: ctrl,
      readOnly: locked,
      style: TextStyle(
        fontFamily: 'Poppins', fontSize: 14,
        fontWeight: FontWeight.w600,
        color: locked ? AppColors.textHint : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins', fontSize: 13,
          color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Poppins', fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(11),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: locked
                  ? const Color(0xFFF5F5F5)
                  : AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 16,
              color: locked ? AppColors.textHint : AppColors.primary),
          ),
        ),
        suffixIcon: locked
            ? const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.lock_outline_rounded,
                    size: 16, color: AppColors.textHint))
            : const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.textHint)),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: locked
            ? const Color(0xFFFAFAFA)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: locked ? border : focusBorder,
        disabledBorder: border,
      ),
    );
  }
}

class _StyledPhoneField extends StatelessWidget {
  final TextEditingController ctrl;
  final bool verified;
  const _StyledPhoneField({required this.ctrl, required this.verified});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
    );

    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.phone,
      style: const TextStyle(
        fontFamily: 'Poppins', fontSize: 14,
        fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Phone number',
        labelStyle: const TextStyle(
          fontFamily: 'Poppins', fontSize: 13,
          color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Poppins', fontSize: 12,
          fontWeight: FontWeight.w600, color: AppColors.primary),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(11),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.phone_outlined,
                size: 16, color: AppColors.primary),
          ),
        ),
        prefix: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(7)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('🇮🇳', style: TextStyle(fontSize: 13)),
            SizedBox(width: 4),
            Text('+91',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
          ]),
        ),
        suffixIcon: verified
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle_rounded,
                        size: 13, color: Color(0xFF16A34A)),
                    SizedBox(width: 4),
                    Text('Verified',
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A))),
                  ]),
                ),
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: focusBorder,
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final String? value;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon, required this.bg, required this.iconColor,
    required this.label, required this.onTap,
    this.labelColor, this.value,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 14,
              fontWeight: FontWeight.w600,
              color: labelColor ?? AppColors.textPrimary)),
          if (value != null)
            Text(value!,
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 12,
                color: AppColors.textSecondary)),
        ])),
        Icon(Icons.chevron_right_rounded,
          size: 18,
          color: labelColor != null
              ? labelColor!.withValues(alpha: 0.4)
              : AppColors.textHint),
      ]),
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon, required this.bg, required this.iconColor,
    required this.label, required this.sub,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(11)),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
          style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text(sub,
          style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 11,
            color: AppColors.textSecondary)),
      ])),
      Switch.adaptive(
        value: value, onChanged: onChanged,
        activeTrackColor: AppColors.primary,
        activeThumbColor: Colors.white,
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Micro widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String t;
  const _SectionTitle(this.t);
  @override
  Widget build(BuildContext context) => Text(t,
    style: const TextStyle(
      fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700,
      color: Color(0xFF9E9E9E), letterSpacing: 1.0));
}

class _WhiteCard extends StatelessWidget {
  final List<Widget> children;
  const _WhiteCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Column(children: children),
    ),
  );
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 68, endIndent: 0,
          thickness: 0.8, color: Color(0xFFF2F2F2));
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  const _Pill({required this.icon, required this.label, required this.iconColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: iconColor),
      const SizedBox(width: 5),
      Text(label,
        style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 10,
          fontWeight: FontWeight.w600, color: Colors.white)),
    ]),
  );
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  const _GlassBtn(this.icon);
  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, size: 18, color: Colors.white),
  );
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar fallback
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarFallback extends StatelessWidget {
  final String name;
  final bool hasPrime;
  const _AvatarFallback(this.name, this.hasPrime);

  @override
  Widget build(BuildContext context) {
    final color = hasPrime
        ? const Color(0xFF3D1270)
        : AppColors.primary;
    return Container(
      color: color.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontFamily: 'Poppins', fontSize: 36,
            fontWeight: FontWeight.w800, color: color)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language sheet
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageSheet extends StatelessWidget {
  final List<String> languages;
  final String selected;
  final ValueChanged<String> onSelect;
  const _LanguageSheet({
      required this.languages, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        // Drag handle
        Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Select Language',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 17,
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
        ),
        const SizedBox(height: 8),
        // Scrollable list
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: languages.length,
            itemBuilder: (_, i) {
              final lang    = languages[i];
              final active  = lang == selected;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: active
                    ? AppColors.primary.withValues(alpha: 0.06)
                    : null,
                title: Text(lang,
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? AppColors.primary
                        : AppColors.textPrimary)),
                trailing: active
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () => onSelect(lang),
              );
            },
          ),
        ),
        SizedBox(height: 16 + bottomPad),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5), shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded,
              size: 32, color: AppColors.textHint)),
        const SizedBox(height: 16),
        Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14,
            color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12)),
            child: const Text('Retry',
              style: TextStyle(
                fontFamily: 'Poppins', fontSize: 14,
                fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
    ),
  );
}
