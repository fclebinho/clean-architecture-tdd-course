
import 'package:clean_architecture_tdd_course/core/error/exception.dart';
import 'package:clean_architecture_tdd_course/core/error/failure.dart';
import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_repository_test.mocks.dart';

@GenerateMocks([INetworkInfo])
@GenerateMocks([INumberTriviaRemoteDataSource])
@GenerateMocks([INumberTriviaLocalDataSource])
void main() {
  late NumberTriviaRepository repository;
  late MockINumberTriviaRemoteDataSource remoteDataSource;
  late MockINumberTriviaLocalDataSource localDataSource;
  late MockINetworkInfo networkInfo;

  setUp(() {
    remoteDataSource = MockINumberTriviaRemoteDataSource();
    localDataSource = MockINumberTriviaLocalDataSource();
    networkInfo = MockINetworkInfo();

    repository = NumberTriviaRepository(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaModel = NumberTriviaModel('test trivia', number: tNumber);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async {
      when(localDataSource.cacheNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
      when(remoteDataSource.getConcreteNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
      when(networkInfo.isConnected).thenAnswer((_) async => true);

      repository.getConcreteNumberTrivia(tNumber);

      verify(networkInfo.isConnected);
    });

    runTestsOnline(() {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return last locally cached data when the cached data is present', () async {
        when(remoteDataSource.getConcreteNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
        when(localDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return remote data when the call to remote data source is unsuccessful', () async {
        when(remoteDataSource.getConcreteNumberTrivia(any)).thenThrow(ServerException());

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verify(remoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(localDataSource);
        expect(result, Left(ServerFailure()));
      }, skip: true);

      test('should return CacheFailure when there is no cached data present', () async {
        when(remoteDataSource.getConcreteNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
        when(localDataSource.getLastNumberTrivia()).thenThrow(CacheException());

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      }, skip: true);
      
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaModel = NumberTriviaModel('test trivia', number: tNumber);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async {
      when(remoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
      when(localDataSource.cacheNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
      when(networkInfo.isConnected).thenAnswer((_) async => true);

      repository.getRandomNumberTrivia();

      verify(networkInfo.isConnected);
    });

    runTestsOffline(() {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return remote data when the call to remote data source is successful', () async {
        when(localDataSource.cacheNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
        when(localDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);

        final result = await repository.getRandomNumberTrivia();

        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return last locally cached data when the cached data is present', () async {
        when(remoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        when(localDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);

        final result = await repository.getRandomNumberTrivia();

        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return remote data when the call to remote data source is unsuccessful', () async {
        when(remoteDataSource.getRandomNumberTrivia()).thenThrow(ServerException());

        final result = await repository.getRandomNumberTrivia();

        verify(remoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(localDataSource);
        expect(result, Left(ServerFailure()));
      }, skip: true);

      test('should return CacheFailure when there is no cached data present', () async {
        when(remoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        when(localDataSource.getLastNumberTrivia()).thenThrow(CacheException());

        final result = await repository.getRandomNumberTrivia();

        verifyZeroInteractions(remoteDataSource);
        verify(localDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      }, skip: true);
    });
  });
}