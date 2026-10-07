import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uni_cronos/app/app.dart';
import 'package:uni_cronos/app/app_providers.dart';
import 'package:uni_cronos/app/app_router.dart';
import 'package:uni_cronos/features/auth/data/auth_gateway.dart';
import 'package:uni_cronos/features/auth/domain/session.dart';
import 'package:uni_cronos/features/auth/domain/sign_up_data.dart';
import 'package:uni_cronos/features/hours/data/hours_repository.dart';
import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/notifications/data/notifications_preference.dart';
import 'package:uni_cronos/core/utils/link_opener.dart';
import 'package:uni_cronos/features/opportunities/data/opportunity_repository.dart';
import 'package:uni_cronos/features/opportunities/domain/opportunity.dart';
import 'package:uni_cronos/features/profile/data/profile_repository.dart';
import 'package:uni_cronos/features/profile/domain/student_profile.dart';
import 'package:uni_cronos/features/upload/data/certificate_launcher.dart';
import 'package:uni_cronos/features/upload/data/certificate_picker.dart';
import 'package:uni_cronos/features/upload/domain/picked_file.dart';

/// An in-memory notifications preference that records every write and can be
/// told to fail them.
class FakeNotificationsPreference implements NotificationsPreference {
  FakeNotificationsPreference({this.enabled = true, this.failWrites = false});

  bool enabled;
  bool failWrites;
  final writes = <bool>[];

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled(bool value) async {
    writes.add(value);
    if (failWrites) throw Exception('write failed');
    enabled = value;
  }
}

/// The fictitious student every signed-in test uses.
const demoSession = Session(
  userId: 'user-ana',
  email: 'ana.souza@alunos.utfpr.edu.br',
  institutionId: 'utfpr',
);

/// The password of [demoSession] in [FakeAuthGateway].
const demoPassword = 'senha-certa';

/// An account server in memory: it knows [demoSession], can be told to be
/// offline, and records every sign-up.
class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({Session? signedIn}) : _current = signedIn;

  Session? _current;
  bool offline = false;
  final signUps = <SignUpData>[];
  final _accounts = <String, (String, Session)>{
    demoSession.email: (demoPassword, demoSession),
  };
  final _changes = StreamController<Session?>.broadcast();

  /// Pretends the session expired on the server and could not be renewed.
  void expire() {
    _current = null;
    _changes.add(null);
  }

  @override
  Session? get current => _current;

  @override
  Stream<Session?> changes() => _changes.stream;

  @override
  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    if (offline) throw const NetworkFailure();
    final account = _accounts[email];
    if (account == null || account.$1 != password) {
      throw const InvalidCredentials();
    }
    return _signedIn(account.$2);
  }

  @override
  Future<Session> signUp(SignUpData data) async {
    if (offline) throw const NetworkFailure();
    if (_accounts.containsKey(data.email)) {
      throw const EmailAlreadyRegistered();
    }
    signUps.add(data);
    final session = Session(
      userId: 'user-${signUps.length}',
      email: data.email,
      institutionId: data.institutionId,
    );
    _accounts[data.email] = (data.password, session);
    return _signedIn(session);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _changes.add(null);
  }

  Session _signedIn(Session session) {
    _current = session;
    _changes.add(session);
    return session;
  }
}

/// The approved certificates of [demoSession]: 130 complementary and 45
/// extension hours, the three most recent first.
List<ApprovedCertificate> demoCertificates() => [
  ApprovedCertificate(
    id: 'community-tech-workshop',
    title: 'Workshop de Tecnologia Comunitária',
    category: HourCategory.extension,
    hours: 15,
    approvedAt: DateTime(2026, 9, 20),
  ),
  ApprovedCertificate(
    id: 'advanced-python-seminar',
    title: 'Seminário Avançado de Python',
    category: HourCategory.complementary,
    hours: 8,
    approvedAt: DateTime(2026, 9, 12),
  ),
  ApprovedCertificate(
    id: 'university-game-jam-2024',
    title: 'University Game Jam 2024',
    category: HourCategory.complementary,
    hours: 24,
    approvedAt: DateTime(2026, 8, 30),
  ),
  ApprovedCertificate(
    id: 'calculus-tutoring',
    title: 'Monitoria de Cálculo',
    category: HourCategory.complementary,
    hours: 98,
    approvedAt: DateTime(2026, 3, 1),
  ),
  ApprovedCertificate(
    id: 'open-school-extension',
    title: 'Projeto de Extensão Escola Aberta',
    category: HourCategory.extension,
    hours: 30,
    approvedAt: DateTime(2026, 2, 1),
  ),
];

/// Hours in memory: loads [certificates] on every refresh, can be told to
/// fail the loads, and takes new certificates with [add].
class FakeHoursRepository implements HoursRepository {
  FakeHoursRepository([List<ApprovedCertificate>? certificates])
    : certificates = [...?certificates];

  final List<ApprovedCertificate> certificates;
  bool failLoads = false;
  int refreshes = 0;
  final _subject = BehaviorSubject<HoursSnapshot>();

  @override
  Stream<HoursSnapshot> watch() => _subject.stream;

  @override
  Future<void> refresh() async {
    refreshes++;
    if (failLoads) {
      _subject.addError(const HoursLoadFailure());
      return;
    }
    _subject.add(HoursSnapshot.fromCertificates(certificates));
  }

  /// A certificate approved on the server, as the next load would bring it.
  Future<void> add(ApprovedCertificate certificate) async {
    certificates.add(certificate);
    _subject.add(HoursSnapshot.fromCertificates(certificates));
  }

  @override
  void dispose() => _subject.close();
}

/// A file of [sizeBytes] named [name]; a PDF by its first bytes unless
/// [pdf] is false.
PickedFile pickedFile(String name, int sizeBytes, {bool pdf = true}) {
  final bytes = Uint8List(sizeBytes);
  if (pdf) bytes.setRange(0, 5, '%PDF-'.codeUnits);
  return PickedFile(name: name, sizeBytes: sizeBytes, bytes: bytes);
}

/// A file chooser that hands over [next], and counts how often it opened.
class FakeCertificatePicker implements CertificatePicker {
  FakeCertificatePicker([this.next]);

  PickedFile? next;
  int picks = 0;

  @override
  Future<PickedFile?> pick() async {
    picks++;
    return next;
  }
}

/// A reader in memory: answers [result], or throws [failure]; [gate], when
/// set, holds the answer until completed. Records every call.
class FakeCertificateLauncher implements CertificateLauncher {
  LaunchedCertificate result = const LaunchedCertificate(
    title: 'Certificado Game Jam',
    category: HourCategory.complementary,
    hours: 10,
  );
  LaunchFailure? failure;
  LaunchFailure? manualFailure;
  Completer<void>? gate;
  final launched = <PickedFile>[];
  final manual = <(String, String, HourCategory, int)>[];
  final discarded = <String>[];

  @override
  Future<LaunchedCertificate> launch(PickedFile file) async {
    launched.add(file);
    await gate?.future;
    if (failure case final failure?) throw failure;
    return result;
  }

  @override
  Future<LaunchedCertificate> launchManual(
    UnreadableCertificate pending, {
    required String title,
    required HourCategory category,
    required int hours,
  }) async {
    manual.add((pending.path, title, category, hours));
    if (manualFailure case final failure?) throw failure;
    return LaunchedCertificate(title: title, category: category, hours: hours);
  }

  @override
  Future<void> discard(UnreadableCertificate pending) async {
    discarded.add(pending.path);
  }
}

/// The six example opportunities of the catalog.
List<Opportunity> demoOpportunities() => [
  Opportunity(
    id: 'maratona',
    kind: OpportunityKind.event,
    category: HourCategory.complementary,
    title: 'Maratona de Programação',
    description: 'Resolva problemas de algoritmos em equipe.',
    provider: 'Clube de Programação (exemplo)',
    modality: Modality.hibrido,
    hours: 10,
    startsAt: DateTime(2026, 11, 15),
    url: Uri.parse('https://example.com/maratona'),
  ),
  Opportunity(
    id: 'python',
    kind: OpportunityKind.course,
    category: HourCategory.complementary,
    title: 'Introdução ao Python para Dados',
    description: 'Análise de dados do zero aos gráficos.',
    provider: 'Escola Aberta de Dados (exemplo)',
    modality: Modality.online,
    hours: 40,
    startsAt: DateTime(2026, 10, 20),
    url: Uri.parse('https://example.com/python-dados'),
  ),
  Opportunity(
    id: 'horta',
    kind: OpportunityKind.event,
    category: HourCategory.extension,
    title: 'Projeto de Extensão Horta Comunitária',
    description: 'Plantio, colheita e compostagem na horta do bairro.',
    provider: 'Núcleo de Extensão (exemplo)',
    modality: Modality.presencial,
    hours: 30,
    startsAt: DateTime(2026, 10, 25),
  ),
  Opportunity(
    id: 'robotica',
    kind: OpportunityKind.course,
    category: HourCategory.extension,
    title: 'Oficina de Robótica nas Escolas',
    description: 'Robótica básica para alunos do ensino fundamental.',
    provider: 'Núcleo de Extensão (exemplo)',
    modality: Modality.presencial,
    hours: 16,
    startsAt: DateTime(2026, 11, 3),
    url: Uri.parse('https://example.com/robotica'),
  ),
  Opportunity(
    id: 'semana',
    kind: OpportunityKind.event,
    category: HourCategory.complementary,
    title: 'Semana Acadêmica de Computação',
    description: 'Palestras, minicursos e uma feira de projetos.',
    provider: 'Centro Acadêmico (exemplo)',
    modality: Modality.presencial,
    hours: 20,
    startsAt: DateTime(2026, 11, 9),
    url: Uri.parse('https://example.com/semana-academica'),
    featured: true,
  ),
  Opportunity(
    id: 'mentoria',
    kind: OpportunityKind.course,
    category: HourCategory.extension,
    title: 'Mentoria de Tecnologia Comunitária',
    description: 'Ensine programação básica uma vez por semana.',
    provider: 'Comunidade Tech (exemplo)',
    modality: Modality.online,
    hours: 24,
    startsAt: DateTime(2026, 10, 30),
    url: Uri.parse('https://example.com/mentoria'),
  ),
];

/// A catalog in memory that can be told to fail its loads.
class FakeOpportunityRepository implements OpportunityRepository {
  FakeOpportunityRepository([List<Opportunity>? opportunities])
    : opportunities = opportunities ?? demoOpportunities();

  List<Opportunity> opportunities;
  bool fail = false;
  int loads = 0;

  @override
  Future<List<Opportunity>> list() async {
    loads++;
    if (fail) throw const OpportunityLoadFailure();
    return opportunities;
  }
}

/// The profile of [demoSession].
const demoProfile = StudentProfile(
  fullName: 'Ana Souza',
  email: 'ana.souza@alunos.utfpr.edu.br',
  institutionId: 'utfpr',
  course: 'Engenharia de Software',
  term: 5,
);

/// A profile in memory that can be told to fail its loads.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository([this.profile = demoProfile]);

  StudentProfile profile;
  bool fail = false;

  @override
  Future<StudentProfile> current() async {
    if (fail) throw const ProfileLoadFailure();
    return profile;
  }
}

/// Records the links the app opens.
class FakeLinkOpener implements LinkOpener {
  final opened = <Uri>[];

  @override
  Future<void> open(Uri url) async => opened.add(url);
}

/// Pumps the real app — splash, router and shell — with [prefs] stored and
/// no splash wait, and settles on the first screen after the splash. Signed
/// in as [demoSession] unless [signedIn] is false or [auth] says otherwise.
Future<void> pumpRoutedApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  NotificationsPreference? notifications,
  bool signedIn = true,
  FakeAuthGateway? auth,
  HoursRepository? hoursRepository,
  CertificatePicker? picker,
  CertificateLauncher? launcher,
  OpportunityRepository? opportunities,
  ProfileRepository? profile,
  LinkOpener? links,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  PackageInfo.setMockInitialValues(
    appName: 'Uni Cronos',
    packageName: 'uni_cronos',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await tester.pumpWidget(
    AppProviders(
      authGateway:
          auth ?? FakeAuthGateway(signedIn: signedIn ? demoSession : null),
      hoursRepository:
          hoursRepository ?? FakeHoursRepository(demoCertificates()),
      certificatePicker: picker ?? FakeCertificatePicker(),
      certificateLauncher: launcher ?? FakeCertificateLauncher(),
      opportunityRepository: opportunities ?? FakeOpportunityRepository(),
      profileRepository: profile ?? FakeProfileRepository(),
      linkOpener: links ?? FakeLinkOpener(),
      notificationsPreference: notifications ?? FakeNotificationsPreference(),
      child: const MyApp(
        enforceUpgradeGate: false,
        splashDuration: Duration.zero,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The path the router is on.
String currentPath() => GoRouter.of(
  AppRouter.navigatorKey.currentContext!,
).routerDelegate.currentConfiguration.uri.path;

/// A label of the bottom navigation bar.
Finder navLabel(String text) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(text));
