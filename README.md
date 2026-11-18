<div align="center">

# StudySpace

**Ambiente mobile de foco profundo, gestao academica por disciplina e mixagem sonora multicanal para estudantes.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-15221F?style=for-the-badge&logo=flutter&logoColor=E5A06D)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-15221F?style=for-the-badge&logo=dart&logoColor=E5A06D)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-Offline_First-15221F?style=for-the-badge&logo=sqlite&logoColor=E5A06D)](https://www.sqlite.org)
[![Google Play](https://img.shields.io/badge/Google_Play-Ready-15221F?style=for-the-badge&logo=googleplay&logoColor=E5A06D)](https://play.google.com)

</div>

---

## O Problema & A Solucao

Estudantes frequentemente alternam entre multiplos aplicativos desconexos durante a rotina de estudos — um cronometro generico, outro player para ruidos ambientes e planilhas ou notas soltas para controlar entregas e carga horaria por materia.

O **StudySpace** unifica toda a jornada de concentracao em uma interface editorial calma e livre de distracoes:

1. **Espaco de Foco (Timer Pomodoro):** Ciclos configurados de concentracao (`25 min`) e descanso (`5 min`) com progresso circular animado e vinculacao direta a disciplina estudada no momento.
2. **Radio de Foco & Mix de Ambiente:** Reprodutor Lofi integrado a um misturador multicanal simultaneo (*Chuva suave*, *Cafe distante* e *Brisa nas folhas*) com controle independente de volume.
3. **Organizacao Academica & Metricas:** Acompanhamento automatico de horas acumuladas por materia, lista interativa de proximas entregas e painel consolidado de desempenho.

---

## Arquitetura & Design System

Desenvolvido em **Flutter (Dart)** com arquitetura reativa baseada em `Provider` e persistencia hibrida **Offline-First** (SQLite nativo via `sqflite` no Android/iOS e fallback local no navegador).

- **Identidade Visual:** Paleta *warm paper* (`#EEEAE1`), superficie de foco verde-petroleo (`#15221F`) e acentos em terracota (`#E5A06D`), combinando tipografia serifada (**Playfair Display**) com display monoespacado (**DM Mono**).
- **Conformidade Google Play Store:** Estrutura preparada para publicacao em App Bundle (`.aab`), operacao 100% funcional offline e controle nativo de privacidade com exclusao completa dos dados locais pelo usuario.

---

## Estrutura do Projeto

```text
studyspace/
├── lib/
│   ├── main.dart             # Ponto de entrada, navegacao e telas principais
│   ├── app_theme.dart        # Design System, paleta de cores e tipografia
│   ├── study_provider.dart   # Gerenciamento de estado do timer e disciplinas
│   ├── audio_mixer.dart      # Controle de reproducao multicanal (just_audio)
│   └── database_helper.dart  # Camada de persistencia local (SQLite / Web)
└── pubspec.yaml              # Dependencias e configuracoes do pacote
