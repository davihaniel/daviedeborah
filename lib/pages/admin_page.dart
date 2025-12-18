import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'admin_login_page.dart';
import 'admin_dashboard_page.dart';
import '../stores/admin_store.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AdminStore _adminStore = AdminStore();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => _adminStore.isAutenticado
          ? AdminDashboardPage(
              adminStore: _adminStore,
              onLogout: () {
                setState(() {});
              },
            )
          : AdminLoginPage(
              store: _adminStore,
              onLoginSuccess: () {
                setState(() {});
              },
            ),
    );
  }
}
