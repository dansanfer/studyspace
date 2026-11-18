import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('studyspace.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE disciplinas (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL, cor TEXT NOT NULL, meta_minutos INTEGER NOT NULL, minutos_estudados INTEGER NOT NULL DEFAULT 0)',
    );
    await db.execute(
      'CREATE TABLE tarefas (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT NOT NULL, disciplina_nome TEXT NOT NULL, prazo TEXT NOT NULL, concluida INTEGER NOT NULL DEFAULT 0)',
    );
    await db.execute(
      'CREATE TABLE sessoes_pomodoro (id INTEGER PRIMARY KEY AUTOINCREMENT, disciplina_id INTEGER NOT NULL, minutos INTEGER NOT NULL, data_conclusao TEXT NOT NULL)',
    );
  }

  Future<int> inserirDisciplina(String nome, String cor, int metaHoras) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final lista = await listarDisciplinas();
      final novoId = DateTime.now().millisecondsSinceEpoch;
      lista.insert(0, {
        'id': novoId,
        'nome': nome,
        'cor': cor,
        'meta_minutos': metaHoras * 60,
        'minutos_estudados': 0,
      });
      await prefs.setString('web_disciplinas', jsonEncode(lista));
      return novoId;
    }
    final db = await instance.database;
    return await db.insert('disciplinas', {
      'nome': nome,
      'cor': cor,
      'meta_minutos': metaHoras * 60,
      'minutos_estudados': 0,
    });
  }

  Future<List> listarDisciplinas() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('web_disciplinas');
      if (raw == null) return [];
      return jsonDecode(raw) as List;
    }
    final db = await instance.database;
    return await db.query('disciplinas', orderBy: 'id DESC');
  }

  Future<void> somarMinutosEstudados(int disciplinaId, int minutos) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final lista = await listarDisciplinas();
      for (final d in lista) {
        if (d['id'] == disciplinaId) {
          d['minutos_estudados'] = (d['minutos_estudados'] as int) + minutos;
        }
      }
      await prefs.setString('web_disciplinas', jsonEncode(lista));
      return;
    }
    final db = await instance.database;
    await db.rawUpdate(
      'UPDATE disciplinas SET minutos_estudados = minutos_estudados + ? WHERE id = ?',
      [minutos, disciplinaId],
    );
    await db.insert('sessoes_pomodoro', {
      'disciplina_id': disciplinaId,
      'minutos': minutos,
      'data_conclusao': DateTime.now().toIso8601String(),
    });
  }

  Future<int> inserirTarefa(
      String titulo, String disciplinaNome, String prazo) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final lista = await listarTarefas();
      final novoId = DateTime.now().millisecondsSinceEpoch;
      lista.insert(0, {
        'id': novoId,
        'titulo': titulo,
        'disciplina_nome': disciplinaNome,
        'prazo': prazo,
        'concluida': 0,
      });
      await prefs.setString('web_tarefas', jsonEncode(lista));
      return novoId;
    }
    final db = await instance.database;
    return await db.insert('tarefas', {
      'titulo': titulo,
      'disciplina_nome': disciplinaNome,
      'prazo': prazo,
      'concluida': 0,
    });
  }

  Future<List> listarTarefas() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('web_tarefas');
      if (raw == null) return [];
      return jsonDecode(raw) as List;
    }
    final db = await instance.database;
    return await db.query('tarefas', orderBy: 'concluida ASC, id DESC');
  }

  Future<void> alternarTarefaConcluida(int id, bool concluida) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final lista = await listarTarefas();
      for (final t in lista) {
        if (t['id'] == id) {
          t['concluida'] = concluida ? 1 : 0;
        }
      }
      await prefs.setString('web_tarefas', jsonEncode(lista));
      return;
    }
    final db = await instance.database;
    await db.update(
      'tarefas',
      {'concluida': concluida ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> limparTodosOsDados() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('web_disciplinas');
      await prefs.remove('web_tarefas');
      return;
    }
    final db = await instance.database;
    await db.delete('disciplinas');
    await db.delete('tarefas');
    await db.delete('sessoes_pomodoro');
  }
}