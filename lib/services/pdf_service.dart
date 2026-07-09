import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/convidado.dart';

/// Converte cor Flutter (0xAARRGGBB) para PdfColor
PdfColor _hex(int argb) {
  final r = ((argb >> 16) & 0xFF) / 255.0;
  final g = ((argb >> 8) & 0xFF) / 255.0;
  final b = (argb & 0xFF) / 255.0;
  return PdfColor(r, g, b);
}

// Paleta do sistema
final _primaryColor = _hex(0xFFBBC794); // sage green
final _accentColor = _hex(0xFF9B705C);  // terracotta
final _textColor = _hex(0xFF4A4A4A);
final _lightText = _hex(0xFF8A8A8A);
final _childBg = PdfColor(1.0, 0.929, 0.835);    // laranja bem claro
final _childAccent = PdfColor(0.929, 0.506, 0.114); // laranja
final _honorBg = PdfColor(0.918, 0.960, 0.914);
final _honorAccent = PdfColor(0.224, 0.545, 0.286);
final _dangerBg = PdfColor(1.0, 0.918, 0.918);
final _dangerBorder = PdfColor(0.937, 0.267, 0.267);
final _statBg = PdfColor(0.973, 0.980, 0.969);

/// Formata nome em Title Case
String _titleCase(String nome) {
  return nome
      .trim()
      .toLowerCase()
      .split(' ')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

/// Formata data no padrão dd/MM/yyyy
String _formatDate(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}

class PdfService {
  /// Gera o PDF com a lista de convidados confirmados.
  ///
  /// [convidados] deve estar na ordem desejada (mesma da tela).
  /// [stats] é o mapa retornado por `SupabaseService.obterEstatisticas()`.
  /// [agruparPorAnfitriao] quando verdadeiro, organiza a tabela por grupo de anfitrião.
  static Future<Uint8List> gerarListaConvidados(
    List<Convidado> convidados,
    Map<String, dynamic> stats, {
    bool agruparPorAnfitriao = false,
  }) async {
    final doc = pw.Document();

    // ── Carregamento de fontes ───────────────────────────────────────────────
    final fontPlayfairBold = await PdfGoogleFonts.playfairDisplayBold();
    final fontLato = await PdfGoogleFonts.latoRegular();
    final fontLatoBold = await PdfGoogleFonts.latoBold();
    final fontLatoItalic = await PdfGoogleFonts.latoItalic();

    // ── Estatísticas ─────────────────────────────────────────────────────────
    final totalConfirmados = convidados.length;
    final totalAdultos = convidados.where((c) => !c.isCrianca).length;
    final totalCriancas = convidados.where((c) => c.isCrianca).length;
    final totalPagantes = totalAdultos; // crianças < 6 não contam
    final limiteUltrapassado = totalAdultos > 150;

    final geradoEm = DateTime.now();
    final geradoEmStr =
        '${_formatDate(geradoEm)} às ${geradoEm.hour.toString().padLeft(2, '0')}h${geradoEm.minute.toString().padLeft(2, '0')}';

    // ── Estilos reutilizáveis ─────────────────────────────────────────────────
    pw.TextStyle style(
      pw.Font font, {
      double size = 10,
      PdfColor? color,
    }) =>
        pw.TextStyle(
          font: font,
          fontSize: size,
          color: color ?? _textColor,
          fontFallback: [fontLato],
        );

    // ── Cabeçalho de página (repetido em todas as páginas) ───────────────────
    pw.Widget buildHeader(pw.Context ctx) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Davi & Deborah',
                    style: pw.TextStyle(
                      font: fontPlayfairBold,
                      fontSize: 22,
                      color: _primaryColor,
                    ),
                  ),
                  pw.Text(
                    'Lista de Convidados Confirmados',
                    style: style(fontLato, size: 10, color: _lightText),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Gerado em',
                    style: style(fontLato, size: 8, color: _lightText),
                  ),
                  pw.Text(
                    geradoEmStr,
                    style: style(fontLatoBold, size: 9, color: _textColor),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            height: 2,
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [_primaryColor, _accentColor],
              ),
            ),
          ),
          pw.SizedBox(height: 4),
        ],
      );
    }

    // ── Rodapé de página ──────────────────────────────────────────────────────
    pw.Widget buildFooter(pw.Context ctx) {
      return pw.Column(
        children: [
          pw.Container(height: 1, color: _hex(0xFFE0E0E0)),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Davi & Deborah — Uso restrito',
                style: style(fontLatoItalic, size: 8, color: _lightText),
              ),
              pw.Text(
                'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                style: style(fontLato, size: 8, color: _lightText),
              ),
            ],
          ),
        ],
      );
    }

    // ── Definição de colunas e larguras ──────────────────────────────────────
    final colunas = [
      'Nome',
      'Idade',
      'Criança',
      'Anfitrião',
      'Data de Confirmação',
      'Entrada',
    ];

    // columnWidths usa pw.Table, que garante alinhamento perfeito entre header e linhas
    final colWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(2.8),
      1: const pw.FlexColumnWidth(0.7),
      2: const pw.FlexColumnWidth(0.8),
      3: const pw.FlexColumnWidth(2.0),
      4: const pw.FlexColumnWidth(1.3),
      5: const pw.FlexColumnWidth(0.9),
    };

    pw.TableRow buildHeaderRow() {
      return pw.TableRow(
        decoration: pw.BoxDecoration(color: _primaryColor),
        children: colunas
            .map(
              (col) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                child: pw.Text(
                  col,
                  style: pw.TextStyle(
                    font: fontLatoBold,
                    fontSize: 8,
                    color: PdfColors.white,
                  ),
                ),
              ),
            )
            .toList(),
      );
    }

    pw.TableRow buildRow(Convidado c, int index, {bool sombreado = false}) {
      final crianca = c.isCrianca;
      final honra = c.convidadoHonra;
      final bg = honra
          ? _honorBg
          : (crianca ? _childBg : (sombreado ? _statBg : PdfColors.white));

      pw.Widget buildNomeCell() {
        final badges = <pw.Widget>[];

        if (honra) {
          badges.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(left: 6),
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: pw.BoxDecoration(
                color: _honorAccent,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
              child: pw.Text(
                'Honra',
                style: pw.TextStyle(
                  font: fontLatoBold,
                  fontSize: 6.5,
                  color: PdfColors.white,
                ),
              ),
            ),
          );
        }

        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Text(
                _titleCase(c.nome),
                style: style(
                  fontLatoBold,
                  size: 8,
                  color: honra ? _honorAccent : _textColor,
                ),
              ),
            ),
            ...badges,
          ],
        );
      }

      final cells = [
        buildNomeCell(),
        c.idade != null ? '${c.idade} anos' : '—',
        crianca ? 'Sim' : '',
        _titleCase(c.nomeAnfitriao ?? '—'),
        _formatDate(c.datCriacao),
        pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Container(
            width: 10,
            height: 10,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _textColor, width: 0.8),
            ),
          ),
        ),
      ];

      return pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: cells.asMap().entries.map((e) {
          final isCriancaCol = e.key == 2 && crianca;
          final value = e.value;
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: value is pw.Widget
                ? value
                : isCriancaCol
                    ? pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: pw.BoxDecoration(
                          color: _childAccent,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(3),
                          ),
                        ),
                        child: pw.Text(
                          'Criança',
                          style: pw.TextStyle(
                            font: fontLatoBold,
                            fontSize: 7,
                            color: PdfColors.white,
                          ),
                        ),
                      )
                    : pw.Text(
                        value.toString(),
                        style: style(
                          e.key == 0 ? fontLatoBold : fontLato,
                          size: 8,
                          color: crianca ? _accentColor : _textColor,
                        ),
                      ),
          );
        }).toList(),
      );
    }

    // ── Modo: lista agrupada por anfitrião ────────────────────────────────────
    List<pw.Widget> buildTabela(List<Convidado> lista) {
      if (!agruparPorAnfitriao) {
        return [
          pw.Table(
            columnWidths: colWidths,
            children: [
              buildHeaderRow(),
              ...lista.asMap().entries.map(
                (e) => buildRow(e.value, e.key, sombreado: e.key.isOdd),
              ),
            ],
          ),
        ];
      }

      // Agrupa mantendo a ordem original
      final grupos = <String, List<Convidado>>{};
      for (final c in lista) {
        final chave = c.nomeAnfitriao ?? 'Sem anfitrião';
        grupos.putIfAbsent(chave, () => []).add(c);
      }

      final widgets = <pw.Widget>[];
      int numeroGlobal = 0;

      for (final entry in grupos.entries) {
        // Sub-cabeçalho do grupo
        widgets.add(
          pw.Container(
            color: _hex(0xFFEEF2E6),
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Anfitrião: ${_titleCase(entry.key)}',
                  style: pw.TextStyle(
                    font: fontLatoBold,
                    fontSize: 9,
                    color: _accentColor,
                  ),
                ),
                pw.Text(
                  '${entry.value.length} convidado${entry.value.length != 1 ? 's' : ''}',
                  style: style(fontLato, size: 8, color: _lightText),
                ),
              ],
            ),
          ),
        );

        final startIndex = numeroGlobal;
        widgets.add(
          pw.Table(
            columnWidths: colWidths,
            children: [
              buildHeaderRow(),
              ...entry.value.asMap().entries.map(
                (e) => buildRow(entry.value[e.key], startIndex + e.key, sombreado: e.key.isOdd),
              ),
            ],
          ),
        );
        numeroGlobal += entry.value.length;

        widgets.add(pw.SizedBox(height: 8));
      }

      return widgets;
    }

    // ── Montagem das páginas ──────────────────────────────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        header: buildHeader,
        footer: buildFooter,
        build: (ctx) => [
          pw.SizedBox(height: 4),
          // Título da tabela
          pw.Text(
            agruparPorAnfitriao
                ? 'Convidados por Anfitrião'
                : 'Lista de Convidados',
            style: pw.TextStyle(
              font: fontPlayfairBold,
              fontSize: 13,
              color: _textColor,
            ),
          ),
          pw.SizedBox(height: 6),
          ...buildTabela(convidados),
        ],
      ),
    );

    return doc.save();
  }
}
