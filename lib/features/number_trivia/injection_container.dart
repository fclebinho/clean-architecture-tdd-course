import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //! Features - Number Trivia
  // Bloc's
  sl.registerFactory(() => NumberTriviaBloc(
    concreteNumberTrivia: sl(), 
    randomNumberTrivia: sl(), 
    converter: sl()
  ));

  // Uses cases
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));

  // Repositories
  sl.registerLazySingleton<INumberTriviaRepository>(() => NumberTriviaRepository(
    remoteDataSource: sl(), 
    localDataSource: sl(), 
    networkInfo: sl()
  ));

  // Data sources
  sl.registerLazySingleton<INumberTriviaRemoteDataSource>(() => NumberTriviaRemoteDataSource(sl()));
  sl.registerLazySingleton<INumberTriviaLocalDataSource>(() => NumberTriviaLocalDataSource(sl()));


  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<INetworkInfo>(() => NetworkInfo(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() async => http.Client());
  sl.registerLazySingleton(() async => DataConnectionChecker());
}

void initFeatures() {}

