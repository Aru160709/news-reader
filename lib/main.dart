// Mengimpor package dasar Flutter untuk membuat UI
import 'package:flutter/material.dart';

// Mengimpor provider untuk state management
import 'package:provider/provider.dart';

// Mengimpor SharedPreferences untuk menyimpan data lokal (tema, dll)
import 'package:shared_preferences/shared_preferences.dart';

// Mengimpor package http untuk melakukan request API
import 'package:http/http.dart' as http;

// ================= CORE =================

// Mengimpor pengaturan tema aplikasi (light & dark)
import 'package:news_reader/core/theme/app_theme.dart';

// ================= DATA =================

// Mengimpor service API untuk mengambil berita
import 'package:news_reader/data/datasources/news_api_service.dart';

// Mengimpor implementasi repository berita
import 'package:news_reader/data/repositories/news_repository_impl.dart';

// ================= DOMAIN =================

// Mengimpor abstraksi repository (kontrak)
import 'package:news_reader/domain/repositories/news_repository.dart';

// ================= PRESENTATION =================

// Mengimpor provider untuk mengelola data berita
import 'package:news_reader/presentation/providers/news_provider.dart';

// Mengimpor provider untuk mengelola tema aplikasi
import 'package:news_reader/presentation/providers/theme_provider.dart';

// Mengimpor halaman utama aplikasi
import 'package:news_reader/presentation/screens/home_screen.dart';

void main() async {
  // Memastikan binding Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mengambil instance SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Menjalankan aplikasi dan mengirim prefs ke MyApp
  runApp(MyApp(prefs: prefs));
}

// Widget utama aplikasi
class MyApp extends StatelessWidget {
  // SharedPreferences disimpan sebagai properti
  final SharedPreferences prefs;
  
  // Constructor MyApp
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // MultiProvider digunakan untuk menyediakan banyak provider sekaligus
    return MultiProvider(
      providers: [

        // ================= HTTP CLIENT =================
        // Provider untuk http.Client (dipakai API service)
        Provider<http.Client>(
          create: (_) => http.Client(),
        ),
        
        // ================= SHARED PREFERENCES =================
        // Menyediakan SharedPreferences ke seluruh app
        Provider<SharedPreferences>.value(
          value: prefs,
        ),
        
        // ================= API SERVICE =================
        // ProxyProvider → bergantung pada http.Client
        ProxyProvider<http.Client, NewsApiService>(
          update: (_, client, __) => NewsApiService(client: client),
        ),
        
        // ================= REPOSITORY =================
        // Repository bergantung pada API Service & SharedPreferences
        ProxyProvider2<NewsApiService, SharedPreferences, NewsRepository>(
          update: (_, apiService, prefs, __) => NewsRepositoryImpl(
            apiService: apiService,
            prefs: prefs,
          ),
        ),
        
        // ================= THEME PROVIDER =================
        // ChangeNotifier untuk mengatur mode tema (light/dark)
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs: prefs),
        ),
        
        // ================= NEWS PROVIDER =================
        // ChangeNotifier untuk mengatur data berita
        ChangeNotifierProvider<NewsProvider>(
          create: (context) => NewsProvider(
            repository: context.read<NewsRepository>(),
          ),
        ),
      ],

      // Consumer digunakan untuk mendengarkan perubahan tema
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // Judul aplikasi
            title: 'News Reader Pro',

            // Menghilangkan banner debug
            debugShowCheckedModeBanner: false,
            
            // Tema terang
            theme: AppTheme.lightTheme,

            // Tema gelap
            darkTheme: AppTheme.darkTheme,

            // Mode tema (light / dark / system)
            themeMode: themeProvider.themeMode,
            
            // Halaman awal aplikasi
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
