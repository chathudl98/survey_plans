
import 'package:flutter/material.dart';
import '../services/plan_service.dart';

class PlanFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const PlanFormScreen({super.key, this.initial});

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _planNo = TextEditingController();
  final _client = TextEditingController();
  DateTime _surveyDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final data = widget.initial;
    if (data != null) {
      _planNo.text = data['planNo'] ?? '';
      _client.text = data['client'] ?? '';
      _surveyDate = DateTime.tryParse(data['surveyDate'] ?? '') ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _planNo.dispose();
    _client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initial == null ? 'New Plan' : 'Edit Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _planNo,
                decoration: const InputDecoration(labelText: 'Plan No. (unique)'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _client,
                decoration: const InputDecoration(labelText: 'Client'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Survey date: ${_surveyDate.toLocal().toString().split(' ').first}')),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: _surveyDate,
                      );
                      if (picked != null) setState(() => _surveyDate = picked);
                    },
                    child: const Text('Pick'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'planNo': _planNo.text.trim(),
                      'client': _client.text.trim(),
                      'surveyDate': _surveyDate.toIso8601String(),
                      'updatedAt': DateTime.now().toIso8601String(),
                    };
                    if (widget.initial == null) {
                      PlanService.addPlan(data);
                    } else {
                      PlanService.updatePlan(data['planNo'], data);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved (in-memory only)')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
