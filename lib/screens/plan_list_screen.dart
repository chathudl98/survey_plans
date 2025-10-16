import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/plan_service.dart';
import 'plan_form_screen.dart';
import '../models/plan.dart';

class PlanListScreen extends StatefulWidget {
  final String officeId;
  const PlanListScreen({super.key, required this.officeId});

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen> {
  final planNoCtrl = TextEditingController();
  final jobCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  late final PlanService service;

  @override
  void initState() {
    super.initState();
    service = PlanService(FirebaseFirestore.instance, officeId: widget.officeId);
  }

  void _openCreate() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlanFormScreen(officeId: widget.officeId)));
  }

  void _openEdit(String id, Map<String, dynamic> data) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlanFormScreen(officeId: widget.officeId, planId: id, initial: data)));
  }

  Query<Map<String, dynamic>> _currentQuery() {
    final planNo = int.tryParse(planNoCtrl.text.trim());
    if (planNo != null) return service.searchByPlanNumber(planNo);
    if (jobCtrl.text.trim().isNotEmpty) return service.searchByJobNumberPrefix(jobCtrl.text.trim());
    if (nameCtrl.text.trim().isNotEmpty) return service.searchByClientNamePrefix(nameCtrl.text.trim());
    if (phoneCtrl.text.trim().isNotEmpty) return service.searchByClientPhonePrefix(phoneCtrl.text.trim());
    return service.listPlans();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _delete(String id) async {
    await service.deletePlan(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plans — Office: ${widget.officeId}'),
        actions: [
          IconButton(onPressed: _signOut, icon: const Icon(Icons.logout)),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        label: const Text('New Plan'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: planNoCtrl, decoration: const InputDecoration(labelText: 'Plan No'), keyboardType: TextInputType.number, onChanged: (_) => setState(() {}))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: jobCtrl, decoration: const InputDecoration(labelText: 'Job Number'), onChanged: (_) => setState(() {}))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Client Name'), onChanged: (_) => setState(() {}))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), onChanged: (_) => setState(() {}))),
                const SizedBox(width: 8),
                IconButton(onPressed: () {
                  planNoCtrl.clear(); jobCtrl.clear(); nameCtrl.clear(); phoneCtrl.clear();
                  setState(() {});
                }, icon: const Icon(Icons.clear)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _currentQuery().snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No plans found.'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final plan = Plan.fromMap(d.id, d.data());
                    return ListTile(
                      title: Text('Plan #${plan.planNumber} • ${plan.landName}, ${plan.village}'),
                      subtitle: Text('Job: ${plan.jobNumber ?? '-'} | Client: ${plan.clientName ?? '-'} | Phone: ${plan.clientPhone ?? '-'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _openEdit(plan.id, d.data())),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(plan.id)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
