import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/locale_cubit.dart';
import 'core/networking/supabase.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/home/cubit/home_cubit.dart';
import 'features/home/view/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await SupabaseService.initialize();
  }

  runApp(const AutoGearApp());
}

class AutoGearApp extends StatelessWidget {
  const AutoGearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(create: (_) => HomeCubit()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'Auto Gear - Auto Parts E-Catalog',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
