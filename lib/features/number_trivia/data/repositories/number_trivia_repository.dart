import 'package:clean_architecture_tdd_course/core/error/exception.dart';
import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/core/error/failure.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';

import '../datasources/number_trivia_local_datasource.dart';
import '../datasources/number_trivia_remote_datasource.dart';

typedef _ConcreteOrRandomChooser = Future<NumberTriviaModel> Function();

class NumberTriviaRepository implements INumberTriviaRepository {
  final INumberTriviaRemoteDataSource remoteDataSource;
  final INumberTriviaLocalDataSource localDataSource;
  final INetworkInfo networkInfo;

  NumberTriviaRepository({
    required this.remoteDataSource, 
    required this.localDataSource, 
    required this.networkInfo
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number) async {
    return await _geTrivia(() => remoteDataSource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _geTrivia(() => remoteDataSource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTrivia>> _geTrivia(
    _ConcreteOrRandomChooser getConcreteOrRandom
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final trivia = await getConcreteOrRandom();
        localDataSource.cacheNumberTrivia(trivia);
        return Right(trivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } 
    else {
      try {
        final trivia = await localDataSource.getLastNumberTrivia();
        return Right(trivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
  
}