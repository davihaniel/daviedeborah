import 'package:daviedeborah/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/section_title.dart';
import '../config/app_theme.dart';

class PresentesPage extends StatelessWidget {
  const PresentesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      color: AppTheme.lightGray,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const SectionTitle(
            title: 'Presentes',
            subtitle: 'Sua presença é nosso maior presente!',
          ),
          const SizedBox(height: 48),

          _buildGiftMessage(isMobile, context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGiftMessage(bool isMobile, BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : 1200,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          child: Column(
            children: [
              Icon(
                FontAwesomeIcons.heart,
                size: isMobile ? 40 : 50,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Queridos convidados,',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sua presença em nosso casamento já é o maior presente que poderíamos receber. '
                'No entanto, se desejar nos presentear, ficaremos muito felizes!',
                style: GoogleFonts.lato(
                  fontSize: isMobile ? 15 : 17,
                  color: AppTheme.textColor,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.key,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Chave PIX:',
                          style: GoogleFonts.lato(
                            fontSize: isMobile ? 14 : 16,
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SelectableText(
                          pixKey,
                          style: GoogleFonts.lato(
                            fontSize: isMobile ? 16 : 18,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: pixKey));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Chave PIX copiada para a área de transferência!',
                                  style: GoogleFonts.lato(),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.copy_outlined,
                            size: isMobile ? 16 : 18,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Titular: $pixHolderName - $pixBankName',
                style: GoogleFonts.lato(
                  fontSize: isMobile ? 13 : 14,
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
