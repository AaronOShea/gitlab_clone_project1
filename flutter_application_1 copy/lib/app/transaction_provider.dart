import 'package:flutter/material.dart';
import '../data/transaction_store.dart';

class TransactionProvider extends InheritedNotifier<TransactionStore> {
  const TransactionProvider({
    super.key,
    required TransactionStore store,
    required super.child,
  }) : super(notifier: store);

  static TransactionStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<TransactionProvider>();
    assert(provider != null, 'No TransactionProvider found in context');
    return provider!.notifier!;
  }
}
