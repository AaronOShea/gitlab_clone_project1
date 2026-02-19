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
  double _defaultMonthlyIncome = 3000;
  String _budgetCycleStart = '1st of month';
  int _savingsTargetPercent = 20;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final email = user?.email ?? 'Unknown user';
    final createdAt = user?.metadata.creationTime;
    final memberSince = _formatMemberSince(createdAt);
    final initials = _initialsFromEmail(email);
     final displayName = _displayName ?? _deriveDisplayNameFromEmail(email);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => _showEditDisplayNameDialog(context, displayName),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
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
                currentMonthSavingsPercent: 24,
                longestStreakMonths: 5,
                totalSavedFormatted:
                    '${_currencyLabel(_currency).split(' ').first} 12,450',
              ),
              const SizedBox(height: 24),
              Text(
                'Financial preferences',
                style: TextStyle(
                  fontSize: 17,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.currency_exchange_rounded),
                        title: const Text('Currency'),
                        subtitle: Text(
                          _currencyLabel(_currency),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: DropdownButton<String>(
                          value: _currency,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                              value: 'USD',
                              child: Text('USD'),
                            ),
                            DropdownMenuItem(
                              value: 'EUR',
                              child: Text('EUR'),
                            ),
                            DropdownMenuItem(
                              value: 'GBP',
                              child: Text('GBP'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _currency = value;
                            });
                          },
                        ),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.payments_rounded),
                        title: const Text('Default monthly income'),
                        subtitle: Text(
                          '${_currencyLabel(_currency).split(' ').first} ${_defaultMonthlyIncome.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: TextButton(
                          onPressed: () =>
                              _showEditIncomeDialog(context, _defaultMonthlyIncome),
                          child: const Text('Edit'),
                        ),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.calendar_month_rounded),
                        title: const Text('First day of budget cycle'),
                        subtitle: Text(
                          _budgetCycleStart,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: DropdownButton<String>(
                          value: _budgetCycleStart,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                              value: '1st of month',
                              child: Text('1st of month'),
                            ),
                            DropdownMenuItem(
                              value: 'Custom start date',
                              child: Text('Custom start date'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _budgetCycleStart = value;
                            });
                          },
                        ),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.savings_rounded),
                        title: const Text('Savings target percentage'),
                        subtitle: Text(
                          '$_savingsTargetPercent%',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: DropdownButton<int>(
                          value: _savingsTargetPercent,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                              value: 10,
                              child: Text('10%'),
                            ),
                            DropdownMenuItem(
                              value: 15,
                              child: Text('15%'),
                            ),
                            DropdownMenuItem(
                              value: 20,
                              child: Text('20%'),
                            ),
                            DropdownMenuItem(
                              value: 25,
                              child: Text('25%'),
                            ),
                            DropdownMenuItem(
                              value: 30,
                              child: Text('30%'),
                            ),
                            DropdownMenuItem(
                              value: 40,
                              child: Text('40%'),
                            ),
                            DropdownMenuItem(
                              value: 50,
                              child: Text('50%'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _savingsTargetPercent = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Data & Privacy',
                style: TextStyle(
                  fontSize: 17,
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
                    ListTile(
                      leading: const Icon(Icons.shield_rounded),
                      title: const Text('View data policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        // TODO: Navigate to data policy screen or open link.
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.download_rounded),
                      title: const Text('Download my data'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        // TODO: Trigger data export flow.
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.lock_outline_rounded),
                      title: const Text('AI uses anonymised data only'),
                      subtitle: Text(
                        'Aligned with GDPR and privacy-by-design.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever_rounded,
                        color: Color(0xFFB71C1C),
                      ),
                      title: const Text(
                        'Delete account',
                        style: TextStyle(
                          color: Color(0xFFB71C1C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => _confirmDeleteAccount(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'App settings',
                style: TextStyle(
                  fontSize: 17,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_rounded),
                        title: const Text('Notifications'),
                        value: _notifications,
                        onChanged: (value) {
                          setState(() {
                            _notifications = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await AuthService.instance.signOut();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFB71C1C),
                            side: const BorderSide(color: Color(0xFFB71C1C)),
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMemberSince(DateTime? createdAt) {
    if (createdAt == null) return 'Member since Feb 2026';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthName = months[createdAt.month - 1];
    return 'Member since $monthName ${createdAt.year}';
  }

  String _initialsFromEmail(String email) {
    final prefix = email.split('@').first;
    if (prefix.isEmpty) return '?';
    final parts = prefix.split('.');
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      final combined = '$first$second'.trim();
      return combined.isEmpty ? prefix[0].toUpperCase() : combined.toUpperCase();
    }
    return prefix[0].toUpperCase();
  }

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

  String _deriveDisplayNameFromEmail(String email) {
    final prefix = email.split('@').first;
    if (prefix.isEmpty) return 'Your profile';
    final parts = prefix.split('.');
    if (parts.length >= 2) {
      final first = parts[0];
      final second = parts[1];
      return '${_capitalise(first)} ${_capitalise(second)}';
    }
    return _capitalise(prefix);
  }

  String _capitalise(String value) {
    if (value.isEmpty) return value;
    if (value.length == 1) return value.toUpperCase();
    return value[0].toUpperCase() + value.substring(1);
  }

  Future<void> _showEditDisplayNameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit display name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Display name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _displayName = result;
      });
    }
  }

  Future<void> _showEditIncomeDialog(
    BuildContext context,
    double currentIncome,
  ) async {
    final controller =
        TextEditingController(text: currentIncome.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Default monthly income'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.replaceAll(',', '').trim();
                final value = double.tryParse(text);
                Navigator.of(context).pop(value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result > 0) {
      setState(() {
        _defaultMonthlyIncome = result;
      });
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: const Text(
            'This will permanently delete your account and associated data. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await AuthService.instance.deleteAccount();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete account. Please re-authenticate and try again.',
          ),
        ),
      );
    }
  }
}

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
      elevation: 0,
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
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memberSince,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
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
            label: 'Current month savings',
            value: '$currentMonthSavingsPercent%',
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Longest streak',
            value: '${longestStreakMonths} mo',
            color: const Color(0xFFAF52DE),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Total saved',
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
