import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gota/services/supabase_service.dart';
import 'package:gota/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  final supabaseService = SupabaseService();
  
  // Set Provider.debugCheckInvalidValueType to null to avoid the Provider error
  Provider.debugCheckInvalidValueType = null;
  
  try {
    await supabaseService.initialize();
    runApp(MyApp(supabaseService: supabaseService));
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
    
    // Check for specific PostgreSQL errors
    if (e.toString().contains('column "is_active" does not exist') || 
        e.toString().contains('violates row-level security policy')) {
      runApp(DatabaseErrorApp(errorMessage: 'Lỗi cấu trúc cơ sở dữ liệu', 
                              detailMessage: 'Vui lòng chạy file schema_update.sql trong thư mục lib/docs'));
    } else if (e is AuthException) {
      runApp(DatabaseErrorApp(errorMessage: 'Lỗi xác thực',
                              detailMessage: 'Vui lòng kiểm tra thông tin đăng nhập và thử lại'));
    } else {
      runApp(const InitializationErrorApp());
    }
  }
}

class MyApp extends StatefulWidget {
  final SupabaseService supabaseService;
  
  const MyApp({super.key, required this.supabaseService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      // This will be triggered when auth state changes, including after email verification
      debugPrint('Auth state changed: ${data.event}');
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SupabaseService>.value(value: widget.supabaseService),
      ],
      child: MaterialApp(
        title: 'Gota Restaurant',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

// A database error app with more specific error details
class DatabaseErrorApp extends StatelessWidget {
  final String errorMessage;
  final String detailMessage;
  
  const DatabaseErrorApp({
    super.key, 
    required this.errorMessage,
    required this.detailMessage,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Error',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  detailMessage,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Xem hướng dẫn khắc phục lỗi trong thư mục lib/docs/error_resolution_guide.md',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    RestartWidget.restartApp(context);
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A simple error app to show if initialization fails
class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Initialization Error',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Không thể khởi tạo ứng dụng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng kiểm tra kết nối mạng và thử lại',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart app
                  RestartWidget.restartApp(context);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget to restart the app
class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});
  
  final Widget child;
  
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<RestartWidgetState>()?.restartApp();
  }
  
  @override
  State<RestartWidget> createState() => RestartWidgetState();
}

class RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();
  
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}
