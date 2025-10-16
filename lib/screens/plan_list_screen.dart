import 'package:flutter/material.dart';
import '../services/plan_service.dart';
import 'plan_form_screen.dart';

class PlanListScreen extends StatelessWidget {
  const PlanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: PlanService.streamPlans(),
        initialData: PlanService.plans,
        builder: (context, snap) {
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('No plans yet. Tap + to add.'));
          }
          return ListView.separated(
            itemBuilder: (c, i) {
              final p = items[i];
              return ListTile(
                title: Text(p['planNo'] ?? '—'),
                subtitle: Text(p['client'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => PlanService.deletePlan(p['planNo']),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlanFormScreen(initial: p)),
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: items.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlanFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
