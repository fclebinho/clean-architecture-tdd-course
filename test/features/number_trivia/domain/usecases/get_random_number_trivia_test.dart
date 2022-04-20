import 'package:clean_architecture_tdd_course/core/core.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_concrete_number_test.mocks.dart';


@GenerateMocks([INumberTriviaRepository])
void main() {
  late MockINumberTriviaRepository mockRepository;
  late GetRandomNumberTrivia usecase;

  setUp(() {
    mockRepository = MockINumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockRepository);
  });

  const tNumberTrivia = NumberTrivia('test', number: 1);

  test('should get trivia for the number from the repository', () async {
    when(mockRepository.getRandomNumberTrivia()).thenAnswer((_) async => const Right(tNumberTrivia));

    final result = await usecase(NoParams());

    expect(result, const Right(tNumberTrivia));
    verify(mockRepository.getRandomNumberTrivia());
    verifyNoMoreInteractions(mockRepository);
  });
}