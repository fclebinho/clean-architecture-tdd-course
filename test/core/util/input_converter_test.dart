import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  late InputConverter converter;
  
  setUp(() {
    converter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test('should return an integer when the string represents an unsigned integer', () async {
      const str = '123';

      final result = converter.stringToUnsignedInteger(str);

      expect(result, const Right(123));
    });

    test('should return a failure when the string is not an integer', () async {
      const str = 'abc';

      final result = converter.stringToUnsignedInteger(str);

      expect(result, Left(InvalidInputFailure()));
    });

    test('should return a failure when the string is a negative number', () async {
      const str = '-3';

      final result = converter.stringToUnsignedInteger(str);

      expect(result, Left(InvalidInputFailure()));
    });
  });
}