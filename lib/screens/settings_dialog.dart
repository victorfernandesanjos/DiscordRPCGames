import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _clientIdController;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _clientIdController = TextEditingController(text: appState.clientId ?? '');
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Discord Application Setup',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'The app works out of the box with a default Discord Application. To use custom icons, create your own:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildInstructionStep(
                '1',
                'Go to Discord Developer Portal',
                'https://discord.com/developers/applications',
              ),
              _buildInstructionStep('2', 'Create a "New Application"', null),
              _buildInstructionStep(
                '3',
                'Copy the Application ID (Client ID)',
                null,
              ),
              _buildInstructionStep(
                '4',
                'Optional: Upload images in "Rich Presence" > "Art Assets"',
                null,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              TextField(
                controller: _clientIdController,
                decoration: const InputDecoration(
                  labelText: 'Discord Client ID (Optional)',
                  hintText: 'Leave empty to use default, or paste your own Application ID',
                  border: OutlineInputBorder(),
                  helperText: 'App comes with a default Client ID. Enter yours to use custom icons.',
                ),
              ),
              const SizedBox(height: 16),
              Consumer<AppState>(
                builder: (context, appState, child) {
                  return SwitchListTile(
                    title: const Text('Auto-start monitoring'),
                    subtitle: const Text(
                      'Automatically start monitoring when app launches',
                    ),
                    value: appState.autoStart,
                    onChanged: (value) {
                      appState.toggleAutoStart();
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Card(
                    color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: isDark ? Colors.lightBlue.shade300 : Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tips',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.lightBlue.shade300 : Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• You can upload custom images as "Art Assets" in your Discord Application\n'
                            '• Use the asset name (e.g., "game_icon") in the game\'s icon field\n'
                            '• Or use a direct URL to any publicly accessible image\n'
                            '• Make sure Discord is running before starting monitoring',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.lightBlue.shade100 : Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveSettings, child: const Text('Save')),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text, String? link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 14)),
                if (link != null) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse(link);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(
                      link,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.lightBlue.shade300
                            : Colors.blue.shade700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
    final clientId = _clientIdController.text.trim();

    final appState = context.read<AppState>();
    
    // Allow empty client ID (will use default)
    if (clientId.isEmpty) {
      await appState.setClientId('');
    } else {
      await appState.setClientId(clientId);
    }

    if (mounted) {
      final message = clientId.isEmpty 
          ? 'Settings saved - using default Client ID'
          : 'Settings saved - using your custom Client ID';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
