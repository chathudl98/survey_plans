class Plan {
  final String id;
  final int planNumber;
  final DateTime dateOfPlan;
  final DateTime dateOfSurvey;
  final int acres, roods, perches;
  final String landName, village, district;
  final String? remarks, jobNumber, clientName, clientPhone, clientAddress;

  Plan({
    required this.id,
    required this.planNumber,
    required this.dateOfPlan,
    required this.dateOfSurvey,
    required this.acres,
    required this.roods,
    required this.perches,
    required this.landName,
    required this.village,
    required this.district,
    this.remarks,
    this.jobNumber,
    this.clientName,
    this.clientPhone,
    this.clientAddress,
  });

  factory Plan.fromMap(String id, Map<String, dynamic> d) {
    final loc = (d['location'] as Map<String, dynamic>);
    final ex = (d['extent'] as Map<String, dynamic>);
    return Plan(
      id: id,
      planNumber: d['planNumber'] as int,
      dateOfPlan: (d['dateOfPlan'] as dynamic).toDate(),
      dateOfSurvey: (d['dateOfSurvey'] as dynamic).toDate(),
      acres: ex['acres'] as int,
      roods: ex['roods'] as int,
      perches: ex['perches'] as int,
      landName: loc['landName'] as String,
      village: loc['village'] as String,
      district: loc['district'] as String,
      remarks: d['remarks'] as String?,
      jobNumber: d['jobNumber'] as String?,
      clientName: d['clientName'] as String?,
      clientPhone: d['clientPhone'] as String?,
      clientAddress: d['clientAddress'] as String?,
    );
  }
}
