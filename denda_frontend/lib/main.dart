import 'package:denda_frontend/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart'; // ĐÃ THÊM: Import ProductProvider
import 'views/auth/login_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/admin_provider.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DenDa Coffee',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(), 
      routes: {
        '/LoginScreen': (context) => const LoginScreen(),
      },
    );
  }
}