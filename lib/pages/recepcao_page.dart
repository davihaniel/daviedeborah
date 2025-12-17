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
          const SectionTitle(
            title: 'Recepção',
            subtitle: 'Hora de celebrar!',
          ),
          const SizedBox(height: 48),
          
          _buildReceptionDetails(context, isMobile),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildReceptionDetails(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 100,
      ),
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
                    '17:00h',
                    isMobile,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    FontAwesomeIcons.buildingColumns,
                    'Local',
                    'A recepção será no local da cerimônia',
                    isMobile,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Programação
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Programação',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildScheduleItem('17:00', 'Recepção dos convidados', isMobile),
                  _buildScheduleItem('17:30', 'Entrada dos noivos', isMobile),
                  _buildScheduleItem('18:30', 'Jantar', isMobile),
                  _buildScheduleItem('19:30', 'Corte do bolo', isMobile),
                  //_buildScheduleItem('21:00', 'Primeira valsa', isMobile),
                  //_buildScheduleItem('21:30', 'Pista de dança liberada', isMobile),
                  _buildScheduleItem('20:00', 'Encerramento', isMobile),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: isMobile ? 20 : 24,
          color: AppTheme.primaryColor,
        ),
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

  Widget _buildScheduleItem(String time, String event, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: isMobile ? 60 : 70,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: GoogleFonts.lato(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              event,
              style: GoogleFonts.lato(
                fontSize: isMobile ? 15 : 16,
                color: AppTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
  }
}
