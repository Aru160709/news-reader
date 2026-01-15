import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Core
import 'package:news_reader/core/theme/app_theme.dart';

// Data
import 'package:news_reader/data/datasources/news_api_service.dart';
import 'package:news_reader/data/repositories/news_repository_impl.dart';

// Domain
import 'package:news_reader/domain/repositories/news_repository.dart';

// Presentation
import 'package:news_reader/presentation/providers/news_provider.dart';
import 'package:news_reader/presentation/providers/theme_provider.dart';
import 'package:news_reader/presentation/screens/home_screen.dart';

void main() async {
  // Ensure Flutter binding initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // HTTP Client
        Provider<http.Client>(
          create: (_) => http.Client(),
        ),
        
        // SharedPreferences
        Provider<SharedPreferences>.value(
          value: prefs,
        ),
        
        // API Service
        ProxyProvider<http.Client, NewsApiService>(
          update: (_, client, __) => NewsApiService(client: client),
        ),
        
        // Repository
        ProxyProvider2<NewsApiService, SharedPreferences, NewsRepository>(
          update: (_, apiService, prefs, __) => NewsRepositoryImpl(
            apiService: apiService,
            prefs: prefs,
          ),
        ),
        
        // Theme Provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs: prefs),
        ),
        
        // News Provider
        ChangeNotifierProvider<NewsProvider>(
          create: (context) => NewsProvider(
            repository: context.read<NewsRepository>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'News Reader Pro',
            debugShowCheckedModeBanner: false,
            
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Home
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}