enum ReportPeriod { weekly, monthly, yearly }

class ReportBucket {
  final String label;
  final int income;
  final int expense;

  const ReportBucket({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class ReportModel {
  final int income;
  final int expense;
  final List<ReportBucket> buckets;
  final Map<String, int> expenseByCategory;

  const ReportModel({
    required this.income,
    required this.expense,
    required this.buckets,
    required this.expenseByCategory,
  });

  int get net => income - expense;
  bool get isEmpty => income == 0 && expense == 0;
}
