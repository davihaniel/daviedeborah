import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/section_title.dart';
import '../config/app_theme.dart';
import '../stores/mensagem_store.dart';

class RecadosPage extends StatefulWidget {
  const RecadosPage({super.key});

  @override
  State<RecadosPage> createState() => _RecadosPageState();
}

class _RecadosPageState extends State<RecadosPage> {
  final MensagemStore _store = MensagemStore();
  final _nomeController = TextEditingController();
  final _mensagemController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isExpanded = false;
  static const int _initialMessagesCount = 3;

  @override
  void dispose() {
    _nomeController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: AppTheme.lightGray,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
          children: [
            const SectionTitle(
              title: 'Recados',
              subtitle: 'Deixe uma mensagem especial para nós',
            ),
            const SizedBox(height: 48),
            
            _buildMessageForm(context, isMobile),
            
            const SizedBox(height: 48),
            
            _buildMessagesList(isMobile),
            
            const SizedBox(height: 48),
          ],
        ),
    );
  }

  Widget _buildMessageForm(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 100,
      ),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.penToSquare,
                      size: isMobile ? 30 : 40,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Deixe seu recado',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Nome
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Seu Nome *',
                    hintText: 'Digite seu nome',
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
                ),
                
                const SizedBox(height: 16),
                
                // Mensagem
                TextFormField(
                  controller: _mensagemController,
                  decoration: InputDecoration(
                    labelText: 'Sua Mensagem *',
                    hintText: 'Escreva uma mensagem carinhosa para o casal...',
                    prefixIcon: const Icon(FontAwesomeIcons.message),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 5,
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, escreva uma mensagem';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Botão
                ElevatedButton.icon(
                  onPressed: () => _enviarMensagem(context),
                  icon: const Icon(FontAwesomeIcons.paperPlane, size: 16),
                  label: const Text('Enviar Recado'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 16 : 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 100,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.comments,
                size: isMobile ? 24 : 28,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Mensagens dos Convidados',
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Observer(
            builder: (_) => Text(
              '${_store.totalMensagens} ${_store.totalMensagens == 1 ? "mensagem" : "mensagens"}',
              style: GoogleFonts.lato(
                fontSize: isMobile ? 14 : 16,
                color: AppTheme.lightTextColor,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          Observer(
            builder: (_) {
              final allMessages = _store.mensagens.reversed.toList();
              final hasMoreMessages = allMessages.length > _initialMessagesCount;
              final messagesToShow = _isExpanded || !hasMoreMessages
                  ? allMessages
                  : allMessages.take(_initialMessagesCount).toList();

              return Column(
                children: [
                  Stack(
                    children: [
                      Column(
                        children: messagesToShow.map((mensagem) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildMessageCard(mensagem, isMobile),
                          );
                        }).toList(),
                      ),
                      if (!_isExpanded && hasMoreMessages)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.lightGray.withOpacity(0.0),
                                  AppTheme.lightGray.withOpacity(0.7),
                                  AppTheme.lightGray,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (hasMoreMessages) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      icon: Icon(
                        _isExpanded
                            ? FontAwesomeIcons.chevronUp
                            : FontAwesomeIcons.chevronDown,
                        size: 16,
                      ),
                      label: Text(
                        _isExpanded
                            ? 'Ver menos'
                            : 'Ver mais (${allMessages.length - _initialMessagesCount} mensagens)',
                        style: GoogleFonts.lato(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 24,
                          vertical: isMobile ? 12 : 16,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Mensagem mensagem, bool isMobile) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.accentColor.withValues(alpha: 0.1),
                  child: Icon(
                    FontAwesomeIcons.user,
                    size: isMobile ? 16 : 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mensagem.nome,
                        style: GoogleFonts.lato(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      Text(
                        dateFormat.format(mensagem.data),
                        style: GoogleFonts.lato(
                          fontSize: isMobile ? 12 : 13,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mensagem.mensagem,
              style: GoogleFonts.lato(
                fontSize: isMobile ? 14 : 15,
                color: AppTheme.textColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _enviarMensagem(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _store.adicionarMensagem(
        _nomeController.text,
        _mensagemController.text,
      );
      
      _nomeController.clear();
      _mensagemController.clear();
      _formKey.currentState!.reset();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(FontAwesomeIcons.circleCheck, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mensagem enviada com sucesso!\nEla aparecerá aqui em breve após moderação.',
                  style: GoogleFonts.lato(),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
