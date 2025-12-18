import 'package:daviedeborah/utils/extensions.dart';
import 'package:daviedeborah/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;
import '../widgets/section_title.dart';
import '../config/app_theme.dart';

class CerimoniaPage extends StatelessWidget {
  const CerimoniaPage({super.key});

  static bool _isMapRegistered = false;

  static void _registerMapIfNeeded() {
    if (_isMapRegistered) return;

    // Registra o iframe do Google Maps
    ui.platformViewRegistry.registerViewFactory('google-maps-iframe', (
      int viewId,
    ) {
      final iframe = web.HTMLIFrameElement()
        ..src =
            'https://maps.google.com/maps?q=-19.78285,-43.904057&hl=pt-BR&z=15&output=embed'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true
        ..loading = 'lazy';

      return iframe;
    });

    _isMapRegistered = true;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
    width: double.infinity,
      color: AppTheme.lightGray,
      child: Column(
        children: [
          const SizedBox(height: 48),
          const SectionTitle(
            title: 'Cerimônia',
            subtitle: 'Onde nos uniremos para sempre',
          ),
          const SizedBox(height: 48),

          _buildCeremonyDetails(context, isMobile),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildCeremonyDetails(BuildContext context, bool isMobile) {
    infos(CrossAxisAlignment cross) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: cross,
        children: [
          Icon(
            FontAwesomeIcons.church,
            size: isMobile ? 60 : 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 32),

          // Data e hora
          _buildInfoRow(
            FontAwesomeIcons.calendar,
            'Data',
            weddingDate.dataNomeMes,
            isMobile,
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            FontAwesomeIcons.clock,
            'Horário',
            weddingDate.hora,
            isMobile,
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            FontAwesomeIcons.locationDot,
            'Local',
            'Sítio Moriá',
            isMobile,
          ),
          const SizedBox(height: 16),
          SelectionArea(
            child: Text(
              'R. Dona Inházinha Castro, 5 - Chácaras Gervasio Monteiro, Santa Luzia - MG',
              style: GoogleFonts.lato(
                fontSize: isMobile ? 14 : 16,
                color: AppTheme.lightTextColor,
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
            ),
          ),

          const SizedBox(height: 32),

          // Botão de mapa
          ElevatedButton.icon(
            onPressed: () => _openMaps(),
            icon: const Icon(FontAwesomeIcons.mapLocationDot, size: 18),
            label: const Text('Ver no Mapa'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 16 : 20,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: isMobile ? double.infinity : 1200,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
      child: Column(
        children: [
          // Card principal
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 24 : 48),
              child: isMobile
                  ? Column(
                      children: [
                        infos(CrossAxisAlignment.center),
                        const SizedBox(height: 32),
                        _buildMapWidget(isMobile),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: infos(CrossAxisAlignment.start),
                        ),
                        const SizedBox(width: 32),
                        Expanded(flex: 1, child: _buildMapWidget(isMobile)),
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
                children: [_buildInfoSection(isMobile)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações Importantes',
          style: GoogleFonts.playfairDisplay(
            fontSize: isMobile ? 22 : 26,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoTile(
          FontAwesomeIcons.userCheck,
          'Chegada',
          'Pedimos que cheguem pontualmente para que possamos iniciar a cerimônia sem atrasos.',
          isMobile,
        ),
        const SizedBox(height: 16),
        _buildInfoTile(
          FontAwesomeIcons.shirt,
          'Dress Code',
          'Traje: Esporte Fino.',
          isMobile,
        ),
        const SizedBox(height: 16),
        _buildInfoTile(
          FontAwesomeIcons.camera,
          'Fotos e Vídeos',
          'Haverá profissionais registrando o momento. Pedimos que evitem fotos durante a cerimônia. Vivam o momento conosco!',
          isMobile,
        ),
        const SizedBox(height: 16),
        _buildInfoTile(
          FontAwesomeIcons.personDress,
          'Madrinhas e Padrinhos',
          'Os convidados honrados receberão comunicação separada',
          isMobile,
        ),
        const SizedBox(height: 16),
        _buildInfoTile(
          FontAwesomeIcons.car,
          'Estacionamento',
          'O local não oferece estacionamento. Mas, é possível estacionar na rua. Respeite as vagas dos moradores e a sinalização local.',
          isMobile,
        ),
      ],
    );
  }

  Widget _buildMapWidget(bool isMobile) {
    _registerMapIfNeeded();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: isMobile ? 300 : 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const HtmlElementView(viewType: 'google-maps-iframe'),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, size: isMobile ? 20 : 24, color: AppTheme.primaryColor),
        const SizedBox(width: 16),
        Column(
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String description,
    bool isMobile,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: isMobile ? 20 : 22, color: AppTheme.primaryColor),
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
                style: GoogleFonts.lato(
                  fontSize: isMobile ? 14 : 15,
                  color: AppTheme.lightTextColor,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openMaps() async {
    final url = Uri.parse('https://maps.app.goo.gl/RsmDn5ETuPBN6grq6');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
