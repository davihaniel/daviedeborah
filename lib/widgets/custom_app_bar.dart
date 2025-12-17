import 'package:daviedeborah/config/app_theme.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onNavigate;

  const CustomAppBar({super.key, required this.onNavigate});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return AppBar(
      title: GestureDetector(
        onTap: () => onNavigate('home'),
        // & menor que D D
        child: Text(
          'D&D',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      actions: isMobile
          ? [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ]
          : [
              _NavButton(label: 'Início', onTap: () => onNavigate('home')),
              _NavButton(label: 'O Casal', onTap: () => onNavigate('casal')),
              _NavButton(label: 'Cerimônia', onTap: () => onNavigate('cerimonia')),
              _NavButton(label: 'Recepção', onTap: () => onNavigate('recepcao')),
              _NavButton(label: 'Presentes', onTap: () => onNavigate('presentes')),
              _NavButton(label: 'Recados', onTap: () => onNavigate('recados')),
              const SizedBox(width: 16),
            ],
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Menu',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          _DrawerItem(label: 'Início', onTap: () {
            Navigator.pop(context);
            onNavigate('home');
          }),
          _DrawerItem(label: 'O Casal', onTap: () {
            Navigator.pop(context);
            onNavigate('casal');
          }),
          _DrawerItem(label: 'Cerimônia', onTap: () {
            Navigator.pop(context);
            onNavigate('cerimonia');
          }),
          _DrawerItem(label: 'Recepção', onTap: () {
            Navigator.pop(context);
            onNavigate('recepcao');
          }),
          _DrawerItem(label: 'Presentes', onTap: () {
            Navigator.pop(context);
            onNavigate('presentes');
          }),
          _DrawerItem(label: 'Recados', onTap: () {
            Navigator.pop(context);
            onNavigate('recados');
          }),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: AppTheme.secondaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: onTap,
    );
  }
}
