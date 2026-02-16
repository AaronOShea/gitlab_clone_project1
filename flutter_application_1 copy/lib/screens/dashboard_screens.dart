import 'package:flutter/material.dart';
import '../app/transaction_provider.dart';
import '../data/transaction_store.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';
import 'category_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _categoryIcons = {
    'Food': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Bills': Icons.receipt_long_rounded,
    'Entertainment': Icons.movie_rounded,
    'Health': Icons.favorite_rounded,
    'Other': Icons.category_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final store = TransactionProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(
                initialType: TransactionType.expense,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final income = store.incomeThisMonth;
          final spent = store.spentThisMonth;
          final left = store.remainingThisMonth;
          final expenses = store.expensesThisMonth;
          final byCategory = store.spentByCategoryThisMonth;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MonthHeader(),
                      const SizedBox(height: 16),
                      _SummarySection(
                        moneyIn: income,
                        spent: spent,
                        left: left,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle('Budget by category'),
                      const SizedBox(height: 10),
                      _BudgetCategoriesList(
                        byCategory: byCategory,
                        store: store,
                        categoryIcons: _categoryIcons,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle('Recent expenses'),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              if (expenses.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Center(
                      child: Text(
                        'No expenses this month yet.\nTap "Add Expense" to log one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final t = expenses[index];
                        return _ExpenseListTile(
                          transaction: t,
                          categoryIcons: _categoryIcons,
                        );
                      },
                      childCount: expenses.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    final monthName = months[now.month - 1];
    return Text(
      monthName,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final double moneyIn;
  final double spent;
  final double left;

  const _SummarySection({
    required this.moneyIn,
    required this.spent,
    required this.left,
  });

  static String _fmt(double v) {
    final abs = v.abs();
    if (abs >= 1000) {
      final s = abs.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
      return '${v < 0 ? '-' : ''}\$$s';
    }
    return '\$${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Money In',
            value: moneyIn,
            color: const Color(0xFF2E7D32),
            formatValue: _fmt(moneyIn),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Spent',
            value: spent,
            color: const Color(0xFFB71C1C),
            formatValue: _fmt(spent),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            label: 'Left',
            value: left,
            color: left >= 0
                ? const Color(0xFF1B5E20)
                : const Color(0xFFB71C1C),
            formatValue: _fmt(left),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String formatValue;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.formatValue,
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
              formatValue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }
}

class _BudgetCategoriesList extends StatelessWidget {
  final Map<String, double> byCategory;
  final TransactionStore store;
  final Map<String, IconData> categoryIcons;

  const _BudgetCategoriesList({
    required this.byCategory,
    required this.store,
    required this.categoryIcons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: expenseCategories.map((category) {
        final spent = byCategory[category] ?? 0.0;
        final limit = store.getCategoryLimit(category);
        return _BudgetCategoryCard(
          categoryName: category,
          spent: spent,
          limit: limit,
          icon: categoryIcons[category] ?? Icons.category_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryDetailScreen(categoryName: category),
              ),
            );
          },
          onSetLimit: () => _showSetLimitDialog(context, store, category),
        );
      }).toList(),
    );
  }

  void _showSetLimitDialog(
    BuildContext context,
    TransactionStore store,
    String category,
  ) {
    final controller = TextEditingController(
      text: store.getCategoryLimit(category)?.toStringAsFixed(0) ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set limit for $category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Monthly limit',
            prefixText: '\$ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              if (amount != null && amount > 0) {
                store.setCategoryLimit(category, amount);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryCard extends StatelessWidget {
  final String categoryName;
  final double spent;
  final double? limit;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onSetLimit;

  const _BudgetCategoryCard({
    required this.categoryName,
    required this.spent,
    required this.limit,
    required this.icon,
    required this.onTap,
    required this.onSetLimit,
  });

  @override
  Widget build(BuildContext context) {
    final hasLimit = limit != null && limit! > 0;
    final ratio = hasLimit ? (spent / limit!).clamp(0.0, 1.5) : 0.0;
    Color barColor;
    if (!hasLimit) {
      barColor = Colors.grey.shade300;
    } else if (ratio <= 0.75) {
      barColor = const Color(0xFF2E7D32);
    } else if (ratio <= 1.0) {
      barColor = const Color(0xFFF9A825);
    } else {
      barColor = const Color(0xFFB71C1C);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.green.shade700, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (hasLimit)
                    TextButton(
                      onPressed: () => onSetLimit(),
                      child: const Text('Edit limit'),
                    )
                  else
                    TextButton(
                      onPressed: () => onSetLimit(),
                      child: const Text('Set limit'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                hasLimit
                    ? '\$${spent.toStringAsFixed(0)} / \$${limit!.toStringAsFixed(0)}'
                    : 'Spent: \$${spent.toStringAsFixed(0)} (no limit set)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: hasLimit ? ratio.clamp(0.0, 1.0) : 0.0,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
              if (hasLimit && ratio > 1.0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Over by \$${(spent - limit!).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB71C1C),
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

class _ExpenseListTile extends StatelessWidget {
  final Transaction transaction;
  final Map<String, IconData> categoryIcons;

  const _ExpenseListTile({
    required this.transaction,
    required this.categoryIcons,
  });

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final icon = categoryIcons[transaction.category] ?? Icons.category_rounded;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.green.shade700, size: 22),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDate(transaction.date),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Text(
          '\$${transaction.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1B5E20),
          ),
        ),
      ),
    );
  }
}
