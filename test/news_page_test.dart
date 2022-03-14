import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

//* Example of a widget test
void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  ///Dummy article data
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

  ///Mock the behavior of the news service to return dummy article data
  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles()).thenAnswer(
      (invocation) async => tArticles,
    );
  }

  ///Mock the behavior of the news service to return dummy article data after a delay
  void arrangeNewsServiceReturns3ArticlesAfter2SecDelay() {
    when(() => mockNewsService.getArticles()).thenAnswer(
      (invocation) async {
        await Future.delayed(const Duration(seconds: 2));
        return tArticles;
      },
    );
  }

  ///Allows you to achieve testing for specific widgets that require a dependency from its parent
  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  //! Note: Widget tests don't tell the simulated widget tree to rebuild itself
  //! You need to manually let it know that the widget tree needs to be rebuilt
  //* Example widget test for testing static UI, in this case, checking that the screen's title is called "News"
  testWidgets(
    'title is displayed',
    (WidgetTester tester) async {
      //* Arrange
      //* Mock the backend call
      arrangeNewsServiceReturns3Articles();

      //* Act
      //* Get the screen running (somewhat similar in essence to runApp())
      await tester.pumpWidget(createWidgetUnderTest());

      //* Assert
      //* Verify that the static title of the screen shows up
      expect(find.text('News'), findsOneWidget);
    },
  );

  testWidgets(
    "loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      //* Mock the backend call but with a delay before returning the data
      arrangeNewsServiceReturns3ArticlesAfter2SecDelay();
      await tester.pumpWidget(createWidgetUnderTest());

      //* Tells the test framework to rebuild after half a second
      await tester.pump(const Duration(milliseconds: 500));

      //* Find a widget by its class type
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      //* Find a widget by the key assigned to that
      expect(find.byKey(const Key('news_page_loader')), findsOneWidget);

      //* Waits until there are no more rebuilds happening (no more timers waiting)
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    "articles are displayed",
    (WidgetTester tester) async {
      //* Mock the backend call
      arrangeNewsServiceReturns3Articles();

      //* Create the widget and rebuild after the backend call
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      //* Verify that there are text widgets containing the title and content of the retrieved list
      for (final article in tArticles) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
