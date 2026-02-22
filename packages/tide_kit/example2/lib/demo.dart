import 'package:flutter/material.dart';

import 'flutter_dock_manager.dart';

// Main entry point
void main() {
  runApp(const DockingApp());
}

class DockingApp extends StatelessWidget {
  const DockingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Docking Layout Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DockingExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Example usage widget
class DockingExample extends StatefulWidget {
  const DockingExample({super.key});

  @override
  State<DockingExample> createState() => _DockingExampleState();
}

class _DockingExampleState extends State<DockingExample> {
  late GlobalKey<DockingLayoutManagerState> dockingKey;

  @override
  void initState() {
    super.initState();
    dockingKey = GlobalKey<DockingLayoutManagerState>();
  }

  @override
  Widget build(BuildContext context) {
    final panel1 = DockPanel(
      id: 'panel1',
      title: 'File Explorer',
      icon: Icons.folder_open,
      content: _buildExplorerPanel(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Docking Layout Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewPanel,
          ),
        ],
      ),
      body: DockingLayoutManager(
        key: dockingKey,
        initialPanels: [
          panel1,
          DockPanel(
            id: 'panel2',
            title: 'Code Editor',
            icon: Icons.code,
            content: _buildEditorPanel(),
          ),
          DockPanel(
            id: 'panel3',
            title: 'Debug Console',
            icon: Icons.bug_report,
            content: _buildTerminalPanel(),
          ),
          DockPanel(
            id: 'panel4',
            title: 'Properties',
            icon: Icons.settings,
            content: _buildPropertiesPanel(),
          ),
        ],
      ),
    );
  }

  void _addNewPanel() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final panel = DockPanel(
      id: 'panel_$timestamp',
      title: 'Panel $timestamp',
      icon: Icons.insert_drive_file,
      content: Center(
        child: Text('Dynamic Panel $timestamp'),
      ),
    );

    dockingKey.currentState?.addPanel(panel);
  }

  Widget _buildExplorerPanel() {
    final files = [
      {
        'name': 'lib',
        'type': 'folder',
        'children': [
          {'name': 'main.dart', 'type': 'file'},
          {'name': 'models', 'type': 'folder'},
          {'name': 'widgets', 'type': 'folder'},
        ]
      },
      {'name': 'test', 'type': 'folder'},
      {'name': 'pubspec.yaml', 'type': 'file'},
      {'name': 'README.md', 'type': 'file'},
      {'name': 'analysis_options.yaml', 'type': 'file'},
    ];

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_open, size: 16),
                const SizedBox(width: 8),
                Text(
                  'PROJECT EXPLORER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  onPressed: () {},
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  leading: Icon(
                    file['type'] == 'folder'
                        ? Icons.folder
                        : Icons.insert_drive_file,
                    size: 16,
                    color: file['type'] == 'folder' ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    file['name'] as String,
                    style: const TextStyle(fontSize: 13),
                  ),
                  dense: true,
                  onTap: () {
                    // Handle file selection
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'main.dart',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.save, size: 18),
                onPressed: () {},
                tooltip: 'Save',
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow, size: 18),
                onPressed: () {},
                tooltip: 'Run',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: const SingleChildScrollView(
                child: Text(
                  'Text here',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalPanel() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'DEBUG CONSOLE',
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 16),
                  onPressed: () {},
                  tooltip: 'Clear Console',
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 8),
          const Text(
            'Flutter run key commands.',
            style: TextStyle(
                color: Colors.yellow, fontFamily: 'monospace', fontSize: 12),
          ),
          const Text(
            'r Hot reload. 🔥🔥🔥',
            style: TextStyle(
                color: Colors.white, fontFamily: 'monospace', fontSize: 12),
          ),
          const Text(
            'R Hot restart.',
            style: TextStyle(
                color: Colors.white, fontFamily: 'monospace', fontSize: 12),
          ),
          const Text(
            'h List all available interactive commands.',
            style: TextStyle(
                color: Colors.white, fontFamily: 'monospace', fontSize: 12),
          ),
          const SizedBox(height: 16),
          const Text(
            '> flutter run',
            style: TextStyle(
                color: Colors.green, fontFamily: 'monospace', fontSize: 12),
          ),
          const Text(
            'Launching lib/main.dart on Chrome in debug mode...',
            style: TextStyle(
                color: Colors.white, fontFamily: 'monospace', fontSize: 12),
          ),
          const Text(
            'lib/main.dart is being served at http://localhost:3000',
            style: TextStyle(
                color: Colors.blue, fontFamily: 'monospace', fontSize: 12),
          ),
          const Text(
            '✓ Built build/web.',
            style: TextStyle(
                color: Colors.green, fontFamily: 'monospace', fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            'Flutter run key commands.',
            style: TextStyle(
                color: Colors.yellow, fontFamily: 'monospace', fontSize: 12),
          ),
          Expanded(child: Container()),
          const Row(
            children: [
              Text(
                '> ',
                style: TextStyle(
                    color: Colors.green, fontFamily: 'monospace', fontSize: 12),
              ),
              Expanded(
                child: SizedBox(
                  height: 20,
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesPanel() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Icon(Icons.settings, size: 16),
                const SizedBox(width: 8),
                Text(
                  'PROPERTIES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const ListTile(
                  title: Text('Widget Type', style: TextStyle(fontSize: 13)),
                  subtitle:
                      Text('StatefulWidget', style: TextStyle(fontSize: 12)),
                  dense: true,
                ),
                const ListTile(
                  title: Text('Hot Reload', style: TextStyle(fontSize: 13)),
                  subtitle: Text('Enabled', style: TextStyle(fontSize: 12)),
                  dense: true,
                ),
                ListTile(
                  title:
                      const Text('Debug Mode', style: TextStyle(fontSize: 13)),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                  dense: true,
                ),
                const ListTile(
                  title: Text('Platform', style: TextStyle(fontSize: 13)),
                  subtitle: Text('Web', style: TextStyle(fontSize: 12)),
                  dense: true,
                ),
                const ListTile(
                  title: Text('Dart Version', style: TextStyle(fontSize: 13)),
                  subtitle: Text('3.2.0', style: TextStyle(fontSize: 12)),
                  dense: true,
                ),
                const ListTile(
                  title:
                      Text('Flutter Version', style: TextStyle(fontSize: 13)),
                  subtitle: Text('3.16.0', style: TextStyle(fontSize: 12)),
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
