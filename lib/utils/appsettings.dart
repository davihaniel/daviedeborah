class AppSettings {
  // Url do supabase
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  // Keys do supabase
  static const supabaseKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: '',
  );

  String get supabaseUrlValue => supabaseUrl;
  String get supabaseKeyValue => supabaseKey;

  // Dados do pix
  static const pixKey = String.fromEnvironment('PIX_KEY', defaultValue: '');
  static const pixName = String.fromEnvironment('PIX_NAME', defaultValue: '');
  static const pixBank = String.fromEnvironment('PIX_BANK', defaultValue: '');
  
  String get pixKeyValue => pixKey;
  String get pixNameValue => pixName;
  String get pixBankValue => pixBank;

  // Data do casamento
  final weddingDate = DateTime(2026, 7, 12, 15, 00, 00);

  // Data limite para RSVP
  final rsvpLimitDate = DateTime(2026, 5, 31, 23, 59, 59);

  // Máximo de convidados por RSVP
  final countMaxGuests = 5;

  // Habilitar/desabilitar RSVP
  final rsvpEnable = false;

  // Lista de imagens do carrossel
  final List<String> galeryImages;

  // Versão atual do app
  String versaoAtual;

  AppSettings({
    this.versaoAtual = '',
  }) : galeryImages = loadGaleryImages();

  /// Carregar URL imagens
  static List<String> loadGaleryImages() {
    if (supabaseUrl.isEmpty) return [];
    return [
      '$supabaseUrl/storage/v1/object/public/photos/foto_1.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_2.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_3.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_4.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_5.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_6.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_7.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_8.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_9.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_10.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_11.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_12.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_13.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_14.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_15.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_16.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_17.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_18.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_19.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_20.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_21.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_22.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_23.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_24.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_25.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_26.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_27.jpg',
      '$supabaseUrl/storage/v1/object/public/photos/foto_28.jpg',
    ];
  }
  
  String getRandomBackgroundImage() {
    final list = galeryImages;
    list.shuffle();
    return list.isNotEmpty ? list.first : '';
  }

  AppSettings copyWith({
    String? versaoAtual,
  }) {
    return AppSettings(
      versaoAtual: versaoAtual ?? this.versaoAtual,
    );
  }
}
