import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/supabase_service.dart';
import '../models/anfitriao.dart';
import '../models/convidado.dart';
import '../models/recado.dart';
import '../stores/admin_store.dart';
import '../config/app_theme.dart';

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
                      '${(stats['taxa_confirmacao'] ?? 0).toStringAsFixed(1)}%',
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
                      '${(stats['taxa_criancas'] ?? 0).toStringAsFixed(1)}%',
                      FontAwesomeIcons.child,
                    ),
                    _buildStatCardHorizontal(
                      'Recados',
                      '${stats['recados_aprovados'] ?? 0}',
                      'aprovados',
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
                            '${(stats['taxa_confirmacao'] ?? 0).toStringAsFixed(1)}%',
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
                            '${(stats['taxa_criancas'] ?? 0).toStringAsFixed(1)}%',
                            FontAwesomeIcons.child,
                          ),
                          _buildStatCard(
                            'Recados',
                            '${stats['recados_aprovados'] ?? 0}',
                            'aprovados',
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
          children: [Text(titulo), Text('$valor - $subtitulo')],
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
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              FontAwesomeIcons.user,
                              color: AppTheme.primaryColor,
                            ),
                            title: Text(anfitriao.nome),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(anfitriao.numero),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(
                                    anfitriao.confirmacao
                                        ? 'Estarei lá'
                                        : 'Não poderei ir',
                                        style: GoogleFonts.lato(
                                          color: anfitriao.confirmacao
                                              ? Colors.green.shade800
                                              : Colors.red.shade800,
                                        ),
                                  ),
                                  backgroundColor: anfitriao.confirmacao
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(FontAwesomeIcons.pen),
                              onPressed: () => _editarAnfitriao(
                                context,
                                anfitriao,
                                isMobile,
                              ),
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
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Icon(
                                  convidado.isCrianca
                                      ? FontAwesomeIcons.child
                                      : FontAwesomeIcons.person,
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
                                  icon: const Icon(FontAwesomeIcons.pen),
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

  void _editarAnfitriao(
    BuildContext context,
    Anfitriao anfitriao,
    bool isMobile,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${anfitriao.nome}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Confirmado'),
              value: anfitriao.confirmacao,
              onChanged: (value) async {
                await _supabaseService.atualizarConfirmacaoAnfitriao(
                  anfitriao.id,
                  value ?? false,
                );
                if (mounted) {
                  setState(() {
                    _anfitrioes = _supabaseService.obterTodosAnfitriaos();
                  });
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Atualizado com sucesso')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _editarConvidado(
    BuildContext context,
    Convidado convidado,
    bool isMobile,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${convidado.nome}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: ${convidado.id}'),
            if (convidado.isCrianca) ...[
              const SizedBox(height: 16),
              Text('Idade: ${convidado.idade} anos'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _supabaseService.deletarConvidado(convidado.id);
              if (mounted) {
                setState(() {
                  _convidados = _supabaseService.obterTodosConvidados();
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Convidado deletado')),
                );
              }
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
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
}
