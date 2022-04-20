import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exception.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_datasource_test.mocks.dart';

@GenerateMocks([http.Client])
main() {
  late MockClient client;
  late NumberTriviaRemoteDataSource datasource;

  setUp(() {
    client = MockClient();
    datasource = NumberTriviaRemoteDataSource(client);
  });

  void requestMockWithSuccess() {
      when(client.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void requestMockWithFailure() {
      when(client.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('should perform a GET request on s URL with number beign the endpoint and with application/json header', () async {
      requestMockWithSuccess();

      datasource.getConcreteNumberTrivia(tNumber);

      verify(client.get(Uri(scheme: 'http', host: 'numbersapi.com', path: '/$tNumber'), headers: {
        'Content-Type': 'application/json'
      }));
    });

    test('should return NumberTrivia when the response code is 200 (success)', () async {
      requestMockWithSuccess();

      final result = await datasource.getConcreteNumberTrivia(tNumber);

      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the repsonse code is 404 or other', () async {
      requestMockWithFailure();

      final call = datasource.getConcreteNumberTrivia;

      expect(() => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('should perform a GET request on s URL with number beign the endpoint and with application/json header', () async {
      requestMockWithSuccess();

      datasource.getRandomNumberTrivia();

      verify(client.get(Uri(scheme: 'http', host: 'numbersapi.com', path: '/random'), headers: {
        'Content-Type': 'application/json'
      }));
    });

    test('should return NumberTrivia when the response code is 200 (success)', () async {
      requestMockWithSuccess();

      final result = await datasource.getRandomNumberTrivia();

      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the repsonse code is 404 or other', () async {
      requestMockWithFailure();

      final call = datasource.getRandomNumberTrivia;

      expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}