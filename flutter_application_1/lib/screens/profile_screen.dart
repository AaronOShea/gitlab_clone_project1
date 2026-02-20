import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _currency = 'EUR';
  bool _notifications = true;
  String? _displayName;
  double _defaultMonthlyIncome = 0;
  String _budgetCycleStart = '1st of month';
  int _savingsTargetPercent = 20;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final email = user?.email ?? 'user@example.com';
    final createdAt = user?.metadata.creationTime ?? DateTime.now();
    final displayName = _displayName ?? _deriveDisplayNameFromEmail(email);
    final initials = _initialsFromEmail(email);
    final memberSince = _formatMemberSince(createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () => _showEditDisplayNameDialog(context, displayName),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeaderCard(
                displayName: displayName,
                email: email,
                memberSince: memberSince,
                initials: initials,
              ),
              const SizedBox(height: 20),
              _StatsRow(
                currentMonthSavingsPercent: 0,
                longestStreakMonths: 0,
                totalSavedFormatted:
                    '${_currencyLabel(_currency).split(' ').first} 0',
              ),
              const SizedBox(height: 24),

              // --- Financial Preferences ---
              Text(
                'Financial Preferences',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 10),
              _FinancialPreferencesCard(
                currency: _currency,
                onCurrencyChanged: (val) =>
                    setState(() => _currency = val ?? _currency),
                monthlyIncome: _defaultMonthlyIncome,
                onEditIncome: () => _showEditIncomeDialog(
                    context, _defaultMonthlyIncome),
                budgetCycleStart: _budgetCycleStart,
                onCycleChanged: (val) =>
                    setState(() => _budgetCycleStart = val ?? _budgetCycleStart),
                savingsTargetPercent: _savingsTargetPercent,
                onSavingsChanged: (val) =>
                    setState(() => _savingsTargetPercent = val ?? _savingsTargetPercent),
              ),

              const SizedBox(height: 24),

              // --- App Settings ---
              Text(
                'App Settings',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_rounded),
                      title: const Text('Notifications'),
                      value: _notifications,
                      onChanged: (value) =>
                          setState(() => _notifications = value),
                    ),
                    const Divider(height: 0),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await AuthService.instance.signOut();
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB71C1C),
                          side: const BorderSide(color: Color(0xFFB71C1C)),
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Utility methods

  String _formatMemberSince(DateTime? date) {
    if (date == null) return 'Member since unknown';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Member since ${months[date.month - 1]} ${date.year}';
  }

  String _deriveDisplayNameFromEmail(String email) {
    final prefix = email.split('@').first;
    return prefix.isEmpty ? 'User' : prefix.split('.').map(_capitalize).join(' ');
  }

  String _initialsFromEmail(String email) {
    final prefix = email.split('@').first;
    if (prefix.isEmpty) return '?';
    final parts = prefix.split('.');
    return parts.length >= 2
        ? '${parts.first[0].toUpperCase()}${parts[1][0].toUpperCase()}'
        : prefix.substring(0, 1).toUpperCase();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _currencyLabel(String code) {
    switch (code) {
      case 'USD':
        return '\$ USD';
      case 'EUR':
        return '€ EUR';
      case 'GBP':
        return '£ GBP';
      default:
        return code;
    }
  }

  Future<void> _showEditDisplayNameDialog(BuildContext context, String name) async {
    final ctrl = TextEditingController(text: name);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit display name'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Display name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) setState(() => _displayName = newName);
  }

  Future<void> _showEditIncomeDialog(BuildContext context, double income) async {
    final ctrl = TextEditingController(text: income.toStringAsFixed(0));
    final val = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Default monthly income'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, double.tryParse(ctrl.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (val != null && val > 0) setState(() => _defaultMonthlyIncome = val);
  }
}

/// CARD SECTIONS

class _ProfileHeaderCard extends StatelessWidget {
  final String displayName;
  final String email;
  final String memberSince;
  final String initials;

  const _ProfileHeaderCard({
    required this.displayName,
    required this.email,
    required this.memberSince,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.green.shade100,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(email,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  const SizedBox(height: 4),
                  Text(memberSince,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int currentMonthSavingsPercent;
  final int longestStreakMonths;
  final String totalSavedFormatted;

  const _StatsRow({
    required this.currentMonthSavingsPercent,
    required this.longestStreakMonths,
    required this.totalSavedFormatted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Monthly Savings',
            value: '$currentMonthSavingsPercent%',
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Longest Streak',
            value: '${longestStreakMonths} mo',
            color: const Color(0xFFAF52DE),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Total Saved',
            value: totalSavedFormatted,
            color: const Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _FinancialPreferencesCard extends StatelessWidget {
  final String currency;
  final ValueChanged<String?> onCurrencyChanged;
  final double monthlyIncome;
  final VoidCallback onEditIncome;
  final String budgetCycleStart;
  final ValueChanged<String?> onCycleChanged;
  final int savingsTargetPercent;
  final ValueChanged<int?> onSavingsChanged;

  const _FinancialPreferencesCard({
    required this.currency,
    required this.onCurrencyChanged,
    required this.monthlyIncome,
    required this.onEditIncome,
    required this.budgetCycleStart,
    required this.onCycleChanged,
    required this.savingsTargetPercent,
    required this.onSavingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.currency_exchange_rounded),
            title: const Text('Currency'),
            subtitle: Text(currency),
            trailing: DropdownButton<String>(
              value: currency,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'GBP', child: Text('GBP')),
              ],
              onChanged: onCurrencyChanged,
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.payments_rounded),
            title: const Text('Default monthly income'),
            subtitle: Text('\$${monthlyIncome.toStringAsFixed(0)}'),
            trailing:
                TextButton(onPressed: onEditIncome, child: const Text('Edit')),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded),
            title: const Text('Budget cycle start'),
            subtitle: Text(budgetCycleStart),
            trailing: DropdownButton<String>(
              value: budgetCycleStart,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: '1st of month', child: Text('1st of month')),
                DropdownMenuItem(value: 'Custom start date', child: Text('Custom start date')),
              ],
              onChanged: onCycleChanged,
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.savings_rounded),
            title: const Text('Savings target'),
            subtitle: Text('$savingsTargetPercent%'),
            trailing: DropdownButton<int>(
              value: savingsTargetPercent,
              underline: const SizedBox(),
              items: const [10, 15, 20, 25, 30, 40, 50]
                  .map((p) => DropdownMenuItem(value: p, child: Text('$p%')))
                  .toList(),
              onChanged: onSavingsChanged,
            ),
          ),
        ],
      ),
    );
  }
}

