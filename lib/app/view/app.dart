import 'package:appsize/appsize.dart';
import 'package:client/client.dart';
import 'package:data_persistence/data_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router_flow/go_router_flow.dart';
import 'package:weappear/app/models/logged_in_stream.dart';
import 'package:weappear/auth/view/finish_register_page.dart';
import 'package:weappear/auth/view/login_page.dart';
import 'package:weappear/auth/view/register_page.dart';
import 'package:weappear/home/view/home_page.dart';
import 'package:weappear/onboarding/view/onboarding_page.dart';
import 'package:weappear_localizations/weappear_localizations.dart';
import 'package:weappear_ui/weappear_ui.dart';

class App extends StatelessWidget {
  const App({
    required Client client,
    required DataPersistenceRepository dataPersistenceRepository,
    super.key,
  })  : _client = client,
        _dataPersistenceRepository = dataPersistenceRepository;

  final Client _client;
  final DataPersistenceRepository _dataPersistenceRepository;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: const Color(0xffF1F1F1),
      ),
    );
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _client),
        RepositoryProvider.value(value: _dataPersistenceRepository),
      ],
      child: AppSize.child(
        child: const ViewApp(),
      ),
    );
  }
}

class ViewApp extends StatefulWidget {
  const ViewApp({super.key});

  @override
  State<ViewApp> createState() => _ViewAppState();
}

class _ViewAppState extends State<ViewApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WeAppearUi.initUI();
    _router = router(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: WeAppearTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerDelegate: _router.routerDelegate,
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
    );
  }

  GoRouter router(BuildContext context) {
    final dataPersistenceRepository = context.read<DataPersistenceRepository>();

    return GoRouter(
      refreshListenable: LoggedInStream(dataPersistenceRepository.isLoggedInStream),
      debugLogDiagnostics: true,
      initialLocation: '/home',
      routes: <GoRoute>[
        GoRoute(
          path: '/login',
          name: PageLogin.name,
          builder: (_, state) {
            final registeredSuccessfully = state.extra as bool?;

            return PageLogin(
              key: state.pageKey,
              registerSuccessful: registeredSuccessfully ?? false,
            );
          },
        ),
        GoRoute(
          path: '/register',
          name: PageRegister.name,
          builder: (_, state) => PageRegister(key: state.pageKey),
        ),
        GoRoute(
          path: '/finish-register',
          name: PageFinishRegister.name,
          builder: (_, state) {
            final extra = state.extra as Map?;
            final activationId = extra?['activationId'] as String?;
            final email = extra?['email'] as String?;

            if (activationId == null || activationId.isEmpty) {
              throw Exception('Activation ID is null');
            }

            if (email == null || email.isEmpty) {
              throw Exception('Email is null');
            }

            return PageFinishRegister(
              key: state.pageKey,
              activationId: activationId,
              email: email,
            );
          },
        ),
        GoRoute(
          path: '/onboarding',
          name: PageOnboarding.name,
          builder: (_, state) => PageOnboarding(key: state.pageKey),
        ),
        GoRoute(
          path: '/home',
          name: PageHome.name,
          builder: (_, state) => PageHome(key: state.pageKey),
        ),
      ],
      redirect: (context, state) {
        final unauthenticatedPermittedRoutes = [
          '/onboarding',
        ];

        final homePath = PageLogin.name;

        final loggedIn = dataPersistenceRepository.isLoggedIn;
        final loggingIn = unauthenticatedPermittedRoutes.any(state.location.startsWith);

        if (loggedIn && !loggingIn) {
          return homePath;
        }

        return null;
      },
    );
  }
}
