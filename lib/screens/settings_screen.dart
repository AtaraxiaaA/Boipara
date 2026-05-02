import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────
//  SettingsScreen — Full Firebase-backed settings for Boipara
// ─────────────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Brand colors ──────────────────────────────────────────
  static const darkBrown = Color(0xFF613613);
  static const medBrown = Color(0xFF7C4700);
  static const accentOrange = Color(0xFFE07B39);
  static const bgColor = Color(0xFFF5F0E9);

  // ── Firebase ──────────────────────────────────────────────
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // ── Notification prefs (loaded from Firestore) ───────────
  bool _notifOrders = true;
  bool _notifQA = true;
  bool _notifLikes = true;
  bool _notifComments = true;

  // ── Privacy prefs ─────────────────────────────────────────
  bool _profilePublic = true;
  bool _showEmail = false;

  bool _isLoading = true;
  bool _isSaving = false;

  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ── Load settings from Firestore ──────────────────────────
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data() ?? {};

      final notifPrefs = data['notifPrefs'] as Map<String, dynamic>? ?? {};
      final privacyPrefs = data['privacyPrefs'] as Map<String, dynamic>? ?? {};

      setState(() {
        _notifOrders = notifPrefs['orders'] ?? true;
        _notifQA = notifPrefs['qa'] ?? true;
        _notifLikes = notifPrefs['likes'] ?? true;
        _notifComments = notifPrefs['comments'] ?? true;

        _profilePublic = privacyPrefs['profilePublic'] ?? true;
        _showEmail = privacyPrefs['showEmail'] ?? false;
      });
    } catch (_) {
      // use defaults silently
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Save a single settings map to Firestore ───────────────
  Future<void> _saveSettings() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      await _db.collection('users').doc(uid).set({
        'notifPrefs': {
          'orders': _notifOrders,
          'qa': _notifQA,
          'likes': _notifLikes,
          'comments': _notifComments,
        },
        'privacyPrefs': {
          'profilePublic': _profilePublic,
          'showEmail': _showEmail,
        },
      }, SetOptions(merge: true));
      if (mounted) _showSnack('Settings saved ✓');
    } catch (e) {
      if (mounted) _showSnack('Could not save settings', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Save immediately when a toggle changes ────────────────
  void _onToggleChanged(VoidCallback updateState) {
    setState(updateState);
    _saveSettings();
  }

  // ── Change password dialog ────────────────────────────────
  Future<void> _showChangePasswordDialog() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Google-only users don't have a password
    final providers = user.providerData.map((p) => p.providerId).toList();
    if (providers.contains('google.com') && !providers.contains('password')) {
      _showSnack(
        'You signed in with Google. No password to change.',
        isError: true,
      );
      return;
    }

    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCur = true, obscureNew = true, obscureCon = true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _passwordField(
                  'Current Password',
                  currentCtrl,
                  obscureCur,
                  () => setSt(() => obscureCur = !obscureCur),
                ),
                const SizedBox(height: 12),
                _passwordField(
                  'New Password',
                  newCtrl,
                  obscureNew,
                  () => setSt(() => obscureNew = !obscureNew),
                ),
                const SizedBox(height: 12),
                _passwordField(
                  'Confirm New Password',
                  confirmCtrl,
                  obscureCon,
                  () => setSt(() => obscureCon = !obscureCon),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (newCtrl.text != confirmCtrl.text) {
                    _showSnack('Passwords do not match', isError: true);
                    return;
                  }
                  if (newCtrl.text.length < 6) {
                    _showSnack(
                      'Password must be at least 6 characters',
                      isError: true,
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  await _changePassword(
                    currentCtrl.text.trim(),
                    newCtrl.text.trim(),
                  );
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBrown),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            size: 18,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  Future<void> _changePassword(String current, String newPass) async {
    try {
      final user = _auth.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);
      _showSnack('Password updated successfully ✓');
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to update password';
      if (e.code == 'wrong-password') msg = 'Current password is incorrect';
      if (e.code == 'weak-password') msg = 'New password is too weak';
      _showSnack(msg, isError: true);
    }
  }

  // ── Send password reset email ─────────────────────────────
  Future<void> _sendPasswordReset() async {
    final email = _auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      _showSnack('No email linked to this account', isError: true);
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnack('Reset link sent to $email');
    } catch (_) {
      _showSnack('Could not send reset email', isError: true);
    }
  }

  // ── Delete account confirmation ───────────────────────────
  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will permanently delete your Boipara account and all your data '
          '(listings, orders, club memberships). This cannot be undone.\n\n'
          'Are you absolutely sure?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete Forever',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    try {
      final uid = _auth.currentUser?.uid;
      final user = _auth.currentUser;
      if (uid == null || user == null) return;

      // Soft-delete: mark Firestore doc as deleted (keeps order records for sellers)
      await _db.collection('users').doc(uid).set({
        'deleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'username': 'Deleted User',
        'email': '',
        'profilePhoto': '',
      }, SetOptions(merge: true));

      // Delete auth account
      await user.delete();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showSnack(
          'Please log out and log in again before deleting',
          isError: true,
        );
      } else {
        _showSnack('Could not delete account: ${e.message}', isError: true);
      }
    }
  }

  // ── URL launcher helper ───────────────────────────────────
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnack('Could not open link', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : darkBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isGoogleOnly =
        user != null &&
        user.providerData.any((p) => p.providerId == 'google.com') &&
        !user.providerData.any((p) => p.providerId == 'password');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: darkBrown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: darkBrown))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // ─── ACCOUNT ───────────────────────────────────────
                _sectionHeader('Account', Icons.manage_accounts_outlined),
                _settingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: isGoogleOnly
                      ? 'You signed in with Google'
                      : 'Update your account password',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  enabled: !isGoogleOnly,
                  onTap: isGoogleOnly ? null : _showChangePasswordDialog,
                ),
                _settingsTile(
                  icon: Icons.email_outlined,
                  title: 'Forgot Password?',
                  subtitle: 'Send a reset link to your email',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  enabled: !isGoogleOnly,
                  onTap: isGoogleOnly ? null : _sendPasswordReset,
                ),
                _settingsTile(
                  icon: Icons.phone_outlined,
                  title: 'Linked Phone Number',
                  subtitle: user?.phoneNumber?.isNotEmpty == true
                      ? user!.phoneNumber!
                      : 'No phone linked',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () =>
                      _showSnack('Go to Edit Profile to update your phone'),
                ),
                if (isGoogleOnly)
                  _settingsTile(
                    icon: Icons.g_mobiledata_rounded,
                    iconColor: const Color(0xFF4285F4),
                    title: 'Google Account Linked',
                    subtitle: user?.email ?? '',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        'Connected',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: null,
                  ),

                const SizedBox(height: 8),

                // ─── NOTIFICATIONS ─────────────────────────────────
                _sectionHeader('Notifications', Icons.notifications_outlined),
                _toggleTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Order Updates',
                  subtitle: 'New orders, delivery status changes',
                  value: _notifOrders,
                  onChanged: (v) => _onToggleChanged(() => _notifOrders = v),
                ),
                _toggleTile(
                  icon: Icons.question_answer_outlined,
                  title: 'Q&A Alerts',
                  subtitle: 'Questions on your listings & answers',
                  value: _notifQA,
                  onChanged: (v) => _onToggleChanged(() => _notifQA = v),
                ),
                _toggleTile(
                  icon: Icons.favorite_outline,
                  title: 'Post Likes',
                  subtitle: 'When someone likes your book request',
                  value: _notifLikes,
                  onChanged: (v) => _onToggleChanged(() => _notifLikes = v),
                ),
                _toggleTile(
                  icon: Icons.comment_outlined,
                  title: 'Comments',
                  subtitle: 'Replies on your book requests',
                  value: _notifComments,
                  onChanged: (v) => _onToggleChanged(() => _notifComments = v),
                ),

                const SizedBox(height: 8),

                // ─── PRIVACY ───────────────────────────────────────
                _sectionHeader('Privacy', Icons.privacy_tip_outlined),
                _toggleTile(
                  icon: Icons.public_outlined,
                  title: 'Public Profile',
                  subtitle: 'Other users can view your profile',
                  value: _profilePublic,
                  onChanged: (v) => _onToggleChanged(() => _profilePublic = v),
                ),
                _toggleTile(
                  icon: Icons.alternate_email,
                  title: 'Show Email on Profile',
                  subtitle: 'Display your email to other members',
                  value: _showEmail,
                  onChanged: (v) => _onToggleChanged(() => _showEmail = v),
                ),

                const SizedBox(height: 8),

                // ─── ABOUT ─────────────────────────────────────────
                _sectionHeader('About Boipara', Icons.info_outline),
                _settingsTile(
                  icon: Icons.star_outline_rounded,
                  iconColor: Colors.amber,
                  title: 'Rate Us on Play Store',
                  subtitle: 'Enjoying Boipara? Leave a review!',
                  trailing: const Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () => _launchUrl(
                    // Replace with your actual Play Store package name after publishing
                    'https://play.google.com/store/apps/details?id=com.example.bibliobd',
                  ),
                ),
                _settingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  trailing: const Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () =>
                      _launchUrl('https://boipara-eb181.web.app/terms'),
                ),
                _settingsTile(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy',
                  trailing: const Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () =>
                      _launchUrl('https://boipara-eb181.web.app/privacy'),
                ),
                _settingsTile(
                  icon: Icons.support_agent_outlined,
                  title: 'Contact Support',
                  subtitle: 'support@boipara.com.bd',
                  trailing: const Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () => _launchUrl('mailto:support@boipara.com.bd'),
                ),
                _settingsTile(
                  icon: Icons.info_outlined,
                  title: 'App Version',
                  subtitle: 'v$_appVersion  •  Made with ❤️ in Bangladesh',
                  onTap: null,
                ),

                const SizedBox(height: 8),

                // ─── DANGER ZONE ───────────────────────────────────
                _sectionHeader(
                  'Danger Zone',
                  Icons.warning_amber_outlined,
                  isRed: true,
                ),
                _settingsTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: Colors.red,
                  title: 'Delete Account',
                  subtitle: 'Permanently remove your Boipara account',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.red,
                  ),
                  titleColor: Colors.red,
                  onTap: _showDeleteAccountDialog,
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  UI HELPERS
  // ─────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isRed ? Colors.red : medBrown),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isRed ? Colors.red : medBrown,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: isRed ? Colors.red.shade100 : Colors.brown.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: enabled ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: (iconColor ?? darkBrown).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: enabled ? (iconColor ?? darkBrown) : Colors.grey,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: enabled
                              ? (titleColor ?? const Color(0xFF333333))
                              : Colors.grey,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: darkBrown.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: darkBrown),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: accentOrange,
                activeTrackColor: accentOrange.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
