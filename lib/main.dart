import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:advisor_desk/data/datasources/goal_data_source.dart';
import 'package:advisor_desk/data/repositories/goal_repository_impl.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';
import 'package:advisor_desk/domain/usecases/delete_cq_entries_by_date_usecase.dart';
import 'package:advisor_desk/domain/usecases/delete_csat_entries_by_date_usecase.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/data/datasources/local_data_source.dart';
import 'package:advisor_desk/data/repositories/performance_repository_impl.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/presentation/common/theme/app_theme.dart';
import 'package:advisor_desk/presentation/common/theme/theme_cubit.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/presentation/features/dashboard/cubit/dashboard_customization_cubit.dart';
import 'package:in_app_update/in_app_update.dart'; // For in-app updates
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Custom ScrollBehavior for smoother scrolling
class SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await AppConstants.init();
  
  final adService = AdService()..loadAd();
  final localDataSource = await LocalDataSource.init();
  final goalDataSource = GoalDataSource();
  
  final performanceRepository = PerformanceRepositoryImpl(localDataSource: localDataSource);
  final goalRepository = GoalRepositoryImpl(goalDataSource);
  final deleteCQEntriesByDateUseCase = DeleteCQEntriesByDateUseCase(performanceRepository);
  final deleteCSATEntriesByDateUseCase = DeleteCSATEntriesByDateUseCase(performanceRepository);

  final prefs = await SharedPreferences.getInstance();
  final hasShownOnboarding = prefs.getBool('hasShownOnboarding') ?? false;

  String initialRoute = AppRouter.dashboardRoute;
  if (!hasShownOnboarding) {
    initialRoute = AppRouter.onboardingTutorialRoute;
    await prefs.setBool('hasShownOnboarding', true);
  }
  
  runApp(MyApp(
    adService: adService,
    performanceRepository: performanceRepository,
    goalRepository: goalRepository,
    deleteCQEntriesByDateUseCase: deleteCQEntriesByDateUseCase,
    deleteCSATEntriesByDateUseCase: deleteCSATEntriesByDateUseCase,
    initialRoute: initialRoute,
  ));
}

class MyApp extends StatefulWidget {
  final AdService adService;
  final PerformanceRepository performanceRepository;
  final GoalRepository goalRepository;
  final DeleteCQEntriesByDateUseCase deleteCQEntriesByDateUseCase;
  final DeleteCSATEntriesByDateUseCase deleteCSATEntriesByDateUseCase;
  final String initialRoute;
  
  const MyApp({
    Key? key,
    required this.adService,
    required this.performanceRepository,
    required this.goalRepository,
    required this.deleteCQEntriesByDateUseCase,
    required this.deleteCSATEntriesByDateUseCase,
    required this.initialRoute,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    try {
      AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();

      if (appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (appUpdateInfo.flexibleUpdateAllowed) {
          // Start a flexible update
          await InAppUpdate.startFlexibleUpdate();
          // When the flexible update is downloaded, prompt the user to complete it.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Update downloaded! Restart to apply.'),
              action: SnackBarAction(
                label: 'RESTART',
                onPressed: () async {
                  await InAppUpdate.completeFlexibleUpdate();
                },
              ),
            ),
          );
        } else if (appUpdateInfo.immediateUpdateAllowed) {
          // Perform an immediate update if flexible is not allowed
          await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (e) {
      print('Failed to check for update: $e');
      // Handle error, e.g., show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    // एक से ज़्यादा Repository और BLoC प्रोवाइड करें
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AdService>.value(value: widget.adService),
        RepositoryProvider<PerformanceRepository>.value(value: widget.performanceRepository),
        RepositoryProvider<GoalRepository>.value(value: widget.goalRepository),
        RepositoryProvider<DeleteCQEntriesByDateUseCase>.value(value: widget.deleteCQEntriesByDateUseCase),
        RepositoryProvider<DeleteCSATEntriesByDateUseCase>.value(value: widget.deleteCSATEntriesByDateUseCase),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(create: (context) => DashboardCustomizationCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: AppConstants.appName,
              theme: AppTheme.getTheme(Brightness.light, themeState.color),
              darkTheme: AppTheme.getTheme(Brightness.dark, themeState.color),
              themeMode: themeState.themeMode == AppThemeMode.system
                  ? ThemeMode.system
                  : themeState.themeMode == AppThemeMode.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              scrollBehavior: SmoothScrollBehavior(),
              onGenerateRoute: AppRouter.onGenerateRoute,
              initialRoute: widget.initialRoute,
            );
          },
        ),
      ),
    );
  }
}
