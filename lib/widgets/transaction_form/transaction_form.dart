import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_clock.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/dummy_data.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../category_chip/category_chip.dart';
import '../common/app_snackbar.dart';
import '../common/custom_text_field.dart';
import '../common/primary_button.dart';
import '../common/secondary_button.dart';
import 'amount_input.dart';

/// Form yang dipakai bersama oleh halaman Catat dan Edit Transaksi.
/// Sama dengan batas 12 digit pada kolom nominal.
const int _maxAmount = 999999999999;

class TransactionForm extends StatefulWidget {
  final TransactionModel? initial;
  final String submitLabel;
  final ValueChanged<TransactionModel> onSubmit;

  const TransactionForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => TransactionFormState();
}

class TransactionFormState extends State<TransactionForm> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _customCategoryController = TextEditingController();

  late TransactionType _type;
  String? _category;
  bool _customCategory = false;
  String? _walletId;
  late DateTime _date;
  late TimeOfDay _time;

  String? _amountError;
  String? _categoryError;
  String? _walletError;

  @override
  void initState() {
    super.initState();
    _applyInitial();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _applyInitial() {
    final t = widget.initial;
    _type = t?.type ?? TransactionType.expense;
    _amountController.text = t == null ? '' : Formatters.grouped(t.amount);
    _titleController.text = t?.title ?? '';
    _noteController.text = t?.note ?? '';
    final category = t?.category;
    final isPreset = t != null &&
        DummyData.categories
            .any((c) => c.type == t.type && c.name == t.category);
    _customCategory = category != null && !isPreset;
    _category = isPreset ? category : null;
    _customCategoryController.text = _customCategory ? category! : '';
    _walletId = t?.walletId;
    final d = t?.date ?? AppClock.today();
    _date = DateTime(d.year, d.month, d.day);
    _time = t == null
        ? TimeOfDay.now()
        : TimeOfDay(hour: t.date.hour, minute: t.date.minute);
    _amountError = null;
    _categoryError = null;
    _walletError = null;
  }

  /// Dipanggil tombol "Reset" pada halaman Catat Transaksi.
  void reset() => setState(_applyInitial);

  int get _amount =>
      int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

  Color get _typeColor =>
      _type == TransactionType.expense ? AppColors.expense : AppColors.income;

  void _setType(TransactionType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _category = null;
      _customCategory = false;
      _customCategoryController.clear();
      _categoryError = null;
    });
  }

  /// Kategori final: pilihan chip, atau teks manual (dirapikan dan disamakan
  /// dengan kategori yang sudah ada agar tidak terpecah karena beda huruf).
  String? _resolvedCategory() {
    if (!_customCategory) return _category;
    final typed =
        _customCategoryController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (typed.isEmpty) return null;

    final lower = typed.toLowerCase();
    for (final c in DummyData.categories) {
      if (c.name.toLowerCase() == lower) return c.name;
    }
    for (final t in context.read<AppState>().transactions) {
      if (t.category.toLowerCase() == lower) return t.category;
    }
    return typed;
  }

  void _quickAdd(int value) {
    setState(() {
      _amountController.text =
          Formatters.grouped(math.min(_amount + value, _maxAmount));
      _amountError = null;
    });
  }

  Future<void> _pickDate() async {
    final today = AppClock.today();
    // Tidak boleh tanggal masa depan, kecuali transaksi lama yang memang
    // sudah bertanggal lebih akhir (agar tidak error saat diedit).
    final lastDate = _date.isAfter(today) ? _date : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: lastDate,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() {
      _amountError =
          _amount > 0 ? null : 'Nominal transaksi harus lebih dari Rp0';
      _categoryError = _resolvedCategory() == null
          ? (_customCategory
              ? 'Tulis nama kategori'
              : 'Pilih kategori transaksi')
          : null;
      _walletError = _walletId == null ? 'Pilih sumber dana' : null;
    });

    final error = _amountError ?? _categoryError ?? _walletError;
    if (error != null) {
      AppSnackbar.error(context, error);
      return;
    }

    final category = _resolvedCategory()!;
    final typedTitle = _titleController.text.trim();
    widget.onSubmit(
      TransactionModel(
        id: widget.initial?.id ?? 't_${DateTime.now().microsecondsSinceEpoch}',
        title: typedTitle.isEmpty ? category : typedTitle,
        amount: _amount,
        type: _type,
        category: category,
        walletId: _walletId!,
        date: DateTime(
            _date.year, _date.month, _date.day, _time.hour, _time.minute),
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = context.watch<AppState>().wallets;
    final categories =
        DummyData.categories.where((c) => c.type == _type).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypeSwitch(type: _type, onChanged: _setType),
        const SizedBox(height: 20),
        AmountInput(
          controller: _amountController,
          color: _typeColor,
          errorText: _amountError,
          onQuickAdd: _quickAdd,
          onChanged: () {
            if (_amountError != null) setState(() => _amountError = null);
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Nama Transaksi (opsional)',
          hint: 'Contoh: Makan siang',
          controller: _titleController,
          prefixIcon: Icons.edit_outlined,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        Text('Pilih Kategori', style: AppTextStyles.label),
        const SizedBox(height: 10),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              if (i == categories.length) {
                return CategoryChip(
                  category: CategoryModel(
                    id: 'c_custom',
                    name: 'Kategori Lain',
                    icon: Icons.add_rounded,
                    type: _type,
                  ),
                  selected: _customCategory,
                  onTap: () => setState(() {
                    _customCategory = true;
                    _category = null;
                    _categoryError = null;
                  }),
                );
              }
              return CategoryChip(
                category: categories[i],
                selected: !_customCategory && _category == categories[i].name,
                onTap: () => setState(() {
                  _customCategory = false;
                  _category = categories[i].name;
                  _categoryError = null;
                }),
              );
            },
          ),
        ),
        if (_customCategory) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _customCategoryController,
            maxLength: 30,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_categoryError != null) {
                setState(() => _categoryError = null);
              }
            },
            decoration: InputDecoration(
              hintText: _type == TransactionType.expense
                  ? 'Nama kategori, mis. Zakat'
                  : 'Nama kategori, mis. Freelance',
              prefixIcon: const Icon(Icons.category_outlined),
              counterText: '',
            ),
          ),
        ],
        if (_categoryError != null) _ErrorText(_categoryError!),
        const SizedBox(height: 20),
        Text('Sumber Dana', style: AppTextStyles.label),
        const SizedBox(height: 10),
        if (wallets.isEmpty) ...[
          Text(
            'Belum ada dompet. Tambahkan dompet terlebih dahulu.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Tambah Dompet',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.wallets),
          ),
        ] else
          for (final w in wallets)
            _WalletOption(
              name: w.name,
              balance: Formatters.rupiah(w.balance),
              selected: _walletId == w.id,
              onTap: () => setState(() {
                _walletId = w.id;
                _walletError = null;
              }),
            ),
        if (_walletError != null) _ErrorText(_walletError!),
        const SizedBox(height: 20),
        Text('Waktu Transaksi', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PickerTile(
                icon: Icons.calendar_today_rounded,
                value: Formatters.shortDate(_date),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PickerTile(
                icon: Icons.access_time_rounded,
                value: _time.format(context),
                onTap: _pickTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Catatan / Keterangan',
          hint: 'Tulis catatan...',
          controller: _noteController,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: widget.submitLabel,
          onPressed: _submit,
          color: _typeColor,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TypeSwitch extends StatelessWidget {
  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  const _TypeSwitch({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'Pengeluaran',
              icon: Icons.arrow_upward_rounded,
              color: AppColors.expense,
              selected: type == TransactionType.expense,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'Pemasukan',
              icon: Icons.arrow_downward_rounded,
              color: AppColors.income,
              selected: type == TransactionType.income,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletOption extends StatelessWidget {
  final String name;
  final String balance;
  final bool selected;
  final VoidCallback onTap;

  const _WalletOption({
    required this.name,
    required this.balance,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: '$name, saldo $balance',
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.lightGreen : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(fontSize: 14)),
                ),
                const SizedBox(width: 8),
                Text(balance, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;

  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: AppColors.expense),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}
