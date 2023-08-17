import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_infinite_scroll/providers/app_base_provider.dart';
import 'package:twitter_infinite_scroll/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppBaseProvider(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
          routes: {
            HomeScreen.id: (context) => const HomeScreen(),
          }),
    );
  }
}
