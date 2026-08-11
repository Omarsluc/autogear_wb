import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/networking/supabase.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/viewmodel/auth_view_model.dart';
import 'features/cart/viewmodel/cart_view_model.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: MaterialApp(
        title: 'Auto Gear - Auto Parts E-Catalog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
