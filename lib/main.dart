import 'package:daviedeborah/pages/home_page.dart';
import 'package:daviedeborah/pages/admin_page.dart';
import 'package:daviedeborah/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  final supabaseService = SupabaseService();
  await supabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Davi & Deborah - Casamento',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomePage(),
      routes: {'/admin': (context) => const AdminPage()},
    );
  }
}
