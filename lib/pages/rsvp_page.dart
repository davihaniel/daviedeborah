import 'package:daviedeborah/utils/extensions.dart';
import 'package:daviedeborah/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/section_title.dart';
import '../config/app_theme.dart';
import '../stores/rsvp_store.dart';
import '../services/supabase_service.dart';

// Máscara de telefone customizada
class PhoneMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Remove tudo que não é dígito
    final digits = text.replaceAll(RegExp(r'\D'), '');

    // Limita a 11 dígitos (2 DDD + 9 do número)
    if (digits.length > 11) {
      return oldValue;
    }

    String formatted = '';

    if (digits.isNotEmpty) {
      if (digits.length <= 2) {
        formatted = '($digits';
      } else if (digits.length <= 7) {
        formatted = '(${digits.substring(0, 2)}) ${digits.substring(2)}';
      } else {
        formatted =
            '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      ),
    );
  }
}

class RsvpPage extends StatefulWidget {
  const RsvpPage({super.key});

  @override
  State<RsvpPage> createState() => _RsvpPageState();
}

class _RsvpPageState extends State<RsvpPage> {
  final RsvpStore _store = RsvpStore();
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _guestNameCtrls = [];
  final List<TextEditingController> _guestAgeCtrls = [];
  final List<bool> _guestIsChild = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _syncGuestControllersLength(_store.numeroPessoas);
  }

  @override
  void dispose() {
    for (final c in _guestNameCtrls) {
      c.dispose();
    }
    for (final c in _guestAgeCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncGuestControllersLength(int count) {
    // expand
    while (_guestNameCtrls.length < count) {
      _guestNameCtrls.add(TextEditingController());
    }
    while (_guestAgeCtrls.length < count) {
      _guestAgeCtrls.add(TextEditingController());
    }
    while (_guestIsChild.length < count) {
      _guestIsChild.add(false);
    }
    // shrink
    while (_guestNameCtrls.length > count) {
      _guestNameCtrls.removeLast().dispose();
    }
    while (_guestAgeCtrls.length > count) {
      _guestAgeCtrls.removeLast().dispose();
    }
    while (_guestIsChild.length > count) {
      _guestIsChild.removeLast();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const SectionTitle(
            title: 'Confirme sua Presença',
            subtitle: 'Queremos você conosco!',
          ),
          const SizedBox(height: 48),

          _buildRsvpForm(context, isMobile),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildRsvpForm(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 100),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : 48),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  FontAwesomeIcons.envelopeOpenText,
                  size: isMobile ? 50 : 60,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Por favor, confirme sua presença até ${rsvpLimitDate.dataNomeMes}',
                  style: GoogleFonts.lato(
                    fontSize: isMobile ? 15 : 16,
                    color: AppTheme.lightTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Nome
                Observer(
                  builder: (_) => TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nome Completo *',
                      hintText: 'Digite seu nome completo',
                      prefixIcon: const Icon(FontAwesomeIcons.user),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite seu nome';
                      }
                      return null;
                    },
                    onChanged: _store.setNome,
                  ),
                ),

                const SizedBox(height: 24),

                // Email
                Observer(
                  builder: (_) => TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Telefone *',
                      hintText: '(99) 99999-9999',
                      prefixIcon: const Icon(FontAwesomeIcons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneMaskFormatter()],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite seu telefone';
                      }
                      final digits = value.replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 11) {
                        return 'Por favor, digite um telefone válido com 11 dígitos';
                      }
                      return null;
                    },
                    onChanged: _store.setTelefone,
                  ),
                ),

                const SizedBox(height: 24),

                // Confirmação
                Observer(
                  builder: (_) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Você irá ao casamento? *',
                          style: GoogleFonts.lato(
                            fontSize: isMobile ? 15 : 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            RadioListTile<bool>(
                              title: const Text('Sim, estarei lá!'),
                              value: true,
                              groupValue: _store.confirmado,
                              onChanged: (value) =>
                                  _store.setConfirmado(value!),
                              activeColor: AppTheme.primaryColor,
                            ),
                            RadioListTile<bool>(
                              title: const Text('Não poderei ir'),
                              value: false,
                              groupValue: _store.confirmado,
                              onChanged: (value) =>
                                  _store.setConfirmado(value!),
                              activeColor: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Número de pessoas (só aparece se confirmado)
                Observer(
                  builder: (_) => _store.confirmado
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Número de acompanhantes (incluindo você):',
                              style: GoogleFonts.lato(
                                fontSize: isMobile ? 15 : 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_store.numeroPessoas > 1) {
                                      _store.setNumeroPessoas(
                                        _store.numeroPessoas - 1,
                                      );
                                      _syncGuestControllersLength(
                                        _store.numeroPessoas,
                                      );
                                    }
                                  },
                                  icon: const Icon(FontAwesomeIcons.minus),
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_store.numeroPessoas}',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {
                                    if (_store.numeroPessoas < countMaxGuests) {
                                      _store.setNumeroPessoas(
                                        _store.numeroPessoas + 1,
                                      );
                                      _syncGuestControllersLength(
                                        _store.numeroPessoas,
                                      );
                                    }
                                  },
                                  icon: const Icon(FontAwesomeIcons.plus),
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildGuestsList(context, isMobile),
                            const SizedBox(height: 24),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),

                // Botão de envio
                Observer(
                  builder: (_) => ElevatedButton(
                    onPressed: (_store.formularioValido && !_isSubmitting)
                        ? () => _submitForm(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 16 : 20,
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : Text(
                            'Confirmar',
                            style: GoogleFonts.lato(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Caso já tenha confirmado sua presença, mas deseja alterar alguma informação, por favor entre em contato conosco.',
                  style: GoogleFonts.lato(
                    fontSize: isMobile ? 15 : 16,
                    color: AppTheme.lightTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestsList(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nomes dos convidados',
          style: GoogleFonts.lato(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _store.numeroPessoas,
          itemBuilder: (context, index) {
            final nameCtrl = _guestNameCtrls[index];
            final ageCtrl = _guestAgeCtrls[index];
            final isChild = _guestIsChild[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nome do convidado ${index + 1} *',
                        hintText: 'Digite o nome completo',
                        prefixIcon: const Icon(FontAwesomeIcons.user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('É criança? (até 6 anos)'),
                      value: isChild,
                      onChanged: (value) {
                        setState(() {
                          _guestIsChild[index] = value ?? false;
                          if (!value!) {
                            ageCtrl.clear();
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (isChild) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: ageCtrl,
                        decoration: InputDecoration(
                          labelText: 'Idade da criança *',
                          hintText: 'ex: 3',
                          prefixIcon: const Icon(FontAwesomeIcons.cakeCandles),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // validação adicional de convidados quando confirmado
      if (_store.confirmado) {
        for (var i = 0; i < _store.numeroPessoas; i++) {
          final name = _guestNameCtrls.length > i
              ? _guestNameCtrls[i].text.trim()
              : '';
          if (name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Preencha o nome de todos os convidados.'),
              ),
            );
            return;
          }
          // Validar idade se for criança
          if (_guestIsChild[i]) {
            final age = _guestAgeCtrls[i].text.trim();
            if (age.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Preencha a idade da criança $name.')),
              );
              return;
            }
          }
        }
      }

      // Iniciar carregamento
      setState(() => _isSubmitting = true);

      try {
        // Preparar dados dos convidados
        final convidados = <Map<String, dynamic>>[];
        if (_store.confirmado) {
          for (var i = 0; i < _store.numeroPessoas; i++) {
            final nome = _guestNameCtrls[i].text.trim();
            final idade =
                _guestIsChild[i] ? int.tryParse(_guestAgeCtrls[i].text) : null;
            convidados.add({'nome': nome, 'idade': idade});
          }
        }

        // Criar anfitrião com convidados
        await _supabaseService.criarAnfitriaComConvidados(
          nome: _store.nome,
          numero: _store.telefone,
          convidados: convidados,
          confirmacao: _store.confirmado,
        );

        if (!mounted) return;

        setState(() => _isSubmitting = false);

        // Mostrar dialog de sucesso
        if(!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  _store.confirmado
                      ? FontAwesomeIcons.circleCheck
                      : FontAwesomeIcons.circleInfo,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _store.confirmado ? 'Confirmado!' : 'Recebido!',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            content: _store.confirmado
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Obrigado por confirmar sua presença, ${_store.nome}!',
                        style: GoogleFonts.lato(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Convidados:',
                        style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(_store.numeroPessoas, (i) {
                        final nome = _guestNameCtrls[i].text.trim();
                        final idade =
                            int.tryParse(_guestAgeCtrls[i].text.trim());
                        final crianca = idade != null && idade <= 6;
                        final detalheIdade =
                            idade == null ? '' : ' - $idade anos';
                        return Text(
                          '• $nome$detalheIdade ${crianca ? "(criança)" : ""}',
                          style: GoogleFonts.lato(),
                        );
                      }),
                    ],
                  )
                : Text(
                    'Sentiremos sua falta, ${_store.nome}. Obrigado por nos avisar.',
                    style: GoogleFonts.lato(),
                  ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _store.limpar();
                  _formKey.currentState!.reset();
                  _syncGuestControllersLength(_store.numeroPessoas);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        if (!mounted) return;

        setState(() => _isSubmitting = false);

        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar formulário: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
