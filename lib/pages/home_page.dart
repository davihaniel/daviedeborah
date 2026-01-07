import 'package:cached_network_image/cached_network_image.dart';
import 'package:daviedeborah/stores/home_store.dart';
import 'package:daviedeborah/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import '../config/app_theme.dart';
import '../widgets/section_title.dart';
import 'casal_page.dart';
import 'cerimonia_page.dart';
import 'recepcao_page.dart';
import 'presentes_page.dart';
import 'rsvp_page.dart';
import 'recados_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final _store = HomeStore();
  final rsvpLimit = DateTime.now().isAfter(appSettings.rsvpLimitDate);

  late String fundoAleatorio;

  final Map<String, GlobalKey> _sectionKeys = {
    'home': GlobalKey(),
    'casal': GlobalKey(),
    'cerimonia': GlobalKey(),
    'recepcao': GlobalKey(),
    'presentes': GlobalKey(),
    'rsvp': GlobalKey(),
    'recados': GlobalKey(),
  };

  void _scrollToSection(String section) {
    final key = _sectionKeys[section];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fundoAleatorio = appSettings.getRandomBackgroundImage();
    _store.startTimer();
    _scrollController.addListener(() => _store.onScroll(_scrollController));

    // Inicia pré-carregamento de forma segura após o primeiro frame,
    // limitando a quantidade em mobile para evitar estouro de memória.
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 600;
      final imagens = List<String>.from(appSettings.galeryImages);

      if (imagens.isEmpty) return;

      if (isMobile) {
        // Em mobile: pré-carrega só as 3 primeiras, com intervalo maior
        ImageCacheService().precacheImagesWithDelay(
          context,
          imagens.take(3).toList(),
          delayBetween: const Duration(milliseconds: 300),
        );
      } else {
        // Em telas maiores: pré-carrega até 10 imagens de forma gradual
        ImageCacheService().precacheImagesWithDelay(
          context,
          imagens.take(10).toList(),
          delayBetween: const Duration(milliseconds: 150),
        );
      }
    });*/
  }

  @override
  void dispose() {
    _store.timer.cancel();
    _scrollController.removeListener(() => _store.onScroll(_scrollController));
    _scrollController.dispose();
    super.dispose();
  }

  // Método auxiliar para envolver seções com cor de fundo alternada
  List<Widget> _buildSections(bool isMobile) {
    final sections = [
      // Hero Section
      Container(
        key: _sectionKeys['home'],
        child: _buildHeroSection(context, isMobile),
      ),
      // Versiculo
      _buildVersiculo(isMobile),
      // Mensagem dos Noivos
      _buildMensagemNoivos(isMobile),
      // Contador de dias
      Observer(
        builder: (_) {
          return _buildCountdownSection(isMobile, _store.now);
        },
      ),
      // O Casal Section
      Container(key: _sectionKeys['casal'], child: const CasalPage()),
      // Cerimônia Section
      Container(key: _sectionKeys['cerimonia'], child: const CerimoniaPage()),
      // Recepção Section
      Container(key: _sectionKeys['recepcao'], child: const RecepcaoPage()),
      // Presentes Section
      Container(key: _sectionKeys['presentes'], child: const PresentesPage()),
      if (!rsvpLimit && appSettings.rsvpEnable)
        // RSVP Section
        Container(key: _sectionKeys['rsvp'], child: const RsvpPage()),
      // Recados Section
      Container(key: _sectionKeys['recados'], child: const RecadosPage()),
      // Footer
      _buildFooter(isMobile),
    ];

    return sections.asMap().entries.map((entry) {
      final index = entry.key;
      final widget = entry.value;
      final hasBackground = index.isOdd;

      return Container(
        width: double.infinity,
        color: hasBackground ? AppTheme.lightGray : null,
        child: widget,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // SliverAppBar que controla show/hide
          SliverAppBar(
            backgroundColor: AppTheme.appBarColor.withValues(alpha: 0.8),
            floating: true,
            snap: true,
            pinned: false,
            elevation: 0,
            toolbarHeight: kToolbarHeight,
            automaticallyImplyLeading: false,
            title: InkWell(
              onTap: () => _scrollToSection('home'),
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
                    _NavButton(
                      label: 'Início',
                      onTap: () => _scrollToSection('home'),
                    ),
                    _NavButton(
                      label: 'O Casal',
                      onTap: () => _scrollToSection('casal'),
                    ),
                    _NavButton(
                      label: 'Cerimônia',
                      onTap: () => _scrollToSection('cerimonia'),
                    ),
                    _NavButton(
                      label: 'Recepção',
                      onTap: () => _scrollToSection('recepcao'),
                    ),
                    _NavButton(
                      label: 'Presentes',
                      onTap: () => _scrollToSection('presentes'),
                    ),
                    _NavButton(
                      label: 'Recados',
                      onTap: () => _scrollToSection('recados'),
                    ),
                    const SizedBox(width: 16),
                  ],
          ),
          // Body content
          SliverToBoxAdapter(child: Column(children: _buildSections(isMobile))),
        ],
      ),
      endDrawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: FontAwesomeIcons.house,
                    label: 'Início',
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection('home');
                    },
                  ),
                  _DrawerItem(
                    icon: FontAwesomeIcons.userGroup,
                    label: 'O Casal',
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection('casal');
                    },
                  ),
                  _DrawerItem(
                    icon: FontAwesomeIcons.church,
                    label: 'Cerimônia',
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection('cerimonia');
                    },
                  ),
                  _DrawerItem(
                    icon: FontAwesomeIcons.champagneGlasses,
                    label: 'Recepção',
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection('recepcao');
                    },
                  ),
                  _DrawerItem(
                    icon: FontAwesomeIcons.gift,
                    label: 'Presentes',
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection('presentes');
                    },
                  ),
                  _DrawerItem(
                    icon: FontAwesomeIcons.envelopeOpenText,
                    label: 'Recados',
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection('recados');
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    final tamanhoTela = MediaQuery.of(context).size.height;
    final bool hasBackgroundImage = fundoAleatorio.isNotEmpty;
    return Container(
      height: tamanhoTela * 0.95,
      decoration: BoxDecoration(
        color: Colors.black,
        image: hasBackgroundImage
            ? DecorationImage(
                image: fundoAleatorio.startsWith('http')
                    ? CachedNetworkImageProvider(fundoAleatorio)
                    : AssetImage(fundoAleatorio) as ImageProvider,
                alignment: AlignmentGeometry.center,
                scale: 1.0,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.4),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          // Elementos decorativos
          Positioned(
            top: 50,
            left: isMobile ? 20 : 100,
            child: Icon(
              FontAwesomeIcons.heart,
              size: isMobile ? 30 : 50,
              color: AppTheme.primaryColor,
            ),
          ),
          Positioned(
            bottom: 100,
            right: isMobile ? 20 : 100,
            child: Icon(
              FontAwesomeIcons.dove,
              size: isMobile ? 25 : 40,
              color: AppTheme.primaryColor,
            ),
          ),

          // Conteúdo principal
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Estamos nos casando!',
                    style: GoogleFonts.lato(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightGray,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Davi & Deborah',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isMobile ? 48 : 72,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${appSettings.weddingDate.dataNomeMes} • ${appSettings.weddingDate.hora}',
                      style: GoogleFonts.lato(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ),
                  if (rsvpLimit == false && appSettings.rsvpEnable) ...[
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _scrollToSection('rsvp'),
                      icon: const Icon(
                        FontAwesomeIcons.envelopeOpenText,
                        size: 18,
                      ),
                      label: const Text('Confirmar Presença'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24 : 32,
                          vertical: isMobile ? 16 : 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection(bool isMobile, DateTime now) {
    if (now.isAfter(appSettings.weddingDate)) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 32 : 48),
        color: Colors.white,
        child: Column(
          children: [
            Text(
              'Chegou o grande dia! 🎉',
              style: GoogleFonts.playfairDisplay(
                fontSize: isMobile ? 32 : 42,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Cálculo preciso de meses restantes
    int months = 0;
    DateTime tempDate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );

    while (tempDate.add(Duration(days: 30)).isBefore(appSettings.weddingDate)) {
      final nextMonth = DateTime(
        tempDate.month == 12 ? tempDate.year + 1 : tempDate.year,
        tempDate.month == 12 ? 1 : tempDate.month + 1,
        tempDate.day,
        tempDate.hour,
        tempDate.minute,
        tempDate.second,
      );

      if (nextMonth.isBefore(appSettings.weddingDate) ||
          nextMonth.isAtSameMomentAs(appSettings.weddingDate)) {
        months++;
        tempDate = nextMonth;
      } else {
        break;
      }
    }

    // Calcula o restante após os meses completos
    final remainder = appSettings.weddingDate.difference(tempDate);

    final days = remainder.inDays;
    final hours = remainder.inHours % 24;
    final minutes = remainder.inMinutes % 60;
    final seconds = remainder.inSeconds % 60;

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    Widget timeBox(String label, String value) {
      return Container(
        width: isMobile ? 90 : 120,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: isMobile ? 26 : 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: isMobile ? 12 : 14,
                color: AppTheme.lightTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 32 : 48),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          if (months == 0 && days == 0)
            Text(
              'Chegou o grande dia! 🎉',
              style: GoogleFonts.playfairDisplay(
                fontSize: isMobile ? 32 : 42,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              'Contagem para o grande dia',
              style: GoogleFonts.lato(
                fontSize: isMobile ? 18 : 22,
                color: AppTheme.lightTextColor,
              ),
            ),
          const SizedBox(height: 24),
          Wrap(
            spacing: isMobile ? 12 : 20,
            runSpacing: isMobile ? 12 : 20,
            alignment: WrapAlignment.center,
            children: [
              if (months > 0) timeBox('Meses', months.toString()),
              if (days > 0) timeBox('Dias', days.toString()),
              timeBox('Horas', hours.toString()),
              timeBox('Minutos', twoDigits(minutes)),
              timeBox('Segundos', twoDigits(seconds)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersiculo(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 1200,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 48,
      ),
      child: Column(
        children: [
          const SizedBox(height: 46),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '“',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text:
                      'As muitas águas não podem apagar o amor, nem os rios podem afogá-lo',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(
                  text: '”',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Cantares 8:7',
            style: GoogleFonts.lato(fontSize: 13, color: AppTheme.textColor),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 46),
        ],
      ),
    );
  }

  Widget _buildMensagemNoivos(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 1200,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 48,
      ),
      child: Column(
        children: [
          const SectionTitle(
            title: 'Mensagem dos Noivos',
            subtitle: 'Seja bem-vindo(a)!',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: isMobile ? double.infinity : 1200,
            child: Text(
              'Se você recebeu este link, é porque é uma pessoa muito especial para nós. '
              'É com imensa alegria que desejamos compartilhar um dos momentos mais importantes de nossa história: o nosso casamento. '
              'A partir do dia 12 de julho de 2026, iniciaremos uma nova etapa, dando início à nossa família. Criamos este site com carinho para facilitar a comunicação com nossos convidados e auxiliar na organização desse dia tão especial.',
              style: GoogleFonts.lato(fontSize: 16, color: AppTheme.textColor),
              textAlign: TextAlign.justify,
            ),
          ),
          const SizedBox(height: 34),
          Text(
            'Ficamos muito felizes em ter você conosco para celebrar esse momento!',
            style: GoogleFonts.lato(fontSize: 16, color: AppTheme.textColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Davi & Deborah - 2026',
                  style: GoogleFonts.lato(
                    fontSize: isMobile ? 14 : 16,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            Text(
              'Desenvolvido por mim, Davi.',
              style: GoogleFonts.lato(
                fontSize: isMobile ? 12 : 14,
                color: AppTheme.lightTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              appSettings.versaoAtual,
              style: GoogleFonts.lato(
                fontSize: isMobile ? 12 : 14,
                color: AppTheme.lightTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.lato(
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
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AppTheme.primaryColor),
      title: Text(
        label,
        style: GoogleFonts.lato(fontSize: 16, color: AppTheme.primaryColor),
      ),
      onTap: onTap,
    );
  }
}
