import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/vocab_repository.dart';
import 'logic/cubits/navigation_cubit.dart';
import 'logic/cubits/vocab_cubit.dart';
import 'logic/cubits/practice_cubit.dart';
import 'ui/screens/main_screen.dart';
import 'ui/theme/lexicraft_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final vocabRepository = MockVocabRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<VocabRepository>.value(value: vocabRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NavigationCubit()),
          BlocProvider(create: (context) => VocabCubit(vocabRepository)),
          BlocProvider(create: (context) => PracticeCubit()),
        ],
        child: const LexicraftApp(),
      ),
    ),
  );
}

class LexicraftApp extends StatelessWidget {
  const LexicraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexicraft',
      debugShowCheckedModeBanner: false,
      theme: LexicraftTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
