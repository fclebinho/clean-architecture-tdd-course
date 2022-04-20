// ignore_for_file: constant_identifier_names

import 'package:bloc/bloc.dart';
import 'package:clean_architecture_tdd_course/core/core.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server failure';
const String CACHE_FAILURE_MESSAGE = 'Cache failure';
const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid input - The number be a positive or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia concreteNumberTrivia;
  final GetRandomNumberTrivia randomNumberTrivia;
  final InputConverter converter;

  NumberTriviaBloc({
    required this.concreteNumberTrivia, 
    required this.randomNumberTrivia, 
    required this.converter
  }) : super(NumberTriviaInitial()) {
    on<NumberTriviaEvent>((event, emit) async {
      if (event is GetTriviaForConcreteNumber) {
        emit.call(NumberTriviaLoading());
        final result = converter.stringToUnsignedInteger(event.numberString);

        result.fold((l) {
          emit.call(const NumberTriviaError(INVALID_INPUT_FAILURE_MESSAGE));
        } , (r) async {
          final result = await concreteNumberTrivia(Params(number: r));
          _eitherLoadedOrError(emit, result);
        });
      } else if (event is GetTriviaForRandomNumber) {
        emit.call(NumberTriviaLoading());

        final result = await randomNumberTrivia(NoParams());
        _eitherLoadedOrError(emit, result);
      }
    });
  }

  void _eitherLoadedOrError(Emitter<NumberTriviaState> emit, Either<Failure, NumberTrivia> value) => 
    value.fold((l) => emit.call(NumberTriviaError(_mapFailureToMessage(l))), (r) => emit.call(NumberTriviaLoaded(r)));

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
