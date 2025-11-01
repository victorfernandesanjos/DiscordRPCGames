import 'dart:async';
import 'dart:io';

/// Service to monitor running processes on Windows
class ProcessMonitor {
  Timer? _monitorTimer;
  final Duration checkInterval;
  Set<String> _runningProcesses = {};

  ProcessMonitor({this.checkInterval = const Duration(seconds: 5)});

  /// Start monitoring processes
  void startMonitoring(Function(Set<String>) onProcessesUpdated) {
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(checkInterval, (_) async {
      final processes = await getRunningProcesses();
      if (!_setEquals(_runningProcesses, processes)) {
        _runningProcesses = processes;
        onProcessesUpdated(processes);
      }
    });
    // Initial check
    getRunningProcesses().then((processes) {
      _runningProcesses = processes;
      onProcessesUpdated(_runningProcesses);
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  /// Get list of currently running process names using tasklist command
  Future<Set<String>> getRunningProcesses() async {
    final processes = <String>{};

    try {
      // Use Windows tasklist command
      final result = await Process.run(
        'tasklist',
        ['/FO', 'CSV', '/NH'],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');

        for (final line in lines) {
          if (line.trim().isEmpty) continue;

          // Parse CSV format: "processname.exe","PID","Session","Mem","Status"
          final match = RegExp(r'^"([^"]+)"').firstMatch(line);
          if (match != null) {
            final processName = match.group(1)!.toLowerCase();
            processes.add(processName);
          }
        }
      }
    } catch (e) {
      // Return empty set on error
    }

    return processes;
  }

  /// Check if a specific process is running
  bool isProcessRunning(String processName) {
    return _runningProcesses.contains(processName.toLowerCase());
  }

  /// Get all running processes (cached)
  Set<String> get runningProcesses => Set.unmodifiable(_runningProcesses);

  /// Helper to compare sets
  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
