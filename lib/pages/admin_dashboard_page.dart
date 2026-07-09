import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import '../services/pdf_service.dart';
import '../models/anfitriao.dart';
import '../models/convidado.dart';
import '../models/recado.dart';
import '../stores/admin_store.dart';
import '../config/app_theme.dart';
import '../utils/extensions.dart';
import 'rsvp_page.dart';

enum _ConvidadoOrdenacaoCampo { nome, dataCriacao }

enum _AnfitriaoOrdenacaoCampo { nome, dataCriacao }

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
  String _filtroAnfitriaoId = '';
  _ConvidadoOrdenacaoCampo _ordenacaoConvidados =
      _ConvidadoOrdenacaoCampo.dataCriacao;
  bool _ordemConvidadosCrescente = false;
  _AnfitriaoOrdenacaoCampo _ordenacaoAnfitrioes =
      _AnfitriaoOrdenacaoCampo.dataCriacao;
  bool _ordemAnfitrioesCrescente = false;

  bool _exportandoPdf = false;
  bool _agruparPorAnfitriaoPdf = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    _estatisticas = _supabaseService.obterEstatisticas();
    _anfitrioes = _supabaseService.obterTodosAnfitriaos();
    _convidados = _supabaseService.obterTodosConvidadosComAnfitriao();
    _recados = _supabaseService.obterTodosRecados();
  }

  List<Convidado> _aplicarFiltrosConvidados(List<Convidado> convidados) {
    final termoBusca = _filtroNomeConvidado.trim().toLowerCase();

    final filtrados = convidados.where((convidado) {
      final correspondeNome =
          termoBusca.isEmpty ||
          convidado.nome.toLowerCase().contains(termoBusca);
      final correspondeAnfitriao =
          _filtroAnfitriaoId.isEmpty ||
          convidado.idAnfitriao == _filtroAnfitriaoId;

      return correspondeNome && correspondeAnfitriao;
    }).toList();

    filtrados.sort((anterior, atual) {
      int resultado;

      switch (_ordenacaoConvidados) {
        case _ConvidadoOrdenacaoCampo.nome:
          resultado = anterior.nome.normalizeForSort.compareTo(
            atual.nome.normalizeForSort,
          );
          if (resultado == 0) {
            resultado = anterior.datCriacao.compareTo(atual.datCriacao);
          }
        case _ConvidadoOrdenacaoCampo.dataCriacao:
          resultado = anterior.datCriacao.compareTo(atual.datCriacao);
          if (resultado == 0) {
            resultado = anterior.nome.normalizeForSort.compareTo(
              atual.nome.normalizeForSort,
            );
          }
      }

      return _ordemConvidadosCrescente ? resultado : -resultado;
    });

    return filtrados;
  }

  List<DropdownMenuItem<String>> _buildAnfitriaoOptions(
    List<Convidado> convidados,
  ) {
    final anfitrioes = <String, String>{};

    for (final convidado in convidados) {
      if (convidado.idAnfitriao.isEmpty) {
        continue;
      }

      anfitrioes[convidado.idAnfitriao] =
          convidado.nomeAnfitriao?.trim().isNotEmpty == true
          ? convidado.nomeAnfitriao!.trim()
          : 'Sem anfitrião';
    }

    final items = anfitrioes.entries.toList()
      ..sort(
        (anterior, atual) => anterior.value.normalizeForSort.compareTo(
          atual.value.normalizeForSort,
        ),
      );

    return [
      const DropdownMenuItem<String>(
        value: '',
        child: Text('Todos os anfitriões'),
      ),
      ...items.map(
        (item) =>
            DropdownMenuItem<String>(value: item.key, child: Text(item.value)),
      ),
    ];
  }

  Widget _buildControlesConvidados(bool isMobile, List<Convidado> convidados) {
    final anfitriaoItems = _buildAnfitriaoOptions(convidados);

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
          DropdownButtonFormField<String>(
            initialValue: _filtroAnfitriaoId,
            decoration: InputDecoration(
              labelText: 'Anfitrião',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: anfitriaoItems,
            onChanged: (value) {
              setState(() {
                _filtroAnfitriaoId = value ?? '';
              });
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Nome'),
                selected: _ordenacaoConvidados == _ConvidadoOrdenacaoCampo.nome,
                onSelected: (_) {
                  setState(() {
                    _ordenacaoConvidados = _ConvidadoOrdenacaoCampo.nome;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Data de criação'),
                selected:
                    _ordenacaoConvidados ==
                    _ConvidadoOrdenacaoCampo.dataCriacao,
                onSelected: (_) {
                  setState(() {
                    _ordenacaoConvidados = _ConvidadoOrdenacaoCampo.dataCriacao;
                  });
                },
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _ordemConvidadosCrescente = !_ordemConvidadosCrescente;
                  });
                },
                icon: Icon(
                  _ordemConvidadosCrescente
                      ? FontAwesomeIcons.arrowUpAZ
                      : FontAwesomeIcons.arrowDownZA,
                  size: 14,
                ),
                label: Text(
                  _ordemConvidadosCrescente ? 'Crescente' : 'Decrescente',
                ),
              ),
            ],
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
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: _exportandoPdf
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(FontAwesomeIcons.filePdf, size: 14),
              label: Text(_exportandoPdf ? 'Gerando...' : 'Exportar PDF'),
              onPressed: _exportandoPdf
                  ? null
                  : () => _exportarPdf(context, convidados),
            ),
          ),
        ] else ...[
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
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
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _filtroAnfitriaoId,
                      decoration: InputDecoration(
                        labelText: 'Anfitrião',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: anfitriaoItems,
                      onChanged: (value) {
                        setState(() {
                          _filtroAnfitriaoId = value ?? '';
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
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: _exportandoPdf
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(FontAwesomeIcons.filePdf, size: 14),
                    label: Text(_exportandoPdf ? 'Gerando...' : 'Exportar PDF'),
                    onPressed: _exportandoPdf
                        ? null
                        : () => _exportarPdf(context, convidados),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Nome'),
                      selected:
                          _ordenacaoConvidados == _ConvidadoOrdenacaoCampo.nome,
                      onSelected: (_) {
                        setState(() {
                          _ordenacaoConvidados = _ConvidadoOrdenacaoCampo.nome;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Data de criação'),
                      selected:
                          _ordenacaoConvidados ==
                          _ConvidadoOrdenacaoCampo.dataCriacao,
                      onSelected: (_) {
                        setState(() {
                          _ordenacaoConvidados =
                              _ConvidadoOrdenacaoCampo.dataCriacao;
                        });
                      },
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _ordemConvidadosCrescente =
                              !_ordemConvidadosCrescente;
                        });
                      },
                      icon: Icon(
                        _ordemConvidadosCrescente
                            ? FontAwesomeIcons.arrowUpAZ
                            : FontAwesomeIcons.arrowDownZA,
                        size: 14,
                      ),
                      label: Text(
                        _ordemConvidadosCrescente ? 'Crescente' : 'Decrescente',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<Anfitriao> _aplicarFiltrosAnfitrioes(List<Anfitriao> anfitrioes) {
    final termoBusca = _filtroNomeAnfitriao.trim().toLowerCase();

    final filtrados = anfitrioes.where((anfitriao) {
      return termoBusca.isEmpty ||
          anfitriao.nome.toLowerCase().contains(termoBusca);
    }).toList();

    filtrados.sort((anterior, atual) {
      int resultado;

      switch (_ordenacaoAnfitrioes) {
        case _AnfitriaoOrdenacaoCampo.nome:
          resultado = anterior.nome.normalizeForSort.compareTo(
            atual.nome.normalizeForSort,
          );
          if (resultado == 0) {
            resultado = anterior.datCriacao.compareTo(atual.datCriacao);
          }
        case _AnfitriaoOrdenacaoCampo.dataCriacao:
          resultado = anterior.datCriacao.compareTo(atual.datCriacao);
          if (resultado == 0) {
            resultado = anterior.nome.normalizeForSort.compareTo(
              atual.nome.normalizeForSort,
            );
          }
      }

      return _ordemAnfitrioesCrescente ? resultado : -resultado;
    });

    return filtrados;
  }

  Widget _buildControlesAnfitrioes(bool isMobile) {
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Nome'),
                selected: _ordenacaoAnfitrioes == _AnfitriaoOrdenacaoCampo.nome,
                onSelected: (_) {
                  setState(() {
                    _ordenacaoAnfitrioes = _AnfitriaoOrdenacaoCampo.nome;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Data de criação'),
                selected:
                    _ordenacaoAnfitrioes ==
                    _AnfitriaoOrdenacaoCampo.dataCriacao,
                onSelected: (_) {
                  setState(() {
                    _ordenacaoAnfitrioes = _AnfitriaoOrdenacaoCampo.dataCriacao;
                  });
                },
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _ordemAnfitrioesCrescente = !_ordemAnfitrioesCrescente;
                  });
                },
                icon: Icon(
                  _ordemAnfitrioesCrescente
                      ? FontAwesomeIcons.arrowUpAZ
                      : FontAwesomeIcons.arrowDownZA,
                  size: 14,
                ),
                label: Text(
                  _ordemAnfitrioesCrescente ? 'Crescente' : 'Decrescente',
                ),
              ),
            ],
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
          Column(
            children: [
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Nome'),
                      selected:
                          _ordenacaoAnfitrioes == _AnfitriaoOrdenacaoCampo.nome,
                      onSelected: (_) {
                        setState(() {
                          _ordenacaoAnfitrioes = _AnfitriaoOrdenacaoCampo.nome;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Data de criação'),
                      selected:
                          _ordenacaoAnfitrioes ==
                          _AnfitriaoOrdenacaoCampo.dataCriacao,
                      onSelected: (_) {
                        setState(() {
                          _ordenacaoAnfitrioes =
                              _AnfitriaoOrdenacaoCampo.dataCriacao;
                        });
                      },
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _ordemAnfitrioesCrescente =
                              !_ordemAnfitrioesCrescente;
                        });
                      },
                      icon: Icon(
                        _ordemAnfitrioesCrescente
                            ? FontAwesomeIcons.arrowUpAZ
                            : FontAwesomeIcons.arrowDownZA,
                        size: 14,
                      ),
                      label: Text(
                        _ordemAnfitrioesCrescente ? 'Crescente' : 'Decrescente',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
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
          if (!isMobile) _buildAppBarInfo(),
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
            tooltip: 'Atualizar dados',
            onPressed: () {
              setState(() {
                _carregarDados();
              });
            },
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
                  margin: const EdgeInsets.only(top: 15),
                  width: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // Header do menu
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                24,
                                20,
                                20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryColor,
                                          AppTheme.accentColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      FontAwesomeIcons.heart,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Davi & Deborah',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Painel de gerenciamento',
                                    style: GoogleFonts.lato(
                                      fontSize: 12,
                                      color: AppTheme.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            // Itens do menu
                            ..._buildMenuItems(),
                          ],
                        ),
                      ),
                      _buildSidebarStats(),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildEstatisticas(isMobile),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    _buildEstatisticas(isMobile),
                    const SizedBox(height: 24),
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

  List<Widget> _buildMenuItems() {
    final items = [
      _MenuItemData('Anfitriões', FontAwesomeIcons.houseUser, 0),
      _MenuItemData('Convidados', FontAwesomeIcons.userGroup, 1),
      _MenuItemData('Recados', FontAwesomeIcons.envelope, 2),
    ];

    return items.map((item) {
      final isSelected = indexedTab == item.index;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => indexedTab = item.index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 18,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.lightTextColor,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    item.label,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textColor,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAppBarInfo() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _estatisticas,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final dias = stats?['dias_para_casamento'] ?? '...';
        final rsvpAberto = stats?['rsvp_aberto'] ?? true;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.calendar,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$dias dias',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: rsvpAberto
                    ? Colors.green.shade400.withValues(alpha: 0.9)
                    : Colors.red.shade400.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                rsvpAberto ? 'RSVP Aberto' : 'RSVP Encerrado',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Olá, ${widget.adminStore.nomeUsuario}',
              style: GoogleFonts.lato(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  Widget _buildSidebarStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _estatisticas,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final stats = snapshot.data!;
        final dias = stats['dias_para_casamento'] ?? 0;
        final rsvpAberto = stats['rsvp_aberto'] ?? true;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$dias',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'dias para o casamento',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: rsvpAberto
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        rsvpAberto ? 'RSVP Aberto' : 'RSVP Encerrado',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEstatisticas(bool isMobile) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _estatisticas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Erro ao carregar: ${snapshot.error}'),
          );
        }

        final stats = snapshot.data ?? {};
        final totalAnfitrioes = stats['total_anfitrioes'] ?? 0;
        final totalConfirmados = stats['total_confirmados'] ?? 0;
        final taxaConfirmacao = (stats['taxa_confirmacao'] ?? 0.0) as double;
        final totalConvidados = stats['total_convidados'] ?? 0;
        final totalAdultos = stats['total_adultos'] ?? 0;
        final totalCriancas = stats['total_criancas'] ?? 0;
        final totalRecados = stats['total_recados'] ?? 0;
        final totalPendentes = stats['total_recados_pendentes'] ?? 0;
        final diasCasamento = stats['dias_para_casamento'] ?? 0;
        final rsvpAberto = stats['rsvp_aberto'] ?? true;

        final cards = [
          _StatData(
            'Confirmações',
            '$totalConfirmados/$totalAnfitrioes',
            '${taxaConfirmacao.toStringAsFixed(1)}%',
            FontAwesomeIcons.circleCheck,
            Colors.green,
            progress: totalAnfitrioes > 0
                ? totalConfirmados / totalAnfitrioes
                : 0.0,
          ),
          _StatData(
            'Convidados',
            '$totalConvidados',
            'total geral',
            FontAwesomeIcons.users,
            AppTheme.primaryColor,
          ),
          _StatData(
            'Adultos',
            '$totalAdultos/150',
            'pessoas',
            FontAwesomeIcons.userTie,
            AppTheme.accentColor,
          ),
          _StatData(
            'Crianças',
            '$totalCriancas',
            'até 6 anos',
            FontAwesomeIcons.child,
            Colors.orange,
          ),
          _StatData(
            'Recados',
            '$totalRecados',
            'aprovados',
            FontAwesomeIcons.comments,
            Colors.blue,
          ),
          _StatData(
            'Pendentes',
            '$totalPendentes',
            'aguardando',
            FontAwesomeIcons.clockRotateLeft,
            Colors.amber.shade700,
          ),
        ];

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contagem regressiva mobile
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$diasCasamento dias',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'para o casamento',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: rsvpAberto
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        rsvpAberto ? 'RSVP Aberto' : 'RSVP Encerrado',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Cards móveis em scroll horizontal
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 140,
                    child: _buildModernStatCard(cards[index]),
                  ),
                ),
              ),
            ],
          );
        }

        // Desktop: cards em row no topo da área de conteúdo
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: cards
                .map(
                  (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildModernStatCard(c),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildModernStatCard(_StatData data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, size: 16, color: data.color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.titulo,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppTheme.lightTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data.valor,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
              ),
            ),
            if (data.progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: data.progress!,
                  backgroundColor: Colors.grey.shade200,
                  color: data.color,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (data.subtitulo.isNotEmpty)
              Text(
                data.subtitulo,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: AppTheme.lightTextColor,
                ),
              ),
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
        final filtrados = _aplicarFiltrosAnfitrioes(anfitrioes);

        return Column(
          children: [
            _buildControlesAnfitrioes(isMobile),
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
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            onTap: () {
                              _listaConvidadosAnfitriao(
                                context,
                                anfitriao,
                                isMobile,
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withValues(
                                alpha: 0.15,
                              ),
                              child: Icon(
                                FontAwesomeIcons.user,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              anfitriao.nome,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(anfitriao.numero),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: anfitriao.confirmacao
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        anfitriao.confirmacao
                                            ? 'Confirmado'
                                            : 'Não confirmado',
                                        style: GoogleFonts.lato(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: anfitriao.confirmacao
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      FontAwesomeIcons.clock,
                                      size: 10,
                                      color: AppTheme.lightTextColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      anfitriao.datCriacao.dataHoraAbrev,
                                      style: GoogleFonts.lato(
                                        fontSize: 10,
                                        color: AppTheme.lightTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Wrap(
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              children: [
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
                                    size: 18,
                                  ),
                                  onPressed: () => _editarAnfitriao(
                                    context,
                                    anfitriao,
                                    isMobile,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.trash,
                                    size: 18,
                                    color: Colors.red.shade400,
                                  ),
                                  tooltip: 'Excluir anfitrião',
                                  onPressed: () =>
                                      _deletarAnfitriao(context, anfitriao),
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
        final filtrados = _aplicarFiltrosConvidados(convidados);

        return Column(
          children: [
            _buildControlesConvidados(isMobile, convidados),
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
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: convidado.isCrianca
                                  ? Colors.orange.withValues(alpha: 0.15)
                                  : AppTheme.primaryColor.withValues(
                                      alpha: 0.15,
                                    ),
                              child: Icon(
                                convidado.isCrianca
                                    ? FontAwesomeIcons.child
                                    : FontAwesomeIcons.user,
                                color: convidado.isCrianca
                                    ? Colors.orange
                                    : AppTheme.primaryColor,
                                size: 18,
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    convidado.nome,
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (convidado.isCrianca) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${convidado.idade} anos',
                                      style: GoogleFonts.lato(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                                if (convidado.convidadoHonra) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.workspace_premium,
                                          size: 12,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Honra',
                                          style: GoogleFonts.lato(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.houseUser,
                                      size: 10,
                                      color: AppTheme.lightTextColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      convidado.nomeAnfitriao ??
                                          'Sem anfitrião',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: AppTheme.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.clock,
                                      size: 10,
                                      color: AppTheme.lightTextColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      convidado.datCriacao.dataHoraAbrev,
                                      style: GoogleFonts.lato(
                                        fontSize: 10,
                                        color: AppTheme.lightTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(FontAwesomeIcons.pen, size: 18),
                              onPressed: () => _editarConvidado(
                                context,
                                convidado,
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
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: recado.aprovado
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                recado.aprovado
                                    ? FontAwesomeIcons.circleCheck
                                    : FontAwesomeIcons.clock,
                                color: recado.aprovado
                                    ? Colors.green
                                    : Colors.orange,
                                size: 20,
                              ),
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    recado.nome,
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: recado.aprovado
                                        ? Colors.green.shade50
                                        : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    recado.aprovado ? 'Aprovado' : 'Pendente',
                                    style: GoogleFonts.lato(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: recado.aprovado
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
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
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.clock,
                                      size: 10,
                                      color: AppTheme.lightTextColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      recado.datCriacao.dataHoraAbrev,
                                      style: GoogleFonts.lato(
                                        fontSize: 10,
                                        color: AppTheme.lightTextColor,
                                      ),
                                    ),
                                  ],
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

  Future<void> _exportarPdf(
    BuildContext context,
    List<Convidado> convidadosDaTela,
  ) async {
    // Diálogo de opções antes de gerar
    bool? confirmar;
    bool agrupar = _agruparPorAnfitriaoPdf;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setStateSB) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FontAwesomeIcons.filePdf,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Exportar PDF',
                style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A lista será gerada com a mesma ordenação exibida na tela, '
                'contendo apenas convidados de anfitriões confirmados.',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppTheme.lightTextColor,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: agrupar,
                onChanged: (v) => setStateSB(() => agrupar = v),
                title: Text(
                  'Agrupar por anfitrião',
                  style: GoogleFonts.lato(fontSize: 14),
                ),
                subtitle: Text(
                  'Organiza a lista em seções por anfitrião',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppTheme.lightTextColor,
                  ),
                ),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                confirmar = false;
                Navigator.pop(dialogCtx);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(FontAwesomeIcons.filePdf, size: 14),
              label: const Text('Gerar PDF'),
              onPressed: () {
                confirmar = true;
                setState(() => _agruparPorAnfitriaoPdf = agrupar);
                Navigator.pop(dialogCtx);
              },
            ),
          ],
        ),
      ),
    );

    if (confirmar != true) return;

    setState(() => _exportandoPdf = true);

    try {
      // Busca apenas confirmados e aplica a ordenação da tela
      final confirmados = await _supabaseService.obterConvidadosConfirmados();
      final ordenados = _aplicarFiltrosConvidados(confirmados);
      final stats = await _estatisticas;

      final bytes = await PdfService.gerarListaConvidados(
        ordenados,
        stats,
        agruparPorAnfitriao: _agruparPorAnfitriaoPdf,
      );

      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: 'convidados_davi_deborah.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exportandoPdf = false);
    }
  }

  void _deletarAnfitriao(BuildContext context, Anfitriao anfitriao) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                FontAwesomeIcons.triangleExclamation,
                color: Colors.red.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Excluir Anfitrião'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: AppTheme.textColor,
                ),
                children: [
                  const TextSpan(text: 'Deseja realmente excluir '),
                  TextSpan(
                    text: anfitriao.nome,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.circleInfo,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Todos os convidados vinculados a este anfitrião também serão removidos.',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _supabaseService.deletarAnfitriao(anfitriao.id);
              if (mounted) {
                setState(() {
                  _carregarDados();
                });
                if (!context.mounted) return;
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anfitrião excluído com sucesso'),
                  ),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
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
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 480,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              FontAwesomeIcons.userPen,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Editar Anfitrião',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Criado em ${anfitriao.datCriacao.dataNomeMesAbrev}',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: AppTheme.lightTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            icon: const Icon(Icons.close, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Dados pessoais
                      Text(
                        'Dados pessoais',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nomeCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: const Icon(
                            FontAwesomeIcons.user,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: numeroCtrl,
                        inputFormatters: [PhoneMaskFormatter()],
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          hintText: '(99) 99999-9999',
                          prefixIcon: const Icon(
                            FontAwesomeIcons.phone,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Status
                      Text(
                        'Status',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: confirmado
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: confirmado
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            confirmado
                                ? 'Presença confirmada'
                                : 'Presença não confirmada',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w600,
                              color: confirmado
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          subtitle: Text(
                            confirmado
                                ? 'O anfitrião confirmou presença no casamento'
                                : 'Aguardando confirmação',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                          value: confirmado,
                          activeColor: Colors.green,
                          onChanged: (value) =>
                              setStateSB(() => confirmado = value),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Ações
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                _deletarAnfitriao(context, anfitriao),
                            icon: Icon(
                              FontAwesomeIcons.trash,
                              size: 14,
                              color: Colors.red.shade400,
                            ),
                            label: Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red.shade400),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: salvando
                                ? null
                                : () async {
                                    final nome = nomeCtrl.text.trim();
                                    final numero = numeroCtrl.text.trim();
                                    if (nome.isEmpty || numero.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Preencha nome e telefone do anfitrião',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final digits = numero.replaceAll(
                                      RegExp(r'\D'),
                                      '',
                                    );
                                    if (digits.length != 11) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Anfitrião atualizado com sucesso',
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Salvar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    bool convidadoDeHonra = convidado.convidadoHonra;

    bool salvando = false;
    final anfitrioesFuture = _supabaseService.obterTodosAnfitriaos();
    String? anfitriaoSelecionado = convidado.idAnfitriao;

    InputDecoration styledInput(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 480,
              ),
              child: FutureBuilder<List<Anfitriao>>(
                future: anfitrioesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Erro ao carregar anfitriões: ${snapshot.error}',
                      ),
                    );
                  }
                  final anfitrioes = snapshot.data ?? [];

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: convidado.isCrianca
                                      ? Colors.orange.withValues(alpha: 0.12)
                                      : AppTheme.primaryColor.withValues(
                                          alpha: 0.12,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  convidado.isCrianca
                                      ? FontAwesomeIcons.child
                                      : FontAwesomeIcons.userPen,
                                  color: convidado.isCrianca
                                      ? Colors.orange
                                      : AppTheme.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Editar Convidado',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Criado em ${convidado.datCriacao.dataNomeMesAbrev}',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: AppTheme.lightTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                icon: const Icon(Icons.close, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Dados
                          Text(
                            'Informações',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: nomeCtrl,
                            decoration: styledInput(
                              'Nome do convidado',
                              FontAwesomeIcons.user,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: idadeCtrl,
                            decoration: styledInput(
                              'Idade (opcional)',
                              FontAwesomeIcons.cakeCandles,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          if (anfitrioes.isNotEmpty)
                            DropdownButtonFormField<String>(
                              value: anfitriaoSelecionado,
                              items: anfitrioes
                                  .map(
                                    (a) => DropdownMenuItem(
                                      value: a.id,
                                      child: Text(a.nome),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setStateSB(
                                () => anfitriaoSelecionado = value,
                              ),
                              decoration: styledInput(
                                'Anfitrião',
                                FontAwesomeIcons.houseUser,
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.circleInfo,
                                    size: 16,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text('Nenhum anfitrião disponível.'),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Status
                          Container(
                            decoration: BoxDecoration(
                              color: convidadoDeHonra
                                  ? Colors.orange.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: convidadoDeHonra
                                    ? Colors.orange.shade200
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: SwitchListTile(
                              title: Text(
                                convidadoDeHonra
                                    ? 'Convidado de Honra'
                                    : 'Convidado Regular',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w600,
                                  color: convidadoDeHonra
                                      ? Colors.orange.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                              subtitle: Text(
                                convidadoDeHonra
                                    ? 'Este convidado é um convidado de honra e terá destaque no evento'
                                    : 'Este convidado é um convidado regular',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: AppTheme.lightTextColor,
                                ),
                              ),
                              value: convidadoDeHonra,
                              activeColor: Colors.orange,
                              onChanged: (value) =>
                                  setStateSB(() => convidadoDeHonra = value),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          // Ações
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  await _supabaseService.deletarConvidado(
                                    convidado.id,
                                  );
                                  if (mounted) {
                                    setState(() {
                                      _convidados = _supabaseService
                                          .obterTodosConvidadosComAnfitriao();
                                      _estatisticas = _supabaseService
                                          .obterEstatisticas();
                                    });
                                    if (!context.mounted) return;
                                    Navigator.pop(dialogCtx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Convidado deletado'),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  FontAwesomeIcons.trash,
                                  size: 14,
                                  color: Colors.red.shade400,
                                ),
                                label: Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.red.shade400),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text('Cancelar'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: salvando
                                    ? null
                                    : () async {
                                        final nome = nomeCtrl.text.trim();
                                        if (nome.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Digite o nome do convidado',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        if (anfitriaoSelecionado == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Selecione um anfitrião',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        final idade =
                                            idadeCtrl.text.trim().isEmpty
                                            ? null
                                            : int.tryParse(
                                                idadeCtrl.text.trim(),
                                              );
                                        setStateSB(() => salvando = true);
                                        await _supabaseService
                                            .atualizarConvidado(
                                              id: convidado.id,
                                              nome: nome,
                                              idade: idade,
                                              idAnfitriao: anfitriaoSelecionado,
                                              convidadoHonra:
                                                  convidadoDeHonra,
                                            );
                                        if (mounted) {
                                          setState(() {
                                            _convidados = _supabaseService
                                                .obterTodosConvidadosComAnfitriao();
                                            _estatisticas = _supabaseService
                                                .obterEstatisticas();
                                          });
                                          if (!context.mounted) return;
                                          Navigator.pop(dialogCtx);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Convidado atualizado',
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
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Salvar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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
      if (index == 0) return;
      guestNameCtrls.removeAt(index);
      guestAgeCtrls.removeAt(index);
      guestIsChild.removeAt(index);
    }

    InputDecoration _styledInput(String label, IconData icon, {String? hint}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 520,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.accentColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.userPlus,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Novo Anfitrião',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Adicione o anfitrião e seus convidados',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: AppTheme.lightTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            icon: const Icon(Icons.close, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Dados do anfitrião
                      Text(
                        'Dados do anfitrião',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nomeCtrl,
                        decoration: _styledInput(
                          'Nome do anfitrião',
                          FontAwesomeIcons.user,
                        ),
                        onChanged: syncHostName,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: numeroCtrl,
                        inputFormatters: [PhoneMaskFormatter()],
                        keyboardType: TextInputType.phone,
                        decoration: _styledInput(
                          'Telefone',
                          FontAwesomeIcons.phone,
                          hint: '(99) 99999-9999',
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Lista de convidados
                      Row(
                        children: [
                          Text(
                            'Convidados',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${guestNameCtrls.length}',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => setStateSB(addGuest),
                            icon: const Icon(FontAwesomeIcons.plus, size: 14),
                            label: const Text('Adicionar'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(guestNameCtrls.length, (index) {
                        final nameCtrl = guestNameCtrls[index];
                        final ageCtrl = guestAgeCtrls[index];
                        final isChild = guestIsChild[index];
                        final isHost = index == 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isHost
                                  ? AppTheme.primaryColor.withValues(
                                      alpha: 0.04,
                                    )
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isHost
                                    ? AppTheme.primaryColor.withValues(
                                        alpha: 0.2,
                                      )
                                    : Colors.grey.shade200,
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isHost
                                            ? AppTheme.primaryColor.withValues(
                                                alpha: 0.15,
                                              )
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isHost
                                                ? AppTheme.primaryColor
                                                : AppTheme.lightTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (isHost)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Anfitrião',
                                          style: GoogleFonts.lato(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    if (!isHost)
                                      IconButton(
                                        icon: Icon(
                                          FontAwesomeIcons.xmark,
                                          size: 16,
                                          color: Colors.red.shade400,
                                        ),
                                        onPressed: () => setStateSB(
                                          () => removeGuest(index),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: nameCtrl,
                                  readOnly: isHost,
                                  decoration: _styledInput(
                                    isHost
                                        ? 'Nome do anfitrião (automático)'
                                        : 'Nome do convidado',
                                    FontAwesomeIcons.user,
                                  ),
                                ),
                                if (!isHost) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: isChild,
                                        onChanged: (v) => setStateSB(() {
                                          guestIsChild[index] = v ?? false;
                                          if (!(v ?? false)) ageCtrl.clear();
                                        }),
                                        activeColor: AppTheme.primaryColor,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      Text(
                                        'É criança (até 6 anos)',
                                        style: GoogleFonts.lato(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  if (isChild) ...[
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: ageCtrl,
                                      decoration: _styledInput(
                                        'Idade',
                                        FontAwesomeIcons.cakeCandles,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      // Ações
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: salvando
                                ? null
                                : () async {
                                    final nome = nomeCtrl.text.trim();
                                    final numero = numeroCtrl.text.trim();
                                    if (nome.isEmpty || numero.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Preencha nome e telefone do anfitrião',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final digits = numero.replaceAll(
                                      RegExp(r'\D'),
                                      '',
                                    );
                                    if (digits.length != 11) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Por favor, digite um telefone válido com 11 dígitos',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final convidados = <Map<String, dynamic>>[];
                                    for (
                                      var i = 0;
                                      i < guestNameCtrls.length;
                                      i++
                                    ) {
                                      final nomeConvidado = guestNameCtrls[i]
                                          .text
                                          .trim();
                                      if (nomeConvidado.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Preencha o nome do convidado ${i + 1}',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      final idadeTexto = guestAgeCtrls[i].text
                                          .trim();
                                      final idade = idadeTexto.isEmpty
                                          ? null
                                          : int.tryParse(idadeTexto);
                                      convidados.add({
                                        'nome': nomeConvidado,
                                        'idade': idade,
                                      });
                                    }

                                    setStateSB(() => salvando = true);
                                    await _supabaseService
                                        .criarAnfitriaComConvidados(
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Salvar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    bool convidadoDeHonra = false;
    final anfitrioesFuture = _supabaseService.obterTodosAnfitriaos();

    InputDecoration styledInput(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 480,
              ),
              child: FutureBuilder<List<Anfitriao>>(
                future: anfitrioesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Erro ao carregar anfitriões: ${snapshot.error}',
                      ),
                    );
                  }
                  final anfitrioes = snapshot.data ?? [];
                  if (anfitrioes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.circleExclamation,
                            size: 40,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum anfitrião cadastrado.',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crie um anfitrião primeiro.',
                            style: GoogleFonts.lato(
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  }

                  anfitriaoSelecionado ??= anfitrioes.first.id;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.accentColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.userPlus,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Novo Convidado',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Adicione um convidado a um anfitrião',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: AppTheme.lightTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                icon: const Icon(Icons.close, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Informações',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: nomeCtrl,
                            decoration: styledInput(
                              'Nome do convidado',
                              FontAwesomeIcons.user,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: idadeCtrl,
                            decoration: styledInput(
                              'Idade (opcional)',
                              FontAwesomeIcons.cakeCandles,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: anfitriaoSelecionado,
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
                            decoration: styledInput(
                              'Anfitrião',
                              FontAwesomeIcons.houseUser,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              convidadoDeHonra
                                  ? 'Convidado de Honra'
                                  : 'Convidado Regular',
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Destaque visual na lista e no PDF.',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: AppTheme.lightTextColor,
                              ),
                            ),
                            value: convidadoDeHonra,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              setStateSB(() => convidadoDeHonra = value);
                            },
                          ),
                          const SizedBox(height: 24),
                          // Ações
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text('Cancelar'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: salvando
                                    ? null
                                    : () async {
                                        final nome = nomeCtrl.text.trim();
                                        if (nome.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Digite o nome do convidado',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        if (anfitriaoSelecionado == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Selecione um anfitrião',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        final idade =
                                            idadeCtrl.text.trim().isEmpty
                                            ? null
                                            : int.tryParse(
                                                idadeCtrl.text.trim(),
                                              );
                                        setStateSB(() => salvando = true);
                                        await _supabaseService.criarConvidado(
                                          nome: nome,
                                          idAnfitriao: anfitriaoSelecionado!,
                                          idade: idade,
                                          convidadoHonra: convidadoDeHonra,
                                        );
                                        if (mounted) {
                                          setState(() {
                                            _convidados = _supabaseService
                                                .obterTodosConvidadosComAnfitriao();
                                            _estatisticas = _supabaseService
                                                .obterEstatisticas();
                                          });
                                          if (!context.mounted) return;
                                          Navigator.pop(dialogCtx);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Convidado adicionado',
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
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Salvar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatData {
  final String titulo;
  final String valor;
  final String subtitulo;
  final IconData icon;
  final Color color;
  final double? progress;

  _StatData(
    this.titulo,
    this.valor,
    this.subtitulo,
    this.icon,
    this.color, {
    this.progress,
  });
}

class _MenuItemData {
  final String label;
  final IconData icon;
  final int index;

  _MenuItemData(this.label, this.icon, this.index);
}
