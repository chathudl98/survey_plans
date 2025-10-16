import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/plan_service.dart';

class PlanFormScreen extends StatefulWidget {
  final String officeId;
  final String? planId; // if editing
  final Map<String, dynamic>? initial;

  const PlanFormScreen({super.key, required this.officeId, this.planId, this.initial});

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? dateOfPlan;
  DateTime? dateOfSurvey;
  final acresCtrl = TextEditingController();
  final roodsCtrl = TextEditingController();
  final perchesCtrl = TextEditingController();
  final landCtrl = TextEditingController();
  final villageCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final jobCtrl = TextEditingController();
  final clientNameCtrl = TextEditingController();
  final clientPhoneCtrl = TextEditingController();
  final clientAddressCtrl = TextEditingController();

  bool saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    if (d != null) {
      dateOfPlan = (d['dateOfPlan'] as Timestamp).toDate();
      dateOfSurvey = (d['dateOfSurvey'] as Timestamp).toDate();
      final ex = d['extent'] as Map<String, dynamic>;
      acresCtrl.text = (ex['acres'] ?? 0).toString();
      roodsCtrl.text = (ex['roods'] ?? 0).toString();
      perchesCtrl.text = (ex['perches'] ?? 0).toString();
      final loc = d['location'] as Map<String, dynamic>;
      landCtrl.text = loc['landName'] ?? '';
      villageCtrl.text = loc['village'] ?? '';
      districtCtrl.text = loc['district'] ?? '';
      remarksCtrl.text = d['remarks'] ?? '';
      jobCtrl.text = d['jobNumber'] ?? '';
      clientNameCtrl.text = d['clientName'] ?? '';
      clientPhoneCtrl.text = d['clientPhone'] ?? '';
      clientAddressCtrl.text = d['clientAddress'] ?? '';
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => saving = true);

    final service = PlanService(FirebaseFirestore.instance, officeId: widget.officeId);

    final data = {
      'dateOfPlan': Timestamp.fromDate(dateOfPlan!),
      'dateOfSurvey': Timestamp.fromDate(dateOfSurvey!),
      'extent': {
        'acres': int.parse(acresCtrl.text),
        'roods': int.parse(roodsCtrl.text),
        'perches': int.parse(perchesCtrl.text),
      },
      'location': {
        'landName': landCtrl.text.trim(),
        'village': villageCtrl.text.trim(),
        'district': districtCtrl.text.trim(),
      },
      if (remarksCtrl.text.trim().isNotEmpty) 'remarks': remarksCtrl.text.trim(),
      if (jobCtrl.text.trim().isNotEmpty) 'jobNumber': jobCtrl.text.trim(),
      if (clientNameCtrl.text.trim().isNotEmpty) 'clientName': clientNameCtrl.text.trim(),
      if (clientPhoneCtrl.text.trim().isNotEmpty) 'clientPhone': clientPhoneCtrl.text.trim(),
      if (clientAddressCtrl.text.trim().isNotEmpty) 'clientAddress': clientAddressCtrl.text.trim(),
    };

    try {
      if (widget.planId == null) {
        await service.createPlan(data);
      } else {
        await service.updatePlan(widget.planId!, data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _pickDate(bool isPlan) async {
    final now = DateTime.now();
    final initial = isPlan ? (dateOfPlan ?? now) : (dateOfSurvey ?? now);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (picked != null) {
      setState(() {
        if (isPlan) {
          dateOfPlan = picked;
        } else {
          dateOfSurvey = picked;
        }
      });
    }
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _int(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return int.tryParse(v) == null ? 'Enter a number' : null;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.planId == null ? 'Create Plan' : 'Edit Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(dateOfPlan == null ? 'Date of Plan *' : 'Date of Plan: ${dateOfPlan!.toLocal().toString().split(' ').first}'),
                      trailing: const Icon(Icons.date_range),
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      title: Text(dateOfSurvey == null ? 'Date of Survey *' : 'Date of Survey: ${dateOfSurvey!.toLocal().toString().split(' ').first}'),
                      trailing: const Icon(Icons.date_range),
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const Text('Extent (A-R-P) *', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: acresCtrl, decoration: const InputDecoration(labelText: 'Acres'), validator: _int, keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: roodsCtrl, decoration: const InputDecoration(labelText: 'Roods'), validator: _int, keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: perchesCtrl, decoration: const InputDecoration(labelText: 'Perches'), validator: _int, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Location *', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(controller: landCtrl, decoration: const InputDecoration(labelText: 'Name of Land'), validator: _req),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: villageCtrl, decoration: const InputDecoration(labelText: 'Village'), validator: _req)),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: districtCtrl, decoration: const InputDecoration(labelText: 'District'), validator: _req)),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(controller: jobCtrl, decoration: const InputDecoration(labelText: 'Job Number (optional)')),
              TextFormField(controller: clientNameCtrl, decoration: const InputDecoration(labelText: 'Client Name (optional)')),
              TextFormField(controller: clientPhoneCtrl, decoration: const InputDecoration(labelText: 'Client Phone (optional)')),
              TextFormField(controller: clientAddressCtrl, decoration: const InputDecoration(labelText: 'Client Address (optional)')),
              TextFormField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks (optional)'), maxLines: 2),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: saving ? null : _save,
                  child: Text(saving ? 'Saving...' : 'Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
