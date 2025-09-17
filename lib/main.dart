import 'package:advisor_desk/core/utils/rate_app_helper.dart';
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
import 'package:in_app_update/in_app_update.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:advisor_desk/data/datasources/usage_tracking_service.dart';
import 'package:advisor_desk/data/datasources/profile_data_source.dart';
import 'package:advisor_desk/data/repositories/profile_repository_impl.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';
import 'package:advisor_desk/presentation/features/profile/bloc/profile_cubit.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:advisor_desk/data/repositories/leave_repository_impl.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';
import 'package:advisor_desk/core/utils/authentication_service.dart';
import 'package:advisor_desk/presentation/screens/lock_screen.dart';
import 'package:advisor_desk/core/utils/ad_blocker_service.dart';
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'package:advisor_desk/domain/services/nlp_service.dart';
import 'package:advisor_desk/presentation/common/widgets/disable_ad_blocker_dialog.dart';

/// A custom [ScrollBehavior] for smoother, bouncing scroll physics across the app.
class SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

/// The main entry point of the application.
///
/// Initializes all necessary services, repositories, and settings before
/// running the app. It determines the initial route based on user state
/// (e.g., first launch, profile completion).
void main() async {
  // Ensure Flutter engine is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize helpers and services.
  await InAppReviewHelper.setInstallDate();
  MobileAds.instance.initialize();
  await AppConstants.init();

  // Track app launches.
  final usageTrackingService = UsageTrackingService();
  await usageTrackingService.incrementLaunchCount();

  // Initialize data sources and repositories.
  final adService = AdService()..loadAd();
  final localDataSource = await LocalDataSource.init();
  final goalDataSource = GoalDataSource();
  final performanceRepository =
      PerformanceRepositoryImpl(localDataSource: localDataSource);
  final goalRepository = GoalRepositoryImpl(goalDataSource);
  final deleteCQEntriesByDateUseCase =
      DeleteCQEntriesByDateUseCase(performanceRepository);
  final deleteCSATEntriesByDateUseCase =
      DeleteCSATEntriesByDateUseCase(performanceRepository);
  final leaveRepository = LeaveRepositoryImpl(localDataSource: localDataSource);
  final profileDataSource = ProfileDataSource();
  final profileRepository = ProfileRepositoryImpl(profileDataSource);

  // Determine the initial route based on user progress.
  final prefs = await SharedPreferences.getInstance();
  final hasShownOnboarding = prefs.getBool('hasShownOnboarding') ?? false;
  final initialProfile = await profileRepository.getProfile();
  final isProfileFilled =
      initialProfile.name != null && initialProfile.companyName != null;

  String initialRoute;
  if (!hasShownOnboarding) {
    initialRoute = AppRouter.onboardingTutorialRoute;
    await prefs.setBool('hasShownOnboarding', true);
  } else if (!isProfileFilled) {
    initialRoute = AppRouter.profileRoute;
  } else {
    initialRoute = AppRouter.dashboardRoute;
  }

  runApp(MyApp(
    adService: adService,
    performanceRepository: performanceRepository,
    goalRepository: goalRepository,
    deleteCQEntriesByDateUseCase: deleteCQEntriesByDateUseCase,
    deleteCSATEntriesByDateUseCase: deleteCSATEntriesByDateUseCase,
    initialRoute: initialRoute,
    profileRepository: profileRepository,
    leaveRepository: leaveRepository,
  ));
}

/// The root widget of the application.
class MyApp extends StatefulWidget {
  final AdService adService;
  final PerformanceRepository performanceRepository;
  final GoalRepository goalRepository;
  final DeleteCQEntriesByDateUseCase deleteCQEntriesByDateUseCase;
  final DeleteCSATEntriesByDateUseCase deleteCSATEntriesByDateUseCase;
  final String initialRoute;
  final ProfileRepository profileRepository;
  final LeaveRepository leaveRepository;

  const MyApp({
    super.key,
    required this.adService,
    required this.performanceRepository,
    required this.goalRepository,
    required this.deleteCQEntriesByDateUseCase,
    required this.deleteCSATEntriesByDateUseCase,
    required this.initialRoute,
    required this.profileRepository,
    required this.leaveRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ValueNotifier<bool> isLocked = ValueNotifier(false);
  bool _justUnlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLockState();
    checkForUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAdBlocker(context));
  }

  /// Checks if an ad blocker is active and shows a dialog if it is.
  /// This check is performed once per day.
  Future<void> _checkAdBlocker(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckString = prefs.getString('lastAdBlockerCheck');
    final today = DateTime.now();
    final todayDate =
        DateTime(today.year, today.month, today.day).toIso8601String();

    if (lastCheckString != todayDate) {
      final adBlockerService = AdBlockerService();
      final isAdBlockerActive = await adBlockerService.isAdBlockerActive();
      if (isAdBlockerActive && context.mounted) {
        showDisableAdBlockerDialog(context);
        await prefs.setString('lastAdBlockerCheck', todayDate);
      }
    }
  }

  /// Initializes the app lock state on startup.
  Future<void> _initializeLockState() async {
    final isEnabled = await AuthenticationService.isAppLockEnabled();
    if (isEnabled) {
      final isRequired = await AuthenticationService.isAuthenticationRequired();
      if (isRequired) {
        isLocked.value = true;
      }
    }
  }

  /// Checks for and initiates an in-app update if one is available.
  Future<void> checkForUpdate() async {
    try {
      AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();
      if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        if (appUpdateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          InAppUpdate.installUpdateListener.listen((status) {
            if (status == InstallStatus.downloaded) {
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        } else if (appUpdateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (e) {
      // Silently fail, as this is not a critical function.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isLocked.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // On resume, check for downloaded updates and re-evaluate lock state.
      InAppUpdate.checkForUpdate().then((info) {
        if (info.installStatus == InstallStatus.downloaded) {
          InAppUpdate.completeFlexibleUpdate();
        }
      }).catchError((e) {
        // Silently fail.
      });

      if (_justUnlocked) {
        _justUnlocked = false;
      } else {
        _initializeLockState();
      }
    } else if (state == AppLifecycleState.paused) {
      // When pausing, update the last authenticated time if the app is not locked.
      if (isLocked.value == false) {
        AuthenticationService.updateLastAuthenticationTime();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The ValueListenableBuilder switches between the LockScreen and the main app.
    return ValueListenableBuilder<bool>(
      valueListenable: isLocked,
      builder: (context, locked, _) {
        if (locked) {
          return MaterialApp(
            title: AppConstants.appName,
            home: LockScreen(onUnlocked: () {
              _justUnlocked = true;
              isLocked.value = false;
            }),
            debugShowCheckedModeBanner: false,
          );
        }

        // The main app UI, wrapped in providers.
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AdService>.value(value: widget.adService),
            RepositoryProvider<PerformanceRepository>.value(
                value: widget.performanceRepository),
            RepositoryProvider<GoalRepository>.value(value: widget.goalRepository),
            RepositoryProvider<DeleteCQEntriesByDateUseCase>.value(
                value: widget.deleteCQEntriesByDateUseCase),
            RepositoryProvider<DeleteCSATEntriesByDateUseCase>.value(
                value: widget.deleteCSATEntriesByDateUseCase),
            RepositoryProvider<ProfileRepository>.value(
                value: widget.profileRepository),
            RepositoryProvider<LeaveRepository>.value(
                value: widget.leaveRepository),
            RepositoryProvider<AiInsightService>(
                create: (context) => AiInsightService()),
            RepositoryProvider<NlpService>(
                create: (context) => NlpService(
                    performanceRepository: context.read<PerformanceRepository>())),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => ThemeCubit()),
              BlocProvider(create: (context) => DashboardCustomizationCubit()),
              BlocProvider(
                  create: (context) =>
                      ProfileCubit(context.read<ProfileRepository>())),
            ],
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return DynamicColorBuilder(
                  builder:
                      (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                    ThemeData lightTheme;
                    ThemeData darkTheme;

                    if (themeState.color == AppColor.materialYou &&
                        lightDynamic != null &&
                        darkDynamic != null) {
                      // Use dynamic colors from the system for Material You.
                      lightTheme = AppTheme.getLightTheme(lightDynamic);
                      darkTheme = AppTheme.getDarkTheme(darkDynamic);
                    } else {
                      // Use the selected predefined color.
                      lightTheme =
                          AppTheme.getTheme(AppThemeMode.light, themeState.color);
                      darkTheme =
                          AppTheme.getTheme(AppThemeMode.dark, themeState.color);
                    }

                    return MaterialApp(
                      title: AppConstants.appName,
                      theme: lightTheme,
                      darkTheme: darkTheme,
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
                );
              },
            ),
          ),
        );
      },
    );
  }
}
