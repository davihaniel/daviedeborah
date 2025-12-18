import 'package:daviedeborah/pages/home_page.dart';
import 'package:daviedeborah/pages/admin_page.dart';
import 'package:daviedeborah/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'config/app_theme.dart';

String versaoAtual = '';

/// Obtém a versão atual do aplicativo
Future<String> obterVersaoApp() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  } catch (e) {
    return 'desconhecida';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  final supabaseService = SupabaseService();
  await supabaseService.initialize();
  
  // Carregar versão no início
  versaoAtual = await obterVersaoApp();
  
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
