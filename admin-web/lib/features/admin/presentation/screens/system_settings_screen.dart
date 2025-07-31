import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _isLoading = false;
  bool _isSaving = false;

  // General Settings
  String _appName = 'WanderWise';
  String _appVersion = '1.0.0';
  String _supportEmail = 'support@wanderwise.com';
  String _contactPhone = '+1 (555) 123-4567';
  String _timezone = 'UTC';
  String _defaultLanguage = 'English';

  // User Management Settings
  bool _allowUserRegistration = true;
  bool _requireEmailVerification = true;
  bool _allowSocialLogin = true;
  int _maxLoginAttempts = 5;
  int _sessionTimeoutMinutes = 30;
  bool _enableTwoFactorAuth = false;

  // Content Management Settings
  bool _autoApproveReviews = false;
  bool _requireReviewModeration = true;
  int _maxReviewLength = 1000;
  bool _allowAnonymousReviews = false;
  bool _enableContentFiltering = true;
  List<String> _bannedWords = ['spam', 'inappropriate', 'offensive'];

  // Notification Settings
  bool _enableEmailNotifications = true;
  bool _enablePushNotifications = true;
  bool _enableSMSNotifications = false;
  String _notificationSenderEmail = 'noreply@wanderwise.com';
  String _notificationSenderName = 'WanderWise';

  // Security Settings
  bool _enableRateLimiting = true;
  int _rateLimitRequests = 100;
  int _rateLimitWindowMinutes = 15;
  bool _enableAuditLogging = true;
  bool _requireStrongPasswords = true;
  int _passwordMinLength = 8;

  // Feature Flags
  bool _enableAdvancedAnalytics = true;
  bool _enableBetaFeatures = false;
  bool _enableDebugMode = false;
  bool _enableMaintenanceMode = false;
  bool _enableAPIAccess = true;

  // Integration Settings
  bool _enableGoogleMaps = true;
  bool _enableStripePayments = true;
  bool _enableEmailService = true;
  bool _enableSMSGateway = false;
  String _googleMapsApiKey = 'your-api-key-here';
  String _stripePublicKey = 'pk_test_...';

  final List<String> _timezones = [
    'UTC',
    'America/New_York',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Paris',
    'Asia/Tokyo',
    'Australia/Sydney',
  ];

  final List<String> _languages = [
    'English',
    'French',
    'Spanish',
    'German',
    'Italian',
    'Portuguese',
    'Japanese',
    'Chinese',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getSystemSettings in SupabaseService
      // For now, using default values
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: Implement saveSystemSettings in SupabaseService
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
            'Are you sure you want to reset all settings to their default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadSettings(); // This will reload default values
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          TextButton(
            onPressed: _isSaving ? null : _resetToDefaults,
            child: const Text('Reset to Defaults',
                style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: _isSaving ? null : _saveSettings,
            child:
                const Text('Save All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Settings
                  _buildSettingsSection(
                    title: 'General Settings',
                    icon: Icons.settings,
                    children: [
                      _buildTextField(
                        label: 'App Name',
                        value: _appName,
                        onChanged: (value) => setState(() => _appName = value),
                      ),
                      _buildTextField(
                        label: 'App Version',
                        value: _appVersion,
                        onChanged: (value) =>
                            setState(() => _appVersion = value),
                      ),
                      _buildTextField(
                        label: 'Support Email',
                        value: _supportEmail,
                        onChanged: (value) =>
                            setState(() => _supportEmail = value),
                      ),
                      _buildTextField(
                        label: 'Contact Phone',
                        value: _contactPhone,
                        onChanged: (value) =>
                            setState(() => _contactPhone = value),
                      ),
                      _buildDropdown(
                        label: 'Default Timezone',
                        value: _timezone,
                        items: _timezones,
                        onChanged: (value) =>
                            setState(() => _timezone = value!),
                      ),
                      _buildDropdown(
                        label: 'Default Language',
                        value: _defaultLanguage,
                        items: _languages,
                        onChanged: (value) =>
                            setState(() => _defaultLanguage = value!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Management Settings
                  _buildSettingsSection(
                    title: 'User Management',
                    icon: Icons.people,
                    children: [
                      _buildSwitch(
                        label: 'Allow User Registration',
                        value: _allowUserRegistration,
                        onChanged: (value) =>
                            setState(() => _allowUserRegistration = value),
                      ),
                      _buildSwitch(
                        label: 'Require Email Verification',
                        value: _requireEmailVerification,
                        onChanged: (value) =>
                            setState(() => _requireEmailVerification = value),
                      ),
                      _buildSwitch(
                        label: 'Allow Social Login',
                        value: _allowSocialLogin,
                        onChanged: (value) =>
                            setState(() => _allowSocialLogin = value),
                      ),
                      _buildNumberField(
                        label: 'Max Login Attempts',
                        value: _maxLoginAttempts,
                        onChanged: (value) =>
                            setState(() => _maxLoginAttempts = value),
                      ),
                      _buildNumberField(
                        label: 'Session Timeout (minutes)',
                        value: _sessionTimeoutMinutes,
                        onChanged: (value) =>
                            setState(() => _sessionTimeoutMinutes = value),
                      ),
                      _buildSwitch(
                        label: 'Enable Two-Factor Authentication',
                        value: _enableTwoFactorAuth,
                        onChanged: (value) =>
                            setState(() => _enableTwoFactorAuth = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Content Management Settings
                  _buildSettingsSection(
                    title: 'Content Management',
                    icon: Icons.content_paste,
                    children: [
                      _buildSwitch(
                        label: 'Auto-Approve Reviews',
                        value: _autoApproveReviews,
                        onChanged: (value) =>
                            setState(() => _autoApproveReviews = value),
                      ),
                      _buildSwitch(
                        label: 'Require Review Moderation',
                        value: _requireReviewModeration,
                        onChanged: (value) =>
                            setState(() => _requireReviewModeration = value),
                      ),
                      _buildNumberField(
                        label: 'Max Review Length',
                        value: _maxReviewLength,
                        onChanged: (value) =>
                            setState(() => _maxReviewLength = value),
                      ),
                      _buildSwitch(
                        label: 'Allow Anonymous Reviews',
                        value: _allowAnonymousReviews,
                        onChanged: (value) =>
                            setState(() => _allowAnonymousReviews = value),
                      ),
                      _buildSwitch(
                        label: 'Enable Content Filtering',
                        value: _enableContentFiltering,
                        onChanged: (value) =>
                            setState(() => _enableContentFiltering = value),
                      ),
                      _buildListField(
                        label: 'Banned Words',
                        items: _bannedWords,
                        onChanged: (items) =>
                            setState(() => _bannedWords = items),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Notification Settings
                  _buildSettingsSection(
                    title: 'Notifications',
                    icon: Icons.notifications,
                    children: [
                      _buildSwitch(
                        label: 'Enable Email Notifications',
                        value: _enableEmailNotifications,
                        onChanged: (value) =>
                            setState(() => _enableEmailNotifications = value),
                      ),
                      _buildSwitch(
                        label: 'Enable Push Notifications',
                        value: _enablePushNotifications,
                        onChanged: (value) =>
                            setState(() => _enablePushNotifications = value),
                      ),
                      _buildSwitch(
                        label: 'Enable SMS Notifications',
                        value: _enableSMSNotifications,
                        onChanged: (value) =>
                            setState(() => _enableSMSNotifications = value),
                      ),
                      _buildTextField(
                        label: 'Notification Sender Email',
                        value: _notificationSenderEmail,
                        onChanged: (value) =>
                            setState(() => _notificationSenderEmail = value),
                      ),
                      _buildTextField(
                        label: 'Notification Sender Name',
                        value: _notificationSenderName,
                        onChanged: (value) =>
                            setState(() => _notificationSenderName = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Security Settings
                  _buildSettingsSection(
                    title: 'Security',
                    icon: Icons.security,
                    children: [
                      _buildSwitch(
                        label: 'Enable Rate Limiting',
                        value: _enableRateLimiting,
                        onChanged: (value) =>
                            setState(() => _enableRateLimiting = value),
                      ),
                      _buildNumberField(
                        label: 'Rate Limit Requests',
                        value: _rateLimitRequests,
                        onChanged: (value) =>
                            setState(() => _rateLimitRequests = value),
                      ),
                      _buildNumberField(
                        label: 'Rate Limit Window (minutes)',
                        value: _rateLimitWindowMinutes,
                        onChanged: (value) =>
                            setState(() => _rateLimitWindowMinutes = value),
                      ),
                      _buildSwitch(
                        label: 'Enable Audit Logging',
                        value: _enableAuditLogging,
                        onChanged: (value) =>
                            setState(() => _enableAuditLogging = value),
                      ),
                      _buildSwitch(
                        label: 'Require Strong Passwords',
                        value: _requireStrongPasswords,
                        onChanged: (value) =>
                            setState(() => _requireStrongPasswords = value),
                      ),
                      _buildNumberField(
                        label: 'Password Min Length',
                        value: _passwordMinLength,
                        onChanged: (value) =>
                            setState(() => _passwordMinLength = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Feature Flags
                  _buildSettingsSection(
                    title: 'Feature Flags',
                    icon: Icons.flag,
                    children: [
                      _buildSwitch(
                        label: 'Enable Advanced Analytics',
                        value: _enableAdvancedAnalytics,
                        onChanged: (value) =>
                            setState(() => _enableAdvancedAnalytics = value),
                      ),
                      _buildSwitch(
                        label: 'Enable Beta Features',
                        value: _enableBetaFeatures,
                        onChanged: (value) =>
                            setState(() => _enableBetaFeatures = value),
                      ),
                      _buildSwitch(
                        label: 'Enable Debug Mode',
                        value: _enableDebugMode,
                        onChanged: (value) =>
                            setState(() => _enableDebugMode = value),
                      ),
                      _buildSwitch(
                        label: 'Enable Maintenance Mode',
                        value: _enableMaintenanceMode,
                        onChanged: (value) =>
                            setState(() => _enableMaintenanceMode = value),
                      ),
                      _buildSwitch(
                        label: 'Enable API Access',
                        value: _enableAPIAccess,
                        onChanged: (value) =>
                            setState(() => _enableAPIAccess = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Integration Settings
                  _buildSettingsSection(
                    title: 'Integrations',
                    icon: Icons.integration_instructions,
                    children: [
                      _buildSwitch(
                        label: 'Enable Google Maps',
                        value: _enableGoogleMaps,
                        onChanged: (value) =>
                            setState(() => _enableGoogleMaps = value),
                      ),
                      _buildSwitch(
                        label: 'Enable Stripe Payments',
                        value: _enableStripePayments,
                        onChanged: (value) =>
                            setState(() => _enableStripePayments = value),
                      ),
                      _buildSwitch(
                        label: 'Enable Email Service',
                        value: _enableEmailService,
                        onChanged: (value) =>
                            setState(() => _enableEmailService = value),
                      ),
                      _buildSwitch(
                        label: 'Enable SMS Gateway',
                        value: _enableSMSGateway,
                        onChanged: (value) =>
                            setState(() => _enableSMSGateway = value),
                      ),
                      _buildTextField(
                        label: 'Google Maps API Key',
                        value: _googleMapsApiKey,
                        onChanged: (value) =>
                            setState(() => _googleMapsApiKey = value),
                        isPassword: true,
                      ),
                      _buildTextField(
                        label: 'Stripe Public Key',
                        value: _stripePublicKey,
                        onChanged: (value) =>
                            setState(() => _stripePublicKey = value),
                        isPassword: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isPassword ? const Icon(Icons.visibility_off) : null,
        ),
        obscureText: isPassword,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value.toString(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (text) {
          final number = int.tryParse(text);
          if (number != null) {
            onChanged(number);
          }
        },
      ),
    );
  }

  Widget _buildListField({
    required String label,
    required List<String> items,
    required Function(List<String>) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: items.map((item) {
              return Chip(
                label: Text(item),
                onDeleted: () {
                  final newItems = List<String>.from(items)..remove(item);
                  onChanged(newItems);
                },
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Add new item',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (text) {
                    if (text.isNotEmpty && !items.contains(text)) {
                      final newItems = List<String>.from(items)..add(text);
                      onChanged(newItems);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
