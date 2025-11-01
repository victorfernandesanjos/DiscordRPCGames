import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/game_profile.dart';

class AddGameDialog extends StatefulWidget {
  final GameProfile? gameToEdit;

  const AddGameDialog({super.key, this.gameToEdit});

  @override
  State<AddGameDialog> createState() => _AddGameDialogState();
}

class _AddGameDialogState extends State<AddGameDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _processNameController;
  late TextEditingController _iconUrlController;
  late TextEditingController _detailsController;
  late TextEditingController _stateController;

  bool _showProcessPicker = false;
  final FocusNode _processFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.gameToEdit?.displayName ?? '',
    );
    _processNameController = TextEditingController(
      text: widget.gameToEdit?.processName ?? '',
    );
    _iconUrlController = TextEditingController(
      text: widget.gameToEdit?.iconUrl ?? '',
    );
    _detailsController = TextEditingController(
      text: widget.gameToEdit?.details ?? '',
    );
    _stateController = TextEditingController(
      text: widget.gameToEdit?.state ?? '',
    );
    
    // Listen to process name changes to filter the process list
    _processNameController.addListener(() {
      if (_showProcessPicker) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _processNameController.dispose();
    _iconUrlController.dispose();
    _detailsController.dispose();
    _stateController.dispose();
    _processFieldFocus.dispose();
    super.dispose();
  }

  List<String> _getFilteredProcesses(Set<String> allProcesses) {
    final searchTerm = _processNameController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      return allProcesses.toList()..sort();
    }
    return allProcesses
        .where((process) => process.toLowerCase().contains(searchTerm))
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.gameToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Game' : 'Add Game'),
      content: SizedBox(
        width: 550,
        height: 650,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name *',
                          hintText: 'e.g., Minecraft',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a display name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildProcessNameField(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _iconUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Icon URL (optional)',
                          hintText: 'https://example.com/icon.png',
                          helperText: 'URL to an image for the game icon',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _detailsController,
                        decoration: const InputDecoration(
                          labelText: 'Details (optional)',
                          hintText: 'e.g., Playing Survival Mode',
                          helperText: 'First line in Discord status',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'State (optional)',
                          hintText: 'e.g., In a server',
                          helperText: 'Second line in Discord status',
                          border: OutlineInputBorder(),
                        ),
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
        ElevatedButton(
          onPressed: _saveGame,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _buildProcessNameField() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final runningProcesses = appState.runningProcesses;
        final hasProcesses = runningProcesses.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _processNameController,
              focusNode: _processFieldFocus,
              decoration: InputDecoration(
                labelText: 'Process Name *',
                hintText: 'e.g., javaw.exe',
                helperText: hasProcesses 
                    ? 'Type to filter running processes, or enter manually'
                    : 'The exact process name (including .exe)',
                border: const OutlineInputBorder(),
                suffixIcon: hasProcesses
                    ? IconButton(
                        icon: Icon(
                          _showProcessPicker
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                        ),
                        onPressed: () {
                          setState(() {
                            _showProcessPicker = !_showProcessPicker;
                          });
                        },
                        tooltip: 'Browse running processes',
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a process name';
                }
                return null;
              },
              onTap: () {
                if (hasProcesses && !_showProcessPicker) {
                  setState(() {
                    _showProcessPicker = true;
                  });
                }
              },
            ),
            if (_showProcessPicker && hasProcesses) ...[
              const SizedBox(height: 8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Builder(
                  builder: (context) {
                    final filteredProcesses =
                        _getFilteredProcesses(runningProcesses);

                    if (filteredProcesses.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No processes match your search',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredProcesses.length,
                      itemBuilder: (context, index) {
                        final process = filteredProcesses[index];
                        final isSelected =
                            _processNameController.text == process;

                        return ListTile(
                          dense: true,
                          selected: isSelected,
                          title: Text(
                            process,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _processNameController.text = process;
                              _showProcessPicker = false;
                            });
                            _processFieldFocus.unfocus();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ] else if (!hasProcesses) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Start monitoring to browse running processes',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _saveGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = context.read<AppState>();

    if (widget.gameToEdit != null) {
      // Update existing game
      final updatedGame = widget.gameToEdit!.copyWith(
        displayName: _displayNameController.text.trim(),
        processName: _processNameController.text.trim(),
        iconUrl: _iconUrlController.text.trim().isEmpty
            ? null
            : _iconUrlController.text.trim(),
        details: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
      );
      await appState.updateGame(widget.gameToEdit!.id, updatedGame);
    } else {
      // Add new game
      final newGame = appState.createGameProfile(
        displayName: _displayNameController.text.trim(),
        processName: _processNameController.text.trim(),
        iconUrl: _iconUrlController.text.trim().isEmpty
            ? null
            : _iconUrlController.text.trim(),
        details: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
      );
      await appState.addGame(newGame);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
