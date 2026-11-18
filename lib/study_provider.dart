import 'dart:async';
import 'package:flutter/material.dart';
import 'database_helper.dart';

class StudyProvider extends ChangeNotifier {
  List disciplinas = [];
  List tarefas = [];
  int? disciplinaSelecionadaId;

  static const int tempoFocoPadrao = 25 * 60;
  static const int tempoPausaPadrao = 5 * 60;

  int segundosRestantes = tempoFocoPadrao;
  int tempoTotalCiclo = tempoFocoPadrao;
  bool emExecucao = false;
  bool modoPausa = false;
  int ciclosConcluidosHoje = 0;
  Timer? _timer;

  StudyProvider() {
    carregarDados();
  }

  double get progressoCircular {
    if (tempoTotalCiclo == 0) return 0;
    return segundosRestantes / tempoTotalCiclo;
  }

  String get tempoFormatado {
    final minutos = (segundosRestantes ~/ 60).toString().padLeft(2, '0');
    final segundos = (segundosRestantes % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }

  Future<void> carregarDados() async {
    disciplinas = await DatabaseHelper.instance.listarDisciplinas();
    tarefas = await DatabaseHelper.instance.listarTarefas();

    if (disciplinas.isNotEmpty && disciplinaSelecionadaId == null) {
      disciplinaSelecionadaId = disciplinas.first['id'] as int;
    }
    notifyListeners();
  }

  void selecionarDisciplina(int? id) {
    disciplinaSelecionadaId = id;
    notifyListeners();
  }

  void iniciarOuPausarTimer() {
    if (emExecucao) {
      _timer?.cancel();
      emExecucao = false;
      notifyListeners();
      return;
    }

    emExecucao = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (segundosRestantes > 0) {
        segundosRestantes--;
        notifyListeners();
      } else {
        await _finalizarCiclo();
      }
    });
  }

  void resetarTimer() {
    _timer?.cancel();
    emExecucao = false;
    tempoTotalCiclo = modoPausa ? tempoPausaPadrao : tempoFocoPadrao;
    segundosRestantes = tempoTotalCiclo;
    notifyListeners();
  }

  void alternarModoFocoOuPausa(bool irParaPausa) {
    _timer?.cancel();
    emExecucao = false;
    modoPausa = irParaPausa;
    tempoTotalCiclo = modoPausa ? tempoPausaPadrao : tempoFocoPadrao;
    segundosRestantes = tempoTotalCiclo;
    notifyListeners();
  }

  Future<void> _finalizarCiclo() async {
    _timer?.cancel();
    emExecucao = false;

    if (!modoPausa) {
      ciclosConcluidosHoje++;
      if (disciplinaSelecionadaId != null) {
        await DatabaseHelper.instance
            .somarMinutosEstudados(disciplinaSelecionadaId!, 25);
        await carregarDados();
      }
      modoPausa = true;
      tempoTotalCiclo = tempoPausaPadrao;
      segundosRestantes = tempoPausaPadrao;
    } else {
      modoPausa = false;
      tempoTotalCiclo = tempoFocoPadrao;
      segundosRestantes = tempoFocoPadrao;
    }
    notifyListeners();
  }

  Future<void> adicionarDisciplina(
      String nome, String cor, int metaHoras) async {
    await DatabaseHelper.instance.inserirDisciplina(nome, cor, metaHoras);
    await carregarDados();
  }

  Future<void> adicionarTarefa(
      String titulo, String disciplinaNome, String prazo) async {
    await DatabaseHelper.instance.inserirTarefa(titulo, disciplinaNome, prazo);
    await carregarDados();
  }

  Future<void> marcarTarefa(int id, bool concluida) async {
    await DatabaseHelper.instance.alternarTarefaConcluida(id, concluida);
    await carregarDados();
  }

  Future<void> resetarAppPlayStore() async {
    _timer?.cancel();
    emExecucao = false;
    await DatabaseHelper.instance.limparTodosOsDados();
    disciplinaSelecionadaId = null;
    ciclosConcluidosHoje = 0;
    await carregarDados();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}