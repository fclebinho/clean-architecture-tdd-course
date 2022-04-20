import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_concrete_number_test.mocks.dart';


@GenerateMocks([INumberTriviaRepository])
void main() {
  late MockINumberTriviaRepository mockRepository;
  late GetConcreteNumberTrivia usecase;

  setUp(() {
    mockRepository = MockINumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockRepository);
  });

  const tNumber = 1;
  const tNumberTrivia = NumberTrivia('test', number: tNumber);

  test('should get trivia for the number from the repository', () async {
    when(mockRepository.getConcreteNumberTrivia(tNumber)).thenAnswer((_) async => const Right(tNumberTrivia));

    final result = await usecase(const Params(number: tNumber));

    expect(result, const Right(tNumberTrivia));
    verify(mockRepository.getConcreteNumberTrivia(tNumber));
    verifyNoMoreInteractions(mockRepository);
  });
}