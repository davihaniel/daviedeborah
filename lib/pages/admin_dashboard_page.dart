import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../models/anfitriao.dart';
import '../models/convidado.dart';
import '../models/recado.dart';
import '../stores/admin_store.dart';
import '../config/app_theme.dart';
import 'rsvp_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final AdminStore adminStore;
  final VoidCallback onLogout;

  const AdminDashboardPage({
    super.key,
    required this.adminStore,
    required this.onLogout,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<Map<String, dynamic>> _estatisticas;
  late Future<List<Anfitriao>> _anfitrioes;
  late Future<List<Convidado>> _convidados;
  late Future<List<Recado>> _recados;

  int indexedTab = 0;

  String _filtroNomeAnfitriao = '';
  String _filtroNomeConvidado = '';
  String _filtroNomeRecado = '';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    _estatisticas = _supabaseService.obterEstatisticas();
    _anfitrioes = _supabaseService.obterTodosAnfitriaos();
    _convidados = _supabaseService.obterTodosConvidados();
    _recados = _supabaseService.obterTodosRecados();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Painel Administrativo',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Olá, ${widget.adminStore.nomeUsuario}',
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowRightFromBracket),
            tooltip: 'Sair',
            onPressed: () {
              widget.adminStore.fazerLogout();
              widget.onLogout();
            },
          ),
        ],
      ),
      body: !isMobile
          ? Row(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 15),
                  width: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: NavigationDrawer(
                          selectedIndex: indexedTab,
                          onDestinationSelected: (value) {
                            setState(() {
                              indexedTab = value;
                            });
                          },
                          children: [
                            NavigationDrawerDestination(
                              icon: Icon(FontAwesomeIcons.houseUser),
                              label: Text('Anfitriões'),
                            ),
                            NavigationDrawerDestination(
                              icon: Icon(FontAwesomeIcons.userGroup),
                              label: Text('Convidados'),
                            ),
                            NavigationDrawerDestination(
                              icon: Icon(FontAwesomeIcons.envelope),
                              label: Text('Recados'),
                            ),
                          ],
                        ),
                      ),
                      // Estatisticas
                      _buildEstatisticas(isMobile),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IndexedStack(
                      index: indexedTab,
                      children: [
                        _buildListaAnfitriaos(isMobile),
                        _buildListaConvidados(isMobile),
                        _buildListaRecados(isMobile),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 32)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estatísticas
                    _buildEstatisticas(isMobile),
                    const SizedBox(height: 40),

                    // Abas
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            isScrollable: isMobile,
                            labelColor: AppTheme.primaryColor,
                            tabAlignment: TabAlignment.start,
                            unselectedLabelColor: AppTheme.lightTextColor,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(
                                text: 'Anfitriões',
                                icon: Icon(FontAwesomeIcons.houseUser),
                              ),
                              Tab(
                                text: 'Convidados',
                                icon: Icon(FontAwesomeIcons.userGroup),
                              ),
                              Tab(
                                text: 'Recados',
                                icon: Icon(FontAwesomeIcons.envelope),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: isMobile ? 500 : 700,
                            child: TabBarView(
                              children: [
                                _buildListaAnfitriaos(isMobile),
                                _buildListaConvidados(isMobile),
                                _buildListaRecados(isMobile),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEstatisticas(bool isMobile) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _estatisticas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Erro ao carregar: ${snapshot.error}'),
          );
        }

        final stats = snapshot.data ?? {};

        return !isMobile
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    _buildStatCardHorizontal(
                      'Confirmações',
                      '${stats['total_confirmados'] ?? 0}/${stats['total_anfitrioes'] ?? 0}',
                      '- ${(stats['taxa_confirmacao'] ?? 0).toStringAsFixed(2)}%',
                      FontAwesomeIcons.circleCheck,
                    ),

                    _buildStatCardHorizontal(
                      'Convidados',
                      '${stats['total_convidados'] ?? 0}',
                      '',
                      FontAwesomeIcons.users,
                    ),
                    _buildStatCardHorizontal(
                      'Crianças',
                      '${stats['total_criancas'] ?? 0}',
                      '',
                      FontAwesomeIcons.child,
                    ),
                    _buildStatCardHorizontal(
                      'Recados',
                      '${stats['total_recados'] ?? 0}',
                      '',
                      FontAwesomeIcons.comments,
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estatísticas do Casamento',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 8;
                      } else if (constraints.maxWidth > 800) {
                        crossAxisCount = 5;
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 4;
                      }

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard(
                            'Confirmações',
                            '${stats['total_confirmados'] ?? 0}/${stats['total_anfitrioes'] ?? 0}',
                            '${(stats['taxa_confirmacao'] ?? 0).toStringAsFixed(2)}%',
                            FontAwesomeIcons.circleCheck,
                          ),
                          _buildStatCard(
                            'Convidados',
                            '${stats['total_convidados'] ?? 0}',
                            '',
                            FontAwesomeIcons.users,
                          ),
                          _buildStatCard(
                            'Crianças',
                            '${stats['total_criancas'] ?? 0}',
                            '',
                            FontAwesomeIcons.child,
                          ),
                          _buildStatCard(
                            'Recados',
                            '${stats['total_recados'] ?? 0}',
                            '',
                            FontAwesomeIcons.comments,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
      },
    );
  }

  Widget _buildStatCardHorizontal(
    String titulo,
    String valor,
    String subtitulo,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 26, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(titulo), Text('$valor $subtitulo')],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String titulo,
    String valor,
    String subtitulo,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            Icon(icon, size: 26, color: AppTheme.primaryColor),
            Text(
              titulo,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: AppTheme.lightTextColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              valor,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitulo.isNotEmpty) ...[
              Text(
                subtitulo,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: AppTheme.lightTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListaAnfitriaos(bool isMobile) {
    return FutureBuilder<List<Anfitriao>>(
      future: _anfitrioes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }

        final anfitrioes = snapshot.data ?? [];
        final filtrados = anfitrioes
            .where(
              (a) => a.nome.toLowerCase().contains(
                _filtroNomeAnfitriao.toLowerCase(),
              ),
            )
            .toList();

        return Column(
          children: [
            if (isMobile) ...[
              TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar anfitrião...',
                  prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _filtroNomeAnfitriao = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(FontAwesomeIcons.plus),
                  label: const Text('Novo anfitrião + convidados'),
                  onPressed: () => _abrirDialogNovoAnfitriao(isMobile),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pesquisar anfitrião...',
                        prefixIcon: const Icon(
                          FontAwesomeIcons.magnifyingGlass,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filtroNomeAnfitriao = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(FontAwesomeIcons.plus),
                    label: const Text('Novo anfitrião + convidados'),
                    onPressed: () => _abrirDialogNovoAnfitriao(isMobile),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: filtrados.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.userSlash,
                          size: 48,
                          color: AppTheme.lightTextColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum anfitrião encontrado',
                          style: GoogleFonts.lato(
                            color: AppTheme.lightTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        final anfitriao = filtrados[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () {
                              _listaConvidadosAnfitriao(
                                context,
                                anfitriao,
                                isMobile,
                              );
                            },
                            leading: Icon(
                              FontAwesomeIcons.user,
                              color: AppTheme.primaryColor,
                            ),
                            title: Text(anfitriao.nome),
                            subtitle: Text(anfitriao.numero),
                            trailing: Wrap(
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: null,
                                  icon: Icon(
                                    anfitriao.confirmacao
                                        ? FontAwesomeIcons.check
                                        : FontAwesomeIcons.xmark,
                                    size: 20,
                                    color: anfitriao.confirmacao
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.whatsapp,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _abrirWhatsApp(anfitriao.numero);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.pen,
                                    size: 20,
                                  ),
                                  onPressed: () => _editarAnfitriao(
                                    context,
                                    anfitriao,
                                    isMobile,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListaConvidados(bool isMobile) {
    return FutureBuilder<List<Convidado>>(
      future: _convidados,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }

        final convidados = snapshot.data ?? [];
        final filtrados = convidados
            .where(
              (c) => c.nome.toLowerCase().contains(
                _filtroNomeConvidado.toLowerCase(),
              ),
            )
            .toList();

        return Column(
          children: [
            if (isMobile) ...[
              TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar convidado...',
                  prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _filtroNomeConvidado = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(FontAwesomeIcons.plus),
                  label: const Text('Adicionar convidado'),
                  onPressed: () => _abrirDialogNovoConvidado(isMobile),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pesquisar convidado...',
                        prefixIcon: const Icon(
                          FontAwesomeIcons.magnifyingGlass,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filtroNomeConvidado = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(FontAwesomeIcons.plus),
                    label: const Text('Adicionar convidado'),
                    onPressed: () => _abrirDialogNovoConvidado(isMobile),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: filtrados.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.userSlash,
                          size: 48,
                          color: AppTheme.lightTextColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum convidado encontrado',
                          style: GoogleFonts.lato(
                            color: AppTheme.lightTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        final convidado = filtrados[index];
                        return FutureBuilder<Anfitriao?>(
                          future: _supabaseService.obterAnfitriaoPorId(
                            convidado.idAnfitriao,
                          ),
                          builder: (context, snapshotAnf) {
                            final anfitriao = snapshotAnf.data;
                            return Card(
                          elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Icon(
                                  convidado.isCrianca
                                      ? FontAwesomeIcons.child
                                      : FontAwesomeIcons.user,
                                  color: AppTheme.primaryColor,
                                ),
                                title: Text(convidado.nome),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(anfitriao?.nome ?? 'Carregando...'),
                                    if (convidado.isCrianca)
                                      Text(
                                        'Criança - ${convidado.idade} anos',
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(FontAwesomeIcons.pen, size: 20,),
                                  onPressed: () => _editarConvidado(
                                    context,
                                    convidado,
                                    isMobile,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListaRecados(bool isMobile) {
    return FutureBuilder<List<Recado>>(
      future: _recados,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        final recados = snapshot.data ?? [];
        final filtrados = recados
            .where(
              (r) =>
                  r.nome.toLowerCase().contains(
                    _filtroNomeRecado.toLowerCase(),
                  ) ||
                  r.mensagem.toLowerCase().contains(
                    _filtroNomeRecado.toLowerCase(),
                  ),
            )
            .toList();

        return Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar recado...',
                prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _filtroNomeRecado = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtrados.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.commentSlash,
                          size: 48,
                          color: AppTheme.lightTextColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum recado encontrado',
                          style: GoogleFonts.lato(
                            color: AppTheme.lightTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        final recado = filtrados[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: recado.aprovado
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                recado.aprovado
                                    ? FontAwesomeIcons.circleCheck
                                    : FontAwesomeIcons.circle,
                                color: recado.aprovado
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            title: Text(
                              recado.nome,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  recado.mensagem,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(fontSize: 13),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem<String>(
                                  value: 'aprovar',
                                  enabled: !recado.aprovado,
                                  child: Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.check,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text('Aprovar'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'reprovar',
                                  enabled: recado.aprovado,
                                  child: Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.xmark,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text('Reprovar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem<String>(
                                  value: 'deletar',
                                  child: Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.trash,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text('Deletar'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'aprovar') {
                                  _aprovarRecado(context, recado);
                                } else if (value == 'reprovar') {
                                  _reprovarRecado(context, recado);
                                } else if (value == 'deletar') {
                                  _deletarRecado(context, recado);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _abrirWhatsApp(String numero) {
    final telefone = numero.replaceAll(RegExp(r'\D'), '');
    final url = 'https://wa.me/55$telefone';

    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _listaConvidadosAnfitriao(
    BuildContext context,
    Anfitriao anfitriao,
    bool isMobile,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Convidados de ${anfitriao.nome}'),
          content: FutureBuilder<List<Convidado>>(
            future: _supabaseService.obterConvidadosPorAnfitriao(anfitriao.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text('Erro ao carregar convidados: ${snapshot.error}');
              }
              final convidados = snapshot.data ?? [];
              if (convidados.isEmpty) {
                return const Text(
                  'Nenhum convidado associado a este anfitrião.',
                );
              }
              return SizedBox(
                width: isMobile ? double.infinity : 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: convidados.length,
                  itemBuilder: (context, index) {
                    final convidado = convidados[index];
                    return ListTile(
                      leading: Icon(
                        convidado.isCrianca
                            ? FontAwesomeIcons.child
                            : FontAwesomeIcons.user,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text(convidado.nome),
                      subtitle: convidado.isCrianca
                          ? Text('Criança - ${convidado.idade} anos')
                          : null,
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _editarAnfitriao(
    BuildContext context,
    Anfitriao anfitriao,
    bool isMobile,
  ) {
    final nomeCtrl = TextEditingController(text: anfitriao.nome);
    final numeroCtrl = TextEditingController(text: anfitriao.numero);
    bool confirmado = anfitriao.confirmacao;
    bool salvando = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text('Editar anfitrião'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(FontAwesomeIcons.user),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: numeroCtrl,
                    inputFormatters: [PhoneMaskFormatter()],
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      hintText: '(99) 99999-9999',
                      prefixIcon: Icon(FontAwesomeIcons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Confirmado'),
                    value: confirmado,
                    onChanged: (value) => setStateSB(() => confirmado = value),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: salvando
                    ? null
                    : () async {
                        final nome = nomeCtrl.text.trim();
                        final numero = numeroCtrl.text.trim();
                        if (nome.isEmpty || numero.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Preencha nome e telefone do anfitrião',
                              ),
                            ),
                          );
                          return;
                        }

                        final digits = numero.replaceAll(RegExp(r'\D'), '');
                        if (digits.length != 11) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor, digite um telefone válido com 11 dígitos',
                              ),
                            ),
                          );
                          return;
                        }
                        setStateSB(() => salvando = true);
                        await _supabaseService.atualizarAnfitriao(
                          id: anfitriao.id,
                          nome: nome,
                          numero: numero,
                          confirmacao: confirmado,
                        );
                        if (mounted) {
                          setState(() {
                            _carregarDados();
                          });
                          if (!context.mounted) return;
                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Anfitrião atualizado com sucesso'),
                            ),
                          );
                        }
                        setStateSB(() => salvando = false);
                      },
                child: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editarConvidado(
    BuildContext context,
    Convidado convidado,
    bool isMobile,
  ) {
    final nomeCtrl = TextEditingController(text: convidado.nome);
    final idadeCtrl = TextEditingController(
      text: convidado.idade?.toString() ?? '',
    );
    bool salvando = false;
    final anfitrioesFuture = _supabaseService.obterTodosAnfitriaos();
    String? anfitriaoSelecionado = convidado.idAnfitriao;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text('Editar convidado'),
            content: FutureBuilder<List<Anfitriao>>(
              future: anfitrioesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Erro ao carregar anfitriões: ${snapshot.error}');
                }
                final anfitrioes = snapshot.data ?? [];
                if (anfitrioes.isEmpty) {
                  return const Text('Nenhum anfitrião disponível.');
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nomeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nome do convidado',
                          prefixIcon: Icon(FontAwesomeIcons.user),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: idadeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Idade (opcional)',
                          prefixIcon: Icon(FontAwesomeIcons.cakeCandles),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: anfitriaoSelecionado,
                        items: anfitrioes
                            .map(
                              (a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.nome),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setStateSB(() => anfitriaoSelecionado = value),
                        decoration: const InputDecoration(
                          labelText: 'Anfitrião',
                          prefixIcon: Icon(FontAwesomeIcons.houseUser),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await _supabaseService.deletarConvidado(convidado.id);
                  if (mounted) {
                    setState(() {
                      _convidados = _supabaseService.obterTodosConvidados();
                      _estatisticas = _supabaseService.obterEstatisticas();
                    });
                    if (!context.mounted) return;
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Convidado deletado')),
                    );
                  }
                },
                child: const Text(
                  'Deletar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: salvando
                    ? null
                    : () async {
                        final nome = nomeCtrl.text.trim();
                        if (nome.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Digite o nome do convidado'),
                            ),
                          );
                          return;
                        }
                        if (anfitriaoSelecionado == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecione um anfitrião'),
                            ),
                          );
                          return;
                        }
                        final idade = idadeCtrl.text.trim().isEmpty
                            ? null
                            : int.tryParse(idadeCtrl.text.trim());
                        setStateSB(() => salvando = true);
                        await _supabaseService.atualizarConvidado(
                          id: convidado.id,
                          nome: nome,
                          idade: idade,
                          idAnfitriao: anfitriaoSelecionado,
                        );
                        if (mounted) {
                          setState(() {
                            _convidados = _supabaseService
                                .obterTodosConvidados();
                            _estatisticas = _supabaseService
                                .obterEstatisticas();
                          });
                          if (!context.mounted) return;
                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Convidado atualizado'),
                            ),
                          );
                        }
                        setStateSB(() => salvando = false);
                      },
                child: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _aprovarRecado(BuildContext context, Recado recado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprovar Recado?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'De: ${recado.nome}',
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(recado.mensagem, style: GoogleFonts.lato(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              await _supabaseService.atualizarRecado(
                recado.id,
                recado.copyWith(aprovado: true),
              );
              if (mounted) {
                setState(() {
                  _recados = _supabaseService.obterTodosRecados();
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recado aprovado com sucesso')),
                );
              }
            },
            child: const Text('Aprovar'),
          ),
        ],
      ),
    );
  }

  void _reprovarRecado(BuildContext context, Recado recado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reprovar Recado?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'De: ${recado.nome}',
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(recado.mensagem, style: GoogleFonts.lato(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              await _supabaseService.atualizarRecado(
                recado.id,
                recado.copyWith(aprovado: false),
              );
              if (mounted) {
                setState(() {
                  _recados = _supabaseService.obterTodosRecados();
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recado reprovado')),
                );
              }
            },
            child: const Text('Reprovar'),
          ),
        ],
      ),
    );
  }

  void _deletarRecado(BuildContext context, Recado recado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Recado?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'De: ${recado.nome}',
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(recado.mensagem, style: GoogleFonts.lato(fontSize: 14)),
            const SizedBox(height: 16),
            const Text(
              'Esta ação não pode ser desfeita.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _supabaseService.deletarRecado(recado.id);
              if (mounted) {
                setState(() {
                  _recados = _supabaseService.obterTodosRecados();
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recado deletado')),
                );
              }
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _abrirDialogNovoAnfitriao(bool isMobile) {
    final nomeCtrl = TextEditingController();
    final numeroCtrl = TextEditingController();
    final guestNameCtrls = <TextEditingController>[TextEditingController()];
    final guestAgeCtrls = <TextEditingController>[TextEditingController()];
    final guestIsChild = <bool>[false];
    bool salvando = false;

    void syncHostName(String value) {
      if (guestNameCtrls.isNotEmpty) {
        guestNameCtrls[0].text = value;
        guestNameCtrls[0].selection = TextSelection.fromPosition(
          TextPosition(offset: value.length),
        );
      }
    }

    void addGuest() {
      guestNameCtrls.add(TextEditingController());
      guestAgeCtrls.add(TextEditingController());
      guestIsChild.add(false);
    }

    void removeGuest(int index) {
      if (index == 0) return; // anfitrião não sai
      guestNameCtrls.removeAt(index);
      guestAgeCtrls.removeAt(index);
      guestIsChild.removeAt(index);
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text('Novo anfitrião + convidados'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome do anfitrião',
                      prefixIcon: Icon(FontAwesomeIcons.user),
                    ),
                    onChanged: syncHostName,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: numeroCtrl,
                    inputFormatters: [PhoneMaskFormatter()],
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      hintText: '(99) 99999-9999',
                      prefixIcon: Icon(FontAwesomeIcons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Convidados (inclui anfitrião)',
                      style: GoogleFonts.lato(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(guestNameCtrls.length, (index) {
                    final nameCtrl = guestNameCtrls[index];
                    final ageCtrl = guestAgeCtrls[index];
                    final isChild = guestIsChild[index];
                    final isHost = index == 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: nameCtrl,
                                    readOnly: isHost,
                                    decoration: InputDecoration(
                                      labelText: isHost
                                          ? 'Nome do anfitrião (fixo)'
                                          : 'Nome do convidado',
                                    ),
                                  ),
                                ),
                                if (!isHost)
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.trash, size: 20,),
                                    onPressed: () {
                                      setStateSB(() => removeGuest(index));
                                    },
                                  ),
                              ],
                            ),
                            if (!isHost) ...[
                              CheckboxListTile(
                                title: const Text('É criança (até 6 anos)', style: TextStyle(fontSize: 14)),
                                value: isChild,
                                onChanged: (v) => setStateSB(() {
                                  guestIsChild[index] = v ?? false;
                                  if (!(v ?? false)) {
                                    ageCtrl.clear();
                                  }
                                }),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (isChild)
                                TextField(
                                  controller: ageCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Idade',
                                    prefixIcon: Icon(
                                      FontAwesomeIcons.cakeCandles,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setStateSB(addGuest);
                      },
                      icon: const Icon(FontAwesomeIcons.plus),
                      label: const Text('Adicionar convidado'),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: salvando
                    ? null
                    : () async {
                        final nome = nomeCtrl.text.trim();
                        final numero = numeroCtrl.text.trim();
                        if (nome.isEmpty || numero.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Preencha nome e telefone do anfitrião',
                              ),
                            ),
                          );
                          return;
                        }
                        final digits = numero.replaceAll(RegExp(r'\D'), '');
                        if (digits.length != 11) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor, digite um telefone válido com 11 dígitos',
                              ),
                            ),
                          );
                          return;
                        }

                        final convidados = <Map<String, dynamic>>[];
                        for (var i = 0; i < guestNameCtrls.length; i++) {
                          final nomeConvidado = guestNameCtrls[i].text.trim();
                          if (nomeConvidado.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Preencha o nome do convidado ${i + 1}',
                                ),
                              ),
                            );
                            return;
                          }
                          final idadeTexto = guestAgeCtrls[i].text.trim();
                          final idade = idadeTexto.isEmpty
                              ? null
                              : int.tryParse(idadeTexto);
                          convidados.add({
                            'nome': nomeConvidado,
                            'idade': idade,
                          });
                        }

                        setStateSB(() => salvando = true);
                        await _supabaseService.criarAnfitriaComConvidados(
                          nome: nome,
                          numero: numero,
                          convidados: convidados,
                          confirmacao: true,
                        );
                        if (mounted) {
                          setState(() {
                            _carregarDados();
                          });
                          if (!context.mounted) return;
                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Anfitrião e convidados adicionados',
                              ),
                            ),
                          );
                        }
                        setStateSB(() => salvando = false);
                      },
                child: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _abrirDialogNovoConvidado(bool isMobile) {
    final nomeCtrl = TextEditingController();
    final idadeCtrl = TextEditingController();
    String? anfitriaoSelecionado;
    bool salvando = false;
    final anfitrioesFuture = _supabaseService.obterTodosAnfitriaos();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text('Adicionar convidado'),
            content: FutureBuilder<List<Anfitriao>>(
              future: anfitrioesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Erro ao carregar anfitriões: ${snapshot.error}');
                }
                final anfitrioes = snapshot.data ?? [];
                if (anfitrioes.isEmpty) {
                  return const Text(
                    'Nenhum anfitrião cadastrado. Crie um anfitrião primeiro.',
                  );
                }

                anfitriaoSelecionado ??= anfitrioes.first.id;

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nomeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nome do convidado',
                          prefixIcon: Icon(FontAwesomeIcons.user),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: idadeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Idade (opcional)',
                          prefixIcon: Icon(FontAwesomeIcons.cakeCandles),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: anfitriaoSelecionado,
                        items: anfitrioes
                            .map(
                              (a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.nome),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setStateSB(() => anfitriaoSelecionado = value),
                        decoration: const InputDecoration(
                          labelText: 'Anfitrião',
                          prefixIcon: Icon(FontAwesomeIcons.houseUser),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: salvando
                    ? null
                    : () async {
                        final nome = nomeCtrl.text.trim();
                        if (nome.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Digite o nome do convidado'),
                            ),
                          );
                          return;
                        }
                        if (anfitriaoSelecionado == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecione um anfitrião'),
                            ),
                          );
                          return;
                        }
                        final idade = idadeCtrl.text.trim().isEmpty
                            ? null
                            : int.tryParse(idadeCtrl.text.trim());
                        setStateSB(() => salvando = true);
                        await _supabaseService.criarConvidado(
                          nome: nome,
                          idAnfitriao: anfitriaoSelecionado!,
                          idade: idade,
                        );
                        if (mounted) {
                          setState(() {
                            _convidados = _supabaseService
                                .obterTodosConvidados();
                            _estatisticas = _supabaseService
                                .obterEstatisticas();
                          });
                          if (!context.mounted) return;
                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Convidado adicionado'),
                            ),
                          );
                        }
                        setStateSB(() => salvando = false);
                      },
                child: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
