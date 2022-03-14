import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/article_page.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

//* Example of an integration test
//* Placing test files inside the integration_test folder will run it through an emulator
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

  testWidgets(
    "Tapping on the first article opens the article page where the full content is displayed",
    (WidgetTester tester) async {
      //* Arrange
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      //* replicate a tap behavior so that it animates to the next page
      await tester.tap(find.text('Test 1 Content'));

      //* Complete the animation
      await tester.pumpAndSettle();

      //* Verify that the page changed and the following text widgets are found
      expect(find.byType(NewsPage), findsNothing);
      expect(find.byType(ArticlePage), findsOneWidget);

      expect(find.text('Test 1'), findsOneWidget);
      expect(find.text('Test 1 Content'), findsOneWidget);
    },
  );
}
