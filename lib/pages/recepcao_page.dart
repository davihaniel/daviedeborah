import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/section_title.dart';
import '../config/app_theme.dart';

class RecepcaoPage extends StatelessWidget {
  const RecepcaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const SectionTitle(title: 'Recepção', subtitle: 'Hora de celebrar!'),
          const SizedBox(height: 48),

          _buildReceptionDetails(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildReceptionDetails(BuildContext context, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 1200,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
      child: Column(
        children: [
          // Card principal
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 24 : 48),
              child: Column(
                children: [
                  Icon(
                    FontAwesomeIcons.champagneGlasses,
                    size: isMobile ? 60 : 80,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 32),

                  _buildInfoRow(
                    FontAwesomeIcons.clock,
                    'Horário',
                    'Após a cerimônia',
                    isMobile,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    FontAwesomeIcons.buildingColumns,
                    'Local',
                    'A recepção será no local',
                    isMobile,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          /*
          // Informações adicionais
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'O que esperar',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureTile(
                    FontAwesomeIcons.utensils,
                    'Jantar Completo',
                    'Menu com opções de carne, frango e vegetariano',
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureTile(
                    FontAwesomeIcons.martiniGlass,
                    'Bar Open',
                    'Bebidas variadas incluindo drinks especiais',
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureTile(
                    FontAwesomeIcons.music,
                    'DJ e Música ao Vivo',
                    'Playlist especial e banda durante o jantar',
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureTile(
                    FontAwesomeIcons.cakeCandles,
                    'Doces e Sobremesas',
                    'Mesa de doces finos e tortas especiais',
                    isMobile,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureTile(
                    FontAwesomeIcons.car,
                    'Estacionamento',
                    'O local não oferece estacionamento. Mas, é possível estacionar na rua. Respeite as vagas dos moradores e a sinalização local.',
                    isMobile,
                  ),
                ],
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isMobile,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: isMobile ? 20 : 24, color: AppTheme.primaryColor),
        const SizedBox(width: 16),
        Expanded(
          flex: isMobile ? 1 : 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: isMobile ? 12 : 14,
                  color: AppTheme.lightTextColor,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /*
  Widget _buildFeatureTile(IconData icon, String title, String description, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isMobile ? 20 : 22,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                softWrap: true,
                style: GoogleFonts.lato(
                  fontSize: isMobile ? 14 : 15,
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }*/
}
