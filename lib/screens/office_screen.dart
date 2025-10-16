import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfficeScreen extends StatefulWidget {
  const OfficeScreen({super.key});

  @override
  State<OfficeScreen> createState() => _OfficeScreenState();
}

class _OfficeScreenState extends State<OfficeScreen> {
  final officeCtrl = TextEditingController();

  Future<void> _save() async {
    final id = officeCtrl.text.trim();
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('officeId', id);
    if (mounted) Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Office ID')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your Office ID (e.g., galle-office-01)'),
                const SizedBox(height: 12),
                TextField(
                  controller: officeCtrl,
                  decoration: const InputDecoration(labelText: 'Office ID'),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _save, child: const Text('Save & Continue'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
