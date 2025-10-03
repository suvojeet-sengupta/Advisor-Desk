import 'package:advisor_desk/core/utils/rate_app_helper.dart';
import 'package:flutter/services.dart';

import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:advisor_desk/data/datasources/goal_data_source.dart';
import 'package:advisor_desk/data/repositories/goal_repository_impl.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';
import 'package:advisor_desk/domain/usecases/delete_cq_entries_by_date_usecase.dart';
import 'package:advisor_desk/domain/usecases/delete_csat_entries_by_date_usecase.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_bloc.dart';
import 'package:advisor_desk/core/utils/widget_updater_service.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:advisor_desk/data/datasources/usage_tracking_service.dart'; // Import the new service
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
import 'package:advisor_desk/domain/services/goal_prediction_service.dart'; // Import GoalPredictionService
import 'package:advisor_desk/presentation/common/widgets/disable_ad_blocker_dialog.dart';

// Custom ScrollBehavior for smoother scrolling
class SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InAppReviewHelper.setInstallDate();
  MobileAds.instance.initialize();
  await AppConstants.init();
  
  // Increment app launch count
  final usageTrackingService = UsageTrackingService();
  await usageTrackingService.incrementLaunchCount();
  
  final adService = AdService()..loadAd();
  final localDataSource = await LocalDataSource.init();
  final goalDataSource = GoalDataSource();
  
  final performanceRepository = PerformanceRepositoryImpl(localDataSource: localDataSource);
  final goalRepository = GoalRepositoryImpl(goalDataSource);
  final deleteCQEntriesByDateUseCase = DeleteCQEntriesByDateUseCase(performanceRepository);
  final deleteCSATEntriesByDateUseCase = DeleteCSATEntriesByDateUseCase(performanceRepository);

  final leaveRepository = LeaveRepositoryImpl(localDataSource: localDataSource);

  

  final prefs = await SharedPreferences.getInstance();
  final hasAcceptedPrivacy = prefs.getBool('hasAcceptedPrivacyPolicy') ?? false;
  final hasShownOnboarding = prefs.getBool('hasShownOnboarding') ?? false;

  // Instantiate Profile related services
  final profileDataSource = ProfileDataSource();
  final profileRepository = ProfileRepositoryImpl(profileDataSource);
  // Load profile to determine if it's filled
  final initialProfile = await profileRepository.getProfile();
  final bool isProfileFilled = initialProfile.name != null && initialProfile.companyName != null; // Assuming both are required
  await prefs.setBool('isProfileFilled', isProfileFilled); // Save for privacy screen to know

  String initialRoute;
  if (!hasAcceptedPrivacy) {
    initialRoute = AppRouter.privacyPolicyRoute;
  } else if (!hasShownOnboarding) {
    initialRoute = AppRouter.onboardingTutorialRoute;
    await prefs.setBool('hasShownOnboarding', true);
  } else if (!isProfileFilled) { // If onboarding is done but profile not filled
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
    profileRepository: profileRepository, // Pass profileRepository to MyApp
    leaveRepository: leaveRepository,
  ));
}

class MyApp extends StatefulWidget {
  final AdService adService;
  final PerformanceRepository performanceRepository;
  final GoalRepository goalRepository;
  final DeleteCQEntriesByDateUseCase deleteCQEntriesByDateUseCase;
  final DeleteCSATEntriesByDateUseCase deleteCSATEntriesByDateUseCase;
  
  final String initialRoute;
  final ProfileRepository profileRepository; // New
  final LeaveRepository leaveRepository;

  const MyApp({
    Key? key,
    required this.adService,
    required this.performanceRepository,
    required this.goalRepository,
    required this.deleteCQEntriesByDateUseCase,
    required this.deleteCSATEntriesByDateUseCase,
    
    required this.initialRoute,
    required this.profileRepository, // New
    required this.leaveRepository,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ValueNotifier<bool> isLocked = ValueNotifier(false);
  bool _justUnlocked = false;
  static const _shortcutChannel = MethodChannel('com.suvojeet.advisordesk/shortcuts');
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLockState();
    checkForUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _checkAdBlocker(context);
       _handleShortcuts();
    });
  }

  Future<void> _handleShortcuts() async {
    try {
      final String? action = await _shortcutChannel.invokeMethod('getShortcutAction');
      if (action != null) {
        _navigateToShortcut(action);
      }
    } on PlatformException catch (e) {
      print("Failed to get shortcut action: '${e.message}'.");
    }

    _shortcutChannel.setMethodCallHandler((call) async {
      if (call.method == 'newShortcutAction') {
        final String action = call.arguments;
        _navigateToShortcut(action);
      }
    });
  }

  void _navigateToShortcut(String action) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    switch (action) {
      case 'com.suvojeet.advisordesk.ADD_ENTRY':
        navigator.pushNamed(AppRouter.addEntryRoute, arguments: {'initial_tab': 0});
        break;
      case 'com.suvojeet.advisordesk.ADD_CSAT':
        navigator.pushNamed(AppRouter.addEntryRoute, arguments: {'initial_tab': 1});
        break;
      case 'com.suvojeet.advisordesk.ADD_CQ':
        navigator.pushNamed(AppRouter.addEntryRoute, arguments: {'initial_tab': 2});
        break;
      case 'android.intent.action.VIEW':
        navigator.popUntil((route) => route.isFirst);
        break;
    }
  }

  Future<void> _checkAdBlocker(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckString = prefs.getString('lastAdBlockerCheck');
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day).toIso8601String();

    if (lastCheckString != todayDate) {
      final adBlockerService = AdBlockerService();
      final isAdBlockerActive = await adBlockerService.isAdBlockerActive();
      if (isAdBlockerActive && context.mounted) {
        showDisableAdBlockerDialog(context);
        await prefs.setString('lastAdBlockerCheck', todayDate);
      }
    }
  }

  Future<void> _initializeLockState() async {
    final isEnabled = await AuthenticationService.isAppLockEnabled();
    if (isEnabled) {
      final isRequired = await AuthenticationService.isAuthenticationRequired();
      if (isRequired) {
        isLocked.value = true;
      }
    }
  }

  

  Future<void> checkForUpdate() async {
    try {
      AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();

      if (appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (appUpdateInfo.flexibleUpdateAllowed) {
          // Start a flexible update
          await InAppUpdate.startFlexibleUpdate();
          // Listen for the update to be downloaded
          InAppUpdate.installUpdateListener.listen((status) {
            if (status == InstallStatus.downloaded) {
              // When the update is downloaded, complete it
              InAppUpdate.completeFlexibleUpdate();
            }
          });
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isLocked.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Check for app updates on resume
      InAppUpdate.checkForUpdate().then((info) {
        if (info.installStatus == InstallStatus.downloaded) {
          InAppUpdate.completeFlexibleUpdate();
        }
      }).catchError((e) {
        print('Failed to check for update on resume: $e');
      });

      // Check for app lock on resume
      if (_justUnlocked) {
        _justUnlocked = false;
      } else {
        _initializeLockState();
      }
    } else if (state == AppLifecycleState.paused) {
      if (isLocked.value == false) {
        AuthenticationService.updateLastAuthenticationTime();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

        // Main App UI
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AdService>.value(value: widget.adService),
            RepositoryProvider<PerformanceRepository>.value(value: widget.performanceRepository),
            RepositoryProvider<GoalRepository>.value(value: widget.goalRepository),
            RepositoryProvider<DeleteCQEntriesByDateUseCase>.value(value: widget.deleteCQEntriesByDateUseCase),
            RepositoryProvider<DeleteCSATEntriesByDateUseCase>.value(value: widget.deleteCSATEntriesByDateUseCase),
            RepositoryProvider<ProfileRepository>.value(value: widget.profileRepository),
            RepositoryProvider<LeaveRepository>.value(value: widget.leaveRepository),
            RepositoryProvider<AiInsightService>(create: (context) => AiInsightService()),
            RepositoryProvider<NlpService>(create: (context) => NlpService(performanceRepository: context.read<PerformanceRepository>())),
            RepositoryProvider<GoalPredictionService>(create: (context) => GoalPredictionServiceImpl()),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => ThemeCubit()),
              BlocProvider(create: (context) => DashboardCustomizationCubit()),
              BlocProvider(create: (context) => ProfileCubit(context.read<ProfileRepository>())), // New
            ],
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return DynamicColorBuilder(
                  builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                    ThemeData lightTheme;
                    ThemeData darkTheme;

                    if (themeState.color == AppColor.materialYou && lightDynamic != null && darkDynamic != null) {
                      // Use dynamic colors for both light and dark themes
                      lightTheme = AppTheme.getLightTheme(lightDynamic);
                      darkTheme = AppTheme.getDarkTheme(darkDynamic);
                    } else {
                      // Use the selected predefined color for both light and dark themes
                      lightTheme = AppTheme.getTheme(AppThemeMode.light, themeState.color);
                      darkTheme = AppTheme.getTheme(AppThemeMode.dark, themeState.color);
                    }

                    return MaterialApp(
                      navigatorKey: _navigatorKey,
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
