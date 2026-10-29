import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/budget_provider.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    // App state is created once at the root, so every screen below can
    // read it and rebuild when it changes.
    ChangeNotifierProvider(
      create: (_) => BudgetProvider.withSampleData(),
      child: const BudgetApp(),
    ),
  );
}

/// Root widget: MaterialApp with a Material 3 theme and named routes.
class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Budget Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        AddTransactionScreen.routeName: (_) => const AddTransactionScreen(),
      },
    );
  }
}
