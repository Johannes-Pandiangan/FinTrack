class Formatters {
  Formatters._();

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static String _group(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
        );
  }

  static String _sign(int value, bool withSign) {
    if (value < 0) return '-';
    return withSign ? '+' : '';
  }

  /// Contoh: 185000 -> "Rp185.000", -185000 -> "-Rp185.000"
  static String rupiah(int amount, {bool withSign = false}) {
    return '${_sign(amount, withSign)}Rp${_group(amount.abs())}';
  }

  /// Contoh: 12150000 -> "Rp12.15 Jt"
  static String rupiahCompact(int amount, {bool withSign = false}) {
    final juta = (amount.abs() / 1000000).toStringAsFixed(2);
    return '${_sign(amount, withSign)}Rp$juta Jt';
  }

  /// Contoh: "Kamis, 24 Oktober 2024"
  static String fullDate(DateTime d) =>
      '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

  /// Contoh: "24 Okt 2024"
  static String shortDate(DateTime d) =>
      '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

  /// Contoh: "Oktober 2024"
  static String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  /// Contoh: "08:30"
  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String grouped(int value) => _group(value);

  /// Contoh: "21 Oktober 2024"
  static String longDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';
}
