import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import '../stores/admin_store.dart';
import '../config/app_theme.dart';

class AdminLoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final AdminStore store;

  const AdminLoginPage({
    super.key,
    required this.onLoginSuccess,
    required this.store,
  });

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _mostrarSenha = false;

  String fundoAleatorio = '';

  @override
  void initState() {
    fundoAleatorio = appSettings.getRandomBackgroundImage();
    super.initState();
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Container(
        decoration: BoxDecoration(
          // Fundo com blur
          image: DecorationImage(
            image: CachedNetworkImageProvider(fundoAleatorio),
            alignment: AlignmentGeometry.center,
            scale: 1.0,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 24 : 48),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 32 : 48),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Icon(
                            FontAwesomeIcons.lock,
                            size: isMobile ? 50 : 60,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Painel Administrativo',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: isMobile ? 24 : 28,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Mensagem de erro
                          Observer(
                            builder: (_) => widget.store.mensagemErro != null
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.circleExclamation,
                                          color: Colors.red.shade700,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            widget.store.mensagemErro!,
                                            style: GoogleFonts.lato(
                                              color: Colors.red.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: widget.store.limparErro,
                                          child: Icon(
                                            FontAwesomeIcons.xmark,
                                            color: Colors.red.shade700,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          if (widget.store.mensagemErro != null)
                            const SizedBox(height: 16),

                          // Usuário
                          TextFormField(
                            controller: _usuarioController,
                            onFieldSubmitted: (_) => _fazerLogin(),
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              hintText: 'Digite seu e-mail',
                              prefixIcon: const Icon(FontAwesomeIcons.user),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite seu usuário';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Senha (não precisa de Observer porque usa estado local)
                          TextFormField(
                            controller: _senhaController,
                            obscureText: !_mostrarSenha,
                            onFieldSubmitted: (_) => _fazerLogin(),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              hintText: 'Digite sua senha',
                              prefixIcon: const Icon(FontAwesomeIcons.key),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _mostrarSenha = !_mostrarSenha;
                                  });
                                },
                                child: Icon(
                                  _mostrarSenha
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, digite sua senha';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Botão de login
                          Observer(
                            builder: (_) => ElevatedButton(
                              onPressed: widget.store.carregando
                                  ? null
                                  : () => _fazerLogin(),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 14 : 16,
                                ),
                              ),
                              child: widget.store.carregando
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Entrar',
                                      style: GoogleFonts.lato(
                                        fontSize: isMobile ? 16 : 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 14),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Voltar ao site"),
                          ),
                          SizedBox(height: 10),

                          Text(
                            appSettings.versaoAtual,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: isMobile ? 12 : 14,
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      final sucesso = await widget.store.fazerLogin(
        _usuarioController.text,
        _senhaController.text,
      );

      if (sucesso) {
        widget.onLoginSuccess();
      }
    }
  }
}
