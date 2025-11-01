import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                'To use this app, you need to create a Discord Application:',
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
                  labelText: 'Discord Client ID',
                  hintText: 'Paste your Application ID here',
                  border: OutlineInputBorder(),
                  helperText: 'Required to connect to Discord',
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
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• You can upload custom images as "Art Assets" in your Discord Application\n'
                        '• Use the asset name (e.g., "game_icon") in the game\'s icon field\n'
                        '• Or use a direct URL to any publicly accessible image\n'
                        '• Make sure Discord is running before starting monitoring',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
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
                  SelectableText(
                    link,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      decoration: TextDecoration.underline,
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

    if (clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Discord Client ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appState = context.read<AppState>();
    await appState.setClientId(clientId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
