import "../Bloc/AppBloc.dart";
import "package:flutter/material.dart";
//import bloc for global state management:
import "package:flutter_bloc/flutter_bloc.dart";

import 'Views/MainScreen.dart';

void main() async
{
  final appBloc = AppBloc();
  runApp(
    MultiBlocProvider
    (
       providers: [
        BlocProvider<AppBloc>(
          create: (_) => appBloc,
        ),
      ],
      child: const BankCardValidator()),
    );
}

class BankCardValidator extends StatelessWidget 
{
  const BankCardValidator({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Bank Card Validator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MainScreen(),
    );
  }
}

