import 'package:flutter/material.dart';
import 'package:stock_count/config.dart';
import 'package:stock_count/constants/wallpaper_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class SetupDialog extends StatefulWidget {
  final bool isFirstLaunch;

  const SetupDialog({Key? key, this.isFirstLaunch = true}) : super(key: key);

  @override
  _SetupDialogState createState() => _SetupDialogState();
}

class _SetupDialogState extends State<SetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
  }

  Future<void> _loadExistingConfig() async {
    setState(() => _isLoading = true);

    try {
      final baseUrl = await AppConfig.baseUrl;
      final clientId = await AppConfig.clientId;

      setState(() {
        _baseUrlController.text = baseUrl;
        _clientIdController.text = clientId;
      });
    } catch (e) {
      print("Error loading config: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await AppConfig.saveConfig(
          baseUrl: _baseUrlController.text.trim(),
          clientId: _clientIdController.text.trim(),
        );

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        print("Error saving config: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save configuration: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _openFrappeOAuthDocs() async {
    const url =
        'https://docs.frappe.io/framework/user/en/guides/integration/how_to_set_up_oauth';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open documentation')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Stack(
        children: [
          // Animated Royal Blue gradient background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: WallpaperManager.fromKey('royal_ocean_blue',
                  effectsEnabled: true),
            ),
          ),
          // Content with glass-morphism
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with icon
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.settings_suggest_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                widget.isFirstLaunch
                                    ? 'Welcome to Cohenix HRMS!'
                                    : 'App Configuration',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),

                              // Subtitle
                              Text(
                                'Please configure the app to connect to your Cohenix server:',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Base URL field
                              TextFormField(
                                controller: _baseUrlController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Base URL',
                                  labelStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.9)),
                                  hintText: 'https://your-cohenix-server.com',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.white, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.red.shade300, width: 2),
                                  ),
                                  prefixIcon: const Icon(Icons.link,
                                      color: Colors.white),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the base URL';
                                  }
                                  if (!value.startsWith('http')) {
                                    return 'URL must start with http:// or https://';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Client ID field
                              TextFormField(
                                controller: _clientIdController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Client ID',
                                  labelStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.9)),
                                  hintText: 'Enter OAuth Client ID',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.white, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.red.shade300, width: 2),
                                  ),
                                  prefixIcon: const Icon(Icons.vpn_key,
                                      color: Colors.white),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the client ID';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // OAuth Setup Instructions
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.2)),
                                ),
                                child: ExpansionTile(
                                  title: const Text(
                                    'How to set up OAuth in Cohenix',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  iconColor: Colors.white,
                                  collapsedIconColor: Colors.white,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '1. Go to your Cohenix server and create a new OAuth Client:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white
                                                  .withOpacity(0.95),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '   • Navigate to: Integrations > OAuth Client > New',
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9)),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '2. Fill in the following details:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white
                                                  .withOpacity(0.95),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '   • App Name: Cohenix HRMS\n'
                                            '   • Skip Authorization: Check this box\n'
                                            '   • Redirect URIs: stockcount://oauth2redirect\n'
                                            '   • Default Redirect URI: stockcount://oauth2redirect\n'
                                            '   • Grant Type: Authorization Code\n'
                                            '   • Response Type: Code',
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9)),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '3. Save the OAuth Client and copy the Client ID',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white
                                                  .withOpacity(0.95),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextButton.icon(
                                            onPressed: _openFrappeOAuthDocs,
                                            icon: const Icon(Icons.open_in_new,
                                                color: Colors.white),
                                            label: const Text(
                                              'Open Cohenix OAuth Documentation',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              const SizedBox(height: 32),

                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!widget.isFirstLaunch)
                                    Flexible(
                                      child: TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: _saveConfig,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF1436AC),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_outline,
                                              size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Save Config',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }
}
