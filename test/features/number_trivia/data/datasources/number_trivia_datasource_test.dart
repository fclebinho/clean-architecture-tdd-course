import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exception.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_datasource_test.mocks.dart';

@GenerateMocks([SharedPreferences])
main() {
  late MockSharedPreferences preferences;
  late NumberTriviaLocalDataSource datasource;

  setUp(() {
    preferences = MockSharedPreferences();
    datasource = NumberTriviaLocalDataSource(preferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test('should return NumberTrivia from SharedPreferences when there is one int the cache', () async {
      when(preferences.getString(any)).thenReturn(fixture('trivia_cached.json'));

      final result = await datasource.getLastNumberTrivia();

      verify(preferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a CacheException when then is no a cached value', () async {
      when(preferences.getString(any)).thenReturn(null);

      final call = datasource.getLastNumberTrivia;

      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel('test trivia', number: 1);
    test('should call SharedPreferences to cache the data', () async {
      when(preferences.setString(any, any)).thenAnswer((_) async => true);
      datasource.cacheNumberTrivia(tNumberTriviaModel);

      final expectedJSONString = json.encode(tNumberTriviaModel.toJson());
      verify(preferences.setString(CACHED_NUMBER_TRIVIA, expectedJSONString));
    });
  });
}