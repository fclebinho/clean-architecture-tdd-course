import 'package:clean_architecture_tdd_course/core/core.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia concreteNumberTrivia;
  late MockGetRandomNumberTrivia randomNumberTrivia;
  late MockInputConverter converter;

  setUp(() {
    concreteNumberTrivia = MockGetConcreteNumberTrivia();
    randomNumberTrivia = MockGetRandomNumberTrivia();
    converter = MockInputConverter();
    bloc = NumberTriviaBloc(
      concreteNumberTrivia: concreteNumberTrivia, 
      randomNumberTrivia: randomNumberTrivia, 
      converter: converter
    );
  });

  test('initialState should be empty', () {
    expect(bloc.state, equals(const TypeMatcher<NumberTriviaInitial>()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumber = 1;
    const tNumberTrivia = NumberTrivia('test trivia', number: 1);

    test('should call the InputCnverter to validate and convert the string to an unsigned integer', () async {
      when(converter.stringToUnsignedInteger(any)).thenReturn(const Right(tNumber));
      when(concreteNumberTrivia(any)).thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(converter.stringToUnsignedInteger(any));

      verify(converter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () async {
      when(converter.stringToUnsignedInteger(any)).thenReturn(Left(InvalidInputFailure()));
      
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      
      final expected = [NumberTriviaInitial(), ErrorDescription(INVALID_INPUT_FAILURE_MESSAGE)];
      expectLater(bloc.state, emitsInOrder(expected));
    }, skip: true);

    test('should get data from the concrete use case', () async {
      when(converter.stringToUnsignedInteger(any)).thenReturn(const Right(tNumber));
      when(concreteNumberTrivia(any)).thenAnswer((_) async => const Right(tNumberTrivia));
      
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(converter.stringToUnsignedInteger(any));

      verify(concreteNumberTrivia(const Params(number: tNumber)));
    });

    test('should emit [loading, loaded] when data is totten successfuly', () async {
      when(converter.stringToUnsignedInteger(any)).thenReturn(const Right(tNumber));
      when(concreteNumberTrivia(any)).thenAnswer((_) async => const Right(tNumberTrivia));

      final expected = [
        NumberTriviaInitial(), 
        NumberTriviaLoading(), 
        const NumberTriviaLoaded(tNumberTrivia)
      ];
      expect(bloc.state, emitsInOrder(expected));
      
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    }, skip: true);

    test('should emit [loading, Error] when getting data fails', () async {
      when(converter.stringToUnsignedInteger(any)).thenReturn(const Right(tNumber));
      when(concreteNumberTrivia(any)).thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        NumberTriviaInitial(), 
        NumberTriviaLoading(), 
        const NumberTriviaError(SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    }, skip: true);

    test('should emit [loading, Error] with proper message for the error when getting data fails', () async {
      when(converter.stringToUnsignedInteger(any)).thenReturn(const Right(tNumber));
      when(concreteNumberTrivia(any)).thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        NumberTriviaInitial(), 
        NumberTriviaLoading(), 
        const NumberTriviaError(CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    }, skip: true);
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia('test trivia', number: 1);

    test('should get data from the random use case', () async {
      when(randomNumberTrivia(any)).thenAnswer((_) async => const Right(tNumberTrivia));
      
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(randomNumberTrivia(any));

      verify(randomNumberTrivia(NoParams()));
    });

    test('should emit [loading, loaded] when data is totten successfuly', () async {
      when(randomNumberTrivia(any)).thenAnswer((_) async => const Right(tNumberTrivia));

      final expected = [
        NumberTriviaInitial(), 
        NumberTriviaLoading(), 
        const NumberTriviaLoaded(tNumberTrivia)
      ];
      expect(bloc.state, emitsInOrder(expected));
      
      bloc.add(GetTriviaForRandomNumber());
    }, skip: true);

    test('should emit [loading, Error] when getting data fails', () async {
      when(randomNumberTrivia(any)).thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        NumberTriviaInitial(), 
        NumberTriviaLoading(), 
        const NumberTriviaError(SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.add(GetTriviaForRandomNumber());
    }, skip: true);

    test('should emit [loading, Error] with proper message for the error when getting data fails', () async {
      when(randomNumberTrivia(any)).thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        NumberTriviaInitial(), 
        NumberTriviaLoading(), 
        const NumberTriviaError(CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.add(GetTriviaForRandomNumber());
    }, skip: true);
  });
}