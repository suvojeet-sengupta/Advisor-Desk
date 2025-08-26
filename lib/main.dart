import 'package:advisor_desk/data/datasources/notification_service.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:advisor_desk/data/datasources/usage_tracking_service.dart'; // Import the new service
import 'package:advisor_desk/data/datasources/profile_data_source.dart';
import 'package:advisor_desk/data/repositories/profile_repository_impl.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';
import 'package:advisor_desk/presentation/features/profile/bloc/profile_cubit.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:advisor_desk/data/repositories/leave_repository_impl.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';

// Custom ScrollBehavior for smoother scrolling
class SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return BouncingScrollPhysics();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  final notificationService = NotificationService(performanceRepository: performanceRepository);
  await notificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final hasShownOnboarding = prefs.getBool('hasShownOnboarding') ?? false;

  // Instantiate Profile related services
  final profileDataSource = ProfileDataSource();
  final profileRepository = ProfileRepositoryImpl(profileDataSource);
  // Load profile to determine if it's filled
  final initialProfile = await profileRepository.getProfile();
  final bool isProfileFilled = initialProfile.name != null && initialProfile.companyName != null; // Assuming both are required

  String initialRoute = AppRouter.dashboardRoute;
  if (!hasShownOnboarding) {
    initialRoute = AppRouter.onboardingTutorialRoute;
    await prefs.setBool('hasShownOnboarding', true);
  } else if (!isProfileFilled) { // If onboarding is done but profile not filled
    initialRoute = AppRouter.profileRoute;
  }
  
  runApp(MyApp(
    adService: adService,
    performanceRepository: performanceRepository,
    goalRepository: goalRepository,
    deleteCQEntriesByDateUseCase: deleteCQEntriesByDateUseCase,
    deleteCSATEntriesByDateUseCase: deleteCSATEntriesByDateUseCase,
    notificationService: notificationService,
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
  final NotificationService notificationService;
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
    required this.notificationService,
    required this.initialRoute,
    required this.profileRepository, // New
    required this.leaveRepository,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkForUpdate();
    _requestNotificationPermission();
    widget.notificationService.scheduleDailyReminders();
    widget.notificationService.cancelTodaysRemindersIfEntryExists();
  }

  Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      InAppUpdate.checkForUpdate().then((info) {
        if (info.installStatus == InstallStatus.downloaded) {
          InAppUpdate.completeFlexibleUpdate();
        }
      }).catchError((e) {
        print('Failed to check for update on resume: $e');
      });
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
        RepositoryProvider<NotificationService>.value(value: widget.notificationService),
        RepositoryProvider<ProfileRepository>.value(value: widget.profileRepository), // New
        RepositoryProvider<LeaveRepository>.value(value: widget.leaveRepository),
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
                  lightTheme = AppTheme.getTheme(Brightness.light, themeState.color);
                  darkTheme = AppTheme.getTheme(Brightness.dark, themeState.color);
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
  }
}