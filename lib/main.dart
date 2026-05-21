import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/database/local_database.dart';
import 'features/waiter_module/presentation/cubits/tables/tables_cubit_export.dart';
import 'features/waiter_module/presentation/cubits/orders/orders_cubit_export.dart';
import 'features/waiter_module/presentation/cubits/reports/reports_cubit_export.dart';
import 'features/waiter_module/presentation/pages/tables_page.dart';

/// Główny punkt wejścia aplikacji QuiLaCarne Waiter
/// 
/// Wzorzec: Composition Root Pattern
/// Dlaczego: Centralne miejsce konfiguracji wszystkich zależności
/// i inicjalizacji aplikacji przed uruchomieniem UI
void main() async {
  // Zapewnij że Flutter bindings są zainicjalizowane
  WidgetsFlutterBinding.ensureInitialized();
  
  // Zainicjalizuj bazę danych
  await di.initDatabase();
  
  // Zarejestruj wszystkie zależności
  await di.initDependencies();
  
  // Uruchom aplikację
  runApp(const QuiLaCarneApp());
}

/// Główny widget aplikacji
class QuiLaCarneApp extends StatelessWidget {
  const QuiLaCarneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // TablesCubit - zarządzanie stolikami
        BlocProvider<TablesCubit>(
          create: (_) => di.sl<TablesCubit>()..loadTables(),
        ),
        
        // OrdersCubit - zarządzanie zamówieniami
        BlocProvider<OrdersCubit>(
          create: (_) => di.sl<OrdersCubit>(),
        ),
        
        // ReportsCubit - zgłoszenia gości
        BlocProvider<ReportsCubit>(
          create: (_) => di.sl<ReportsCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'QuiLaCarne Waiter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.redAccent,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.redAccent,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const TablesPage(),
      ),
    );
  }
}
