// tool/update_config.dart
// Envia o firebase_remote_config_template.json para o Firebase Console
//
// Uso:
//   dart run tool/update_config.dart
//
// Pré-requisitos:
//   - firebase CLI instalado e logado (firebase login)
//   - firebase_remote_config_template.json na raiz do projeto

import 'dart:io';

const _templateFile = 'firebase_remote_config_template.json';
const _firebaseRcFile = '.firebaserc';

Future<void> main(List<String> args) async {
  print('');
  print('⚙️  Remote Config Updater — uni_cronos');
  print('─' * 45);
  print('');

  // ── 1. Verifica se o template existe ─────────────────────────
  if (!File(_templateFile).existsSync()) {
    _err('Arquivo "$_templateFile" não encontrado na raiz do projeto.');
    exit(1);
  }
  print('✅ Template encontrado: $_templateFile');

  // ── 2. Obtém o Project ID ─────────────────────────────────────
  final projectId = await _resolveProjectId(args);
  if (projectId == null) {
    _err('Não foi possível determinar o Firebase Project ID.');
    _err('');
    _err('Opções:');
    _err('  1. Crie um .firebaserc na raiz com:');
    _err('     { "projects": { "default": "seu-project-id" } }');
    _err('');
    _err('  2. Passe o project ID diretamente:');
    _err('     dart run tool/update_config.dart --project=seu-project-id');
    exit(1);
  }
  print('✅ Projeto Firebase: $projectId');

  // ── 3. Verifica se o firebase CLI está disponível ─────────────
  final whichCmd = Platform.isWindows ? 'where' : 'which';
  final whichResult = await Process.run(whichCmd, [
    'firebase',
  ], runInShell: true);
  if (whichResult.exitCode != 0) {
    _err('Firebase CLI não encontrado.');
    _err('Instale com: npm install -g firebase-tools');
    exit(1);
  }

  // ── 4. Envia o Remote Config ──────────────────────────────────
  print('');
  print('📤 Enviando Remote Config para o projeto "$projectId"...');
  print('');

  // firebase deploy --only remoteconfig espera o arquivo como remoteconfig.json
  final deployFile = File('remoteconfig.json');
  File(_templateFile).copySync(deployFile.path);

  final result = await Process.run('firebase', [
    'deploy',
    '--only',
    'remoteconfig',
    '--project=$projectId',
  ], runInShell: true);

  if (deployFile.existsSync()) deployFile.deleteSync();

  if (result.exitCode != 0) {
    _err('Falha ao enviar Remote Config.');
    _err('');
    _err('── DEBUG ──────────────────────────────');
    _err('  exit code: ${result.exitCode}');
    if ((result.stdout as String).trim().isNotEmpty)
      _err('  stdout: ${(result.stdout as String).trim()}');
    if ((result.stderr as String).trim().isNotEmpty)
      _err('  stderr: ${(result.stderr as String).trim()}');
    _err('───────────────────────────────────────');
    exit(1);
  }

  print('');
  print('─' * 45);
  print('✅ Remote Config atualizado com sucesso!');
  print('');
  print('   🔗 Verifique em:');
  print('   https://console.firebase.google.com/project/$projectId/config');
  print('');
}

/// Tenta resolver o Project ID na seguinte ordem:
/// 1. Argumento --project=ID passado na linha de comando
/// 2. .firebaserc na raiz do projeto
Future<String?> _resolveProjectId(List<String> args) async {
  // 1. --project= nos argumentos do script
  for (final arg in args) {
    if (arg.startsWith('--project=')) {
      return arg.replaceFirst('--project=', '');
    }
  }

  // 2. .firebaserc
  final firebaseRc = File(_firebaseRcFile);
  if (firebaseRc.existsSync()) {
    try {
      final content = firebaseRc.readAsStringSync();
      // Extrai o project ID do JSON sem depender de dart:convert
      final match = RegExp(r'"default"\s*:\s*"([^"]+)"').firstMatch(content);
      if (match != null) return match.group(1);
    } catch (_) {}
  }

  return null;
}

void _err(String msg) => stderr.writeln('❌ $msg');
