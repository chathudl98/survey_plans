import 'dart:async';

class PlanService {
  static final List<Map<String, dynamic>> _plans = [];
  static final _controller = StreamController<List<Map<String, dynamic>>>.broadcast();

  static List<Map<String, dynamic>> get plans => List.unmodifiable(_plans);

  static Stream<List<Map<String, dynamic>>> streamPlans() => _controller.stream;

  static void _emit() => _controller.add(List.unmodifiable(_plans));

  static void addPlan(Map<String, dynamic> data) {
    final id = data['planNo'];
    if (_plans.any((p) => p['planNo'] == id)) {
      // overwrite
      final idx = _plans.indexWhere((p) => p['planNo'] == id);
      _plans[idx] = data;
    } else {
      _plans.add(data);
    }
    _emit();
  }

  static void updatePlan(String id, Map<String, dynamic> data) {
    final idx = _plans.indexWhere((p) => p['planNo'] == id);
    if (idx != -1) {
      _plans[idx] = data;
      _emit();
    }
  }

  static void deletePlan(String id) {
    _plans.removeWhere((p) => p['planNo'] == id);
    _emit();
  }
}
