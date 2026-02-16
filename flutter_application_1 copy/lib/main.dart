import 'package:flutter/material.dart';
import 'data/transaction_store.dart';
import 'app/transaction_provider.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TransactionStore();
    return TransactionProvider(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Budget App',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const MainShell(),
      ),
    );
  }
}
