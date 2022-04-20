import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exception.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

abstract class INumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);
  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSource implements INumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSource(this.client);

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    return _getNumberTrivia('/$number');
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async {
    return _getNumberTrivia('/random');
  }

  Future<NumberTriviaModel> _getNumberTrivia(String path) async {
    final response = await client.get(Uri(scheme: 'http', host: 'numbersapi.com', path: path), headers: {
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response.body));
    }

    throw ServerException();
  }
  
}