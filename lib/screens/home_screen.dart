import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/game_profile.dart';
import 'add_game_dialog.dart';
import 'settings_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RPC Games - Discord Rich Presence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBar(context),
          const Divider(height: 1),
          Expanded(child: _buildGameList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGameDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Game'),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isMonitoring = appState.isMonitoring;
        final currentGame = appState.currentGame;
        final isConnected = appState.isDiscordConnected;

        return Container(
          padding: const EdgeInsets.all(16),
          color: isMonitoring
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isConnected ? Icons.check_circle : Icons.cancel,
                    color: isConnected ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected
                        ? 'Connected to Discord'
                        : 'Disconnected from Discord',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (appState.clientId != null)
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (isMonitoring) {
                          await appState.stopMonitoring();
                        } else {
                          try {
                            await appState.startMonitoring();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                      icon: Icon(isMonitoring ? Icons.stop : Icons.play_arrow),
                      label: Text(isMonitoring ? 'Stop' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMonitoring
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => _showSettings(context),
                      icon: const Icon(Icons.settings),
                      label: const Text('Configure'),
                    ),
                ],
              ),
              if (currentGame != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.videogame_asset, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Currently playing: ${currentGame.displayName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameList(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final games = appState.games;

        if (games.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videogame_asset_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No games added yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text('Click the + button to add a game'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: games.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final game = games[index];
            final isRunning = appState.runningProcesses.contains(
              game.processName.toLowerCase(),
            );

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: game.enabled ? Colors.blue : Colors.grey,
                  child: Icon(
                    isRunning ? Icons.play_arrow : Icons.videogame_asset,
                    color: Colors.white,
                  ),
                ),
                title: Text(game.displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Process: ${game.processName}'),
                    if (game.details != null) Text('Details: ${game.details}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRunning)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'RUNNING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                game.enabled
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              const SizedBox(width: 8),
                              Text(game.enabled ? 'Disable' : 'Enable'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditGameDialog(context, game);
                        } else if (value == 'toggle') {
                          appState.updateGame(
                            game.id,
                            game.copyWith(enabled: !game.enabled),
                          );
                        } else if (value == 'delete') {
                          _confirmDelete(context, game);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddGameDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddGameDialog());
  }

  void _showEditGameDialog(BuildContext context, GameProfile game) {
    showDialog(
      context: context,
      builder: (context) => AddGameDialog(gameToEdit: game),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }

  void _confirmDelete(BuildContext context, GameProfile game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: Text('Are you sure you want to delete "${game.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteGame(game.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
