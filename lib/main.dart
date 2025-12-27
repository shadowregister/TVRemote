import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/logger.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.dark) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeString = _prefs.getString(StorageKeys.themeMode);
    if (themeString != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == themeString,
        orElse: () => ThemeMode.dark,
      );
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(StorageKeys.themeMode, mode.name);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }
}

// Haptic feedback provider
final hapticEnabledProvider = StateNotifierProvider<HapticNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HapticNotifier(prefs);
});

class HapticNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  HapticNotifier(this._prefs) : super(true) {
    _loadSetting();
  }

  void _loadSetting() {
    state = _prefs.getBool(StorageKeys.hapticEnabled) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _prefs.setBool(StorageKeys.hapticEnabled, enabled);
  }

  void toggle() {
    setEnabled(!state);
  }
}

// Helper function to trigger haptic feedback if enabled
void triggerHaptic(WidgetRef ref, {HapticType type = HapticType.light}) {
  final enabled = ref.read(hapticEnabledProvider);
  if (!enabled) return;

  switch (type) {
    case HapticType.light:
      HapticFeedback.lightImpact();
      break;
    case HapticType.medium:
      HapticFeedback.mediumImpact();
      break;
    case HapticType.heavy:
      HapticFeedback.heavyImpact();
      break;
    case HapticType.selection:
      HapticFeedback.selectionClick();
      break;
  }
}

enum HapticType { light, medium, heavy, selection }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logger
  AppLogger.configure(enabled: true, minLevel: LogLevel.debug);
  AppLogger.info('App starting...', tag: 'Main');

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const TVRemoteApp(),
    ),
  );
}

class TVRemoteApp extends ConsumerWidget {
  const TVRemoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
