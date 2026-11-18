import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'app_theme.dart';
import 'study_provider.dart';
import 'audio_mixer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => AudioMixerProvider()),
      ],
      child: const StudySpaceApp(),
    ),
  );
}

class StudySpaceApp extends StatelessWidget {
  const StudySpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgPaper,
        useMaterial3: true,
      ),
      builder: (context, child) {
        if (!kIsWeb) return child!;
        return Container(
          color: const Color(0xFF121816),
          alignment: Alignment.center,
          child: Container(
            width: 390,
            height: 844,
            decoration: BoxDecoration(
              color: AppColors.bgPaper,
              borderRadius: BorderRadius.circular(42),
              border: Border.all(color: const Color(0xFF2B3834), width: 10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: child,
            ),
          ),
        );
      },
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _abaAtual = 0;

  final List<Widget> _telas = const [
    FocoScreen(),
    AmbienteSonoroScreen(),
    MateriasEntregasScreen(),
    MetricasConfigScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPaper,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _abaAtual,
          children: _telas,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.navBarDark,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.timer_outlined, 'Foco'),
              _buildNavItem(1, Icons.headphones_outlined, 'Rádio'),
              _buildNavItem(2, Icons.menu_book_outlined, 'Matérias'),
              _buildNavItem(3, Icons.bar_chart_rounded, 'Métricas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final ativo = _abaAtual == index;
    final cor = ativo
        ? AppColors.terracotta
        : AppColors.textMutedLight.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () => setState(() => _abaAtual = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: cor, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.body(
              size: 10,
              weight: ativo ? FontWeight.w700 : FontWeight.w500,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TELA 01: ESPAÇO DE FOCO (TIMER / POMODORO)
// ============================================================================
class FocoScreen extends StatelessWidget {
  const FocoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();

    Map? materiaAtual;
    if (study.disciplinas.isNotEmpty) {
      materiaAtual = study.disciplinas.firstWhere(
        (d) => d['id'] == study.disciplinaSelecionadaId,
        orElse: () => study.disciplinas.first,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HORA DE SE CONCENTRAR', style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  Text('Seu espaço de foco.', style: AppTypography.serifTitle()),
                ],
              ),
              Stack(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: AppColors.textDark, size: 20),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDD875B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            decoration: BoxDecoration(
              color: AppColors.cardPetroleum,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardPetroleum.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModePill(
                        titulo: 'Foco',
                        ativo: !study.modoPausa,
                        onTap: () => study.alternarModoFocoOuPausa(false),
                      ),
                      _buildModePill(
                        titulo: 'Pausa',
                        ativo: study.modoPausa,
                        onTap: () => study.alternarModoFocoOuPausa(true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _abrirSeletorDisciplina(context, study),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE59B66),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          materiaAtual != null
                              ? '${materiaAtual['nome']} ⌄'
                              : 'Adicionar matéria ⌄',
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 224,
                  height: 224,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 224,
                        height: 224,
                        child: CircularProgressIndicator(
                          value: study.progressoCircular,
                          strokeWidth: 4.5,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.terracotta),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            study.modoPausa
                                ? 'RESPIRE E DESCANSE'
                                : 'AGORA, CONCENTRE-SE',
                            style: AppTypography.eyebrow(
                                    color: AppColors.textMutedLight)
                                .copyWith(fontSize: 9),
                          ),
                          const SizedBox(height: 6),
                          Text(study.tempoFormatado,
                              style: AppTypography.timerDigits()),
                          const SizedBox(height: 6),
                          Text(
                            'Sessão ${study.ciclosConcluidosHoje + 1} de 4',
                            style: AppTypography.body(
                              size: 11,
                              color: AppColors.textMutedLight
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlSecondary(
                      icon: Icons.refresh_rounded,
                      onTap: study.resetarTimer,
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: study.iniciarOuPausarTimer,
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3A06C),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          study.emExecucao
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.cardPetroleum,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildControlSecondary(
                      icon: Icons.skip_next_rounded,
                      onTap: () =>
                          study.alternarModoFocoOuPausa(!study.modoPausa),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill(
      {required String titulo,
      required bool ativo,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: ativo ? AppColors.pillBeige : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          titulo,
          style: AppTypography.body(
            size: 12,
            weight: FontWeight.w700,
            color: ativo ? const Color(0xFF20312B) : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }

  Widget _buildControlSecondary(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textLight, size: 20),
      ),
    );
  }

  void _abrirSeletorDisciplina(BuildContext context, StudyProvider study) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardCream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecionar disciplina',
                style: AppTypography.serifTitle(size: 18)),
            const SizedBox(height: 12),
            if (study.disciplinas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Nenhuma matéria cadastrada ainda. Vá na aba Matérias para criar a primeira.',
                  style:
                      AppTypography.body(size: 12, color: AppColors.textEyebrow),
                ),
              ),
            ...study.disciplinas.map(
              (d) => ListTile(
                title: Text(d['nome'],
                    style: AppTypography.body(weight: FontWeight.w700)),
                trailing: study.disciplinaSelecionadaId == d['id']
                    ? const Icon(Icons.check_circle, color: AppColors.sageGreen)
                    : null,
                onTap: () {
                  study.selecionarDisciplina(d['id'] as int);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TELA 02: RÁDIO DE FOCO & SONS DE AMBIENTE
// ============================================================================
class AmbienteSonoroScreen extends StatelessWidget {
  const AmbienteSonoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioMixerProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RÁDIO DE FOCO', style: AppTypography.eyebrow()),
          const SizedBox(height: 4),
          Text('Seu ambiente sonoro.', style: AppTypography.serifTitle()),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF281E38), Color(0xFF141824)],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.nightlight_round,
                              color: AppColors.terracotta, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            'lofi room',
                            style: AppTypography.eyebrow(
                                    color: AppColors.textLight)
                                .copyWith(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOCANDO AGORA',
                            style: AppTypography.eyebrow(
                                    color: AppColors.terracottaDeep)
                                .copyWith(fontSize: 9),
                          ),
                          const SizedBox(height: 2),
                          Text('Late Night Notes',
                              style: AppTypography.serifTitle(size: 18)),
                          const SizedBox(height: 2),
                          Text(
                            'Lofi Beats · 84 BPM',
                            style: AppTypography.body(
                                size: 11, color: AppColors.textEyebrow),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: audio.alternarLofi,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Color(0xFF273A33),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          audio.lofiTocando
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(28, (i) {
                    final alturas = [
                      8.0,
                      14.0,
                      22.0,
                      12.0,
                      26.0,
                      18.0,
                      10.0,
                      24.0,
                      16.0,
                      20.0
                    ];
                    final h = alturas[i % alturas.length];
                    return Container(
                      width: 3,
                      height: audio.lofiTocando ? h : 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF8D6B)
                            .withValues(alpha: i < 16 ? 1.0 : 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mix de ambiente',
                  style: AppTypography.serifTitle(size: 18)),
              Text('Ajuste ao seu espaço',
                  style:
                      AppTypography.body(size: 11, color: AppColors.textEyebrow)),
            ],
          ),
          const SizedBox(height: 14),
          _buildSliderAmbiente(
            icone: Icons.water_drop_rounded,
            titulo: 'Chuva suave',
            valor: audio.volumeChuva,
            onChanged: audio.ajustarChuva,
          ),
          const SizedBox(height: 12),
          _buildSliderAmbiente(
            icone: Icons.coffee_rounded,
            titulo: 'Café distante',
            valor: audio.volumeCafe,
            onChanged: audio.ajustarCafe,
          ),
          const SizedBox(height: 12),
          _buildSliderAmbiente(
            icone: Icons.air_rounded,
            titulo: 'Brisa nas folhas',
            valor: audio.volumeBrisa,
            onChanged: audio.ajustarBrisa,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderAmbiente({
    required IconData icone,
    required String titulo,
    required double valor,
    required ValueChanged<double> onChanged,
  }) {
    final ativo = valor > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ativo ? AppColors.terracotta : AppColors.bgPaper,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icone,
              size: 19,
              color: ativo ? AppColors.cardPetroleum : AppColors.textEyebrow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(titulo,
                        style: AppTypography.body(
                            size: 13, weight: FontWeight.w700)),
                    Text(
                      '${(valor * 100).round()}%',
                      style: AppTypography.eyebrow(color: AppColors.textDark),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: AppColors.terracotta,
                    inactiveTrackColor: AppColors.bgPaper,
                    thumbColor: AppColors.textDark,
                  ),
                  child: Slider(value: valor, onChanged: onChanged),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TELA 03: SUAS MATÉRIAS & ENTREGAS
// ============================================================================
class MateriasEntregasScreen extends StatelessWidget {
  const MateriasEntregasScreen({super.key});

  Color _parseCor(String hex) {
    if (hex == 'sage') return AppColors.sageGreen;
    if (hex == 'lilac') return AppColors.softLilac;
    return AppColors.terracotta;
  }

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ORGANIZAÇÃO ACADÊMICA', style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  Text('Suas matérias.', style: AppTypography.serifTitle()),
                ],
              ),
              IconButton(
                onPressed: () => _modalNovaDisciplina(context, study),
                style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardPetroleum),
                icon: const Icon(Icons.add,
                    color: AppColors.textLight, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(20),
            ),
            child: study.disciplinas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Toque no "+" acima para cadastrar suas disciplinas do semestre.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                            size: 12, color: AppColors.textEyebrow),
                      ),
                    ),
                  )
                : Column(
                    children: study.disciplinas.map((d) {
                      final estudados = d['minutos_estudados'] as int;
                      final meta = d['meta_minutos'] as int;
                      final progresso =
                          meta > 0 ? (estudados / meta).clamp(0.0, 1.0) : 0.0;
                      final horas = estudados ~/ 60;
                      final mins = estudados % 60;
                      final cor = _parseCor(d['cor'] as String);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: cor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(d['nome'],
                                      style: AppTypography.body(
                                          size: 13, weight: FontWeight.w700)),
                                ),
                                Text(
                                  '${horas}h ${mins.toString().padLeft(2, '0')}min',
                                  style: AppTypography.eyebrow(
                                      color: AppColors.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progresso,
                                minHeight: 6,
                                backgroundColor: AppColors.bgPaper,
                                valueColor: AlwaysStoppedAnimation<Color>(cor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Próximas entregas',
                  style: AppTypography.serifTitle(size: 19)),
              GestureDetector(
                onTap: () => _modalNovaTarefa(context, study),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.cardCream,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add,
                      size: 18, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (study.tarefas.isEmpty)
            Text(
              'Nenhuma entrega pendente. Clique em "+" para adicionar.',
              style: AppTypography.body(size: 12, color: AppColors.textEyebrow),
            ),
          ...study.tarefas.map((t) {
            final concluida = (t['concluida'] as int) == 1;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        study.marcarTarefa(t['id'] as int, !concluida),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: concluida
                            ? const Color(0xFF6D9482)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: concluida
                              ? const Color(0xFF6D9482)
                              : AppColors.textEyebrow,
                          width: 1.5,
                        ),
                      ),
                      child: concluida
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t['titulo'],
                          style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w700,
                            color: concluida
                                ? AppColors.textEyebrow
                                : AppColors.textDark,
                          ).copyWith(
                              decoration: concluida
                                  ? TextDecoration.lineThrough
                                  : null),
                        ),
                        Text(
                          t['disciplina_nome'],
                          style: AppTypography.body(
                              size: 11, color: AppColors.textEyebrow),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A171).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      t['prazo'],
                      style: AppTypography.body(
                        size: 10,
                        weight: FontWeight.w700,
                        color: AppColors.terracottaDeep,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _modalNovaDisciplina(BuildContext context, StudyProvider study) {
    final nomeCtrl = TextEditingController();
    final metaCtrl = TextEditingController(text: '20');
    String corSelecionada = 'terracotta';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardCream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nova Disciplina',
                  style: AppTypography.serifTitle(size: 20)),
              const SizedBox(height: 14),
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome da matéria (ex: Cálculo II)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: metaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Meta semestral (horas)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Cor: ',
                      style: AppTypography.body(weight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  _chipCor('terracotta', AppColors.terracotta, corSelecionada,
                      (c) => setModalState(() => corSelecionada = c)),
                  const SizedBox(width: 8),
                  _chipCor('sage', AppColors.sageGreen, corSelecionada,
                      (c) => setModalState(() => corSelecionada = c)),
                  const SizedBox(width: 8),
                  _chipCor('lilac', AppColors.softLilac, corSelecionada,
                      (c) => setModalState(() => corSelecionada = c)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardPetroleum,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    if (nomeCtrl.text.trim().isNotEmpty) {
                      study.adicionarDisciplina(nomeCtrl.text.trim(),
                          corSelecionada, int.tryParse(metaCtrl.text) ?? 20);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Salvar Matéria'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipCor(
      String id, Color cor, String atual, ValueChanged<String> onSelect) {
    return GestureDetector(
      onTap: () => onSelect(id),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          border: atual == id
              ? Border.all(color: AppColors.textDark, width: 2.5)
              : null,
        ),
      ),
    );
  }

  void _modalNovaTarefa(BuildContext context, StudyProvider study) {
    final tituloCtrl = TextEditingController();
    final prazoCtrl = TextEditingController(text: 'Hoje, 18:00');
    String matSelecionada = study.disciplinas.isNotEmpty
        ? study.disciplinas.first['nome']
        : 'Geral';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardCream,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nova Entrega', style: AppTypography.serifTitle(size: 20)),
            const SizedBox(height: 14),
            TextField(
              controller: tituloCtrl,
              decoration: const InputDecoration(
                  labelText: 'Título da entrega (ex: Lista de integrais)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prazoCtrl,
              decoration: const InputDecoration(
                  labelText: 'Prazo (ex: Hoje, 18:00)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardPetroleum,
                    foregroundColor: Colors.white),
                onPressed: () {
                  if (tituloCtrl.text.trim().isNotEmpty) {
                    study.adicionarTarefa(tituloCtrl.text.trim(),
                        matSelecionada, prazoCtrl.text.trim());
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Adicionar Entrega'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TELA 04: MÉTRICAS & PRIVACIDADE (CONFORMIDADE GOOGLE PLAY STORE)
// ============================================================================
class MetricasConfigScreen extends StatelessWidget {
  const MetricasConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();
    final totalMinutos = study.disciplinas
        .fold<int>(0, (soma, d) => soma + (d['minutos_estudados'] as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DESEMPENHO & CONTA', style: AppTypography.eyebrow()),
          const SizedBox(height: 4),
          Text('Suas métricas.', style: AppTypography.serifTitle()),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardPetroleum,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TEMPO TOTAL FOCADO',
                    style:
                        AppTypography.eyebrow(color: AppColors.textMutedLight)),
                const SizedBox(height: 6),
                Text(
                  '${totalMinutos ~/ 60}h ${(totalMinutos % 60).toString().padLeft(2, '0')}min',
                  style: AppTypography.timerDigits().copyWith(fontSize: 34),
                ),
                const SizedBox(height: 6),
                Text(
                  '${study.ciclosConcluidosHoje} sessões concluídas hoje',
                  style: AppTypography.body(
                      size: 12, color: AppColors.terracotta),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Privacidade & Google Play',
              style: AppTypography.serifTitle(size: 18)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardCream,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Seus dados ficam armazenados localmente no dispositivo.',
                    style: AppTypography.body(size: 12)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                    onPressed: () async {
                      await study.resetarAppPlayStore();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Todos os dados foram apagados do dispositivo.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_forever_rounded, size: 18),
                    label: const Text('Excluir Todos os Meus Dados'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}