import 'package:daviedeborah/pages/home_page.dart';
import 'package:daviedeborah/pages/admin_page.dart';
import 'package:daviedeborah/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'config/app_theme.dart';
import 'utils/appsettings.dart';

final AppSettings appSettings = AppSettings();

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
  
  // Configuração de cache de imagens para otimizar uso em mobile
  // Limita o cache para evitar recarregamentos por falta de memória
  PaintingBinding.instance.imageCache.maximumSize = 50; // máx 50 imagens
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // máx 50 MB
  
  await initializeDateFormatting('pt_BR', null);
  final supabaseService = SupabaseService();
  await supabaseService.initialize();
  // Carregar versão no início
  appSettings.versaoAtual = await obterVersaoApp();
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
