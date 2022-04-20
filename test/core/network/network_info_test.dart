
import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([DataConnectionChecker])
void main() {
  late MockDataConnectionChecker connectionChecker;
  late NetworkInfo networkInfo;

  setUp(() {
    connectionChecker = MockDataConnectionChecker();
    networkInfo = NetworkInfo(connectionChecker);
  });

  group('isConnected', () {
    test('should forward the call to DataConectionChecker.hasConnection', () async {
      final tHasConnectionFuture = Future.value(true);

      when(connectionChecker.hasConnection).thenAnswer((_) async => tHasConnectionFuture);

      final result = networkInfo.isConnected;

      verify(connectionChecker.hasConnection);
      expect(result, equals(tHasConnectionFuture));
    }, skip: true);
  });
}