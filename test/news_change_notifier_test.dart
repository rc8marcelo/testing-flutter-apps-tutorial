import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

///This is a bad example of mocking a class.
///
///The reason behind this being a bad example is because there may be instances where you might need to add additional behavior here to mirror the behavior of the real class which makes this harder to maintain.
class BadMockNewsService implements NewsService {
  @override
  Future<List<Article>> getArticles() async {
    return [
      Article(
        title: 'Test 1',
        content: 'Test 1 Content',
      ),
      Article(
        title: 'Test 2',
        content: 'Test 2 Content',
      ),
      Article(
        title: 'Test 3',
        content: 'Test 3 Content',
      ),
    ];
  }
}

class MockNewsService extends Mock implements NewsService {}

void main() {
  ///SUT stands for system under test (the class being tested)
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService;

  setUp(() {
    //* This is where you should initialize or setup dependencies needed to run the tests
    //* This block of code runs before each test is run

    //* Instantiating our mock dependencies
    mockNewsService = MockNewsService();

    //* Reset the SUT
    sut = NewsChangeNotifier(mockNewsService);
  });

  test(
    'initial values are correct',
    () {
      //* Assert
      expect(sut.articles, []);
      expect(sut.isLoading, false);
    },
  );

  group('getArticles', () {
    //* Put data needed by Mocks and Assertions here
    //* These will be used throughout the tests inside this group
    final tArticles = [
      Article(
        title: 'Test 1',
        content: 'Test 1 Content',
      ),
      Article(
        title: 'Test 2',
        content: 'Test 2 Content',
      ),
      Article(
        title: 'Test 3',
        content: 'Test 3 Content',
      ),
    ];
    void arrangeNewsServiceReturns3Articles() {
      when(() => mockNewsService.getArticles()).thenAnswer(
        (invocation) async => tArticles,
      );
    }

    test(
      'gets articles using the NewsService',
      () async {
        //* Arrange

        //* thenAnswer is used here because the getArticles method is an asynchronous function.
        //* We can use thenReturn if the function being tested is synchronous
        when(() => mockNewsService.getArticles()).thenAnswer((_) async => []);

        //* Act
        await sut.getArticles();

        //* Assert

        //* Verify that the mock class' getArticles() function was called once
        verify(() => mockNewsService.getArticles()).called(1);
      },
    );

    test(
      'indicates loading of data, sets articles to the ones  from the service, indicates that data is not being loaded anymore',
      () async {
        //* A better way to manage arranging mocks
        arrangeNewsServiceReturns3Articles();

        final future = sut.getArticles();
        expect(sut.isLoading, true);
        await future;
        expect(sut.articles, tArticles);
        expect(sut.isLoading, false);
      },
    );
  });
}
