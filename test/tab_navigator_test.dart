// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabnavigator/tabnavigator.dart';

void main() {
  late StreamController<TestTab> tabController;

  setUp(() {
    tabController = StreamController<TestTab>.broadcast(sync: true);
  });

  group('TabNavigator', () {
    testWidgets('smoke test', (tester) async {
      const initTab = TestTab.first;

      Stream<TestTab> tabStream() => tabController.stream;

      final map = {
        TestTab.first: () => const ColoredBox(color: Colors.white),
        TestTab.second: () => const ColoredBox(color: Colors.blue),
        TestTab.third: () => const ColoredBox(color: Colors.red),
      };

      final widget = MaterialApp(
        home: Scaffold(
          body: TabNavigator(
            initialTab: initTab,
            selectedTabStream: tabStream(),
            mappedTabs: map,
          ),
        ),
      );

      await tester.pumpWidget(widget);
    });

    testWidgets('navigation between tabs', (tester) async {
      const initTab = TestTab.first;

      const keys = [
        Key('first'),
        Key('second'),
        Key('third'),
      ];

      final map = {
        TestTab.first: () => ColoredBox(color: Colors.white, key: keys[0]),
        TestTab.second: () => ColoredBox(color: Colors.blue, key: keys[1]),
        TestTab.third: () => ColoredBox(color: Colors.red, key: keys[2]),
      };

      Stream<TestTab> tabStream() => tabController.stream;

      final widget = MaterialApp(
        home: Scaffold(
          body: TabNavigator(
            initialTab: initTab,
            selectedTabStream: tabStream(),
            mappedTabs: map,
          ),
        ),
      );

      await tester.pumpWidget(widget);

      // current tab is first with white color
      expect(
        find.descendant(
          of: find.byType(TabNavigator),
          matching: find.byKey(keys[0]),
        ),
        findsWidgets,
      );

      expect(
        find.descendant(
          of: find.byType(TabNavigator),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                (widget.color == Colors.blue || widget.color == Colors.red),
          ),
        ),
        findsNothing,
      );

      // set current tab to second with blue color
      tabController.sink.add(TestTab.second);
      await tester.pump();

      // current tab is second with blue color
      expect(
        find.descendant(
          of: find.byType(TabNavigator),
          matching: find.byKey(keys[1]),
        ),
        findsWidgets,
      );

      expect(
        find.descendant(
          of: find.byType(TabNavigator),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                (widget.color == Colors.red || widget.color == Colors.white),
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('deep navigation', (tester) async {
      const initTab = TestTab.first;

      const keys = [
        Key('first'),
        Key('second'),
        Key('third'),
      ];

      final map = {
        TestTab.first: () {
          return Builder(builder: (context) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => const Scaffold(
                      body: ColoredBox(
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
              child: ColoredBox(color: Colors.white, key: keys[0]),
            );
          });
        },
        TestTab.second: () => ColoredBox(color: Colors.blue, key: keys[1]),
        TestTab.third: () => ColoredBox(color: Colors.red, key: keys[2]),
      };

      Stream<TestTab> tabStream() => tabController.stream;

      final widget = MaterialApp(
        home: Scaffold(
          body: TabNavigator(
            initialTab: initTab,
            selectedTabStream: tabStream(),
            mappedTabs: map,
          ),
          bottomNavigationBar: StreamBuilder<TestTab>(
            stream: tabStream(),
            initialData: initTab,
            builder: (context, snapshot) {
              return BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.feedback),
                    label: 'Feed',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.color_lens),
                    label: 'Colors',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info),
                    label: 'Info',
                  ),
                ],
                currentIndex: snapshot.hasData ? snapshot.data!.value : 0,
                onTap: (value) =>
                    tabController.sink.add(TestTab.byValue(value)),
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);

      // current tab is first with white color
      expect(
        find.descendant(
          of: find.byType(TabNavigator),
          matching: find.byKey(keys[0]),
        ),
        findsWidgets,
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is ColoredBox && widget.color == Colors.green,
        ),
        findsNothing,
      );

      await tester.tap(find.byKey(keys[0]));
      await tester.pumpAndSettle();

      // this means that we're at second screen of first tab
      expect(
        find.byWidgetPredicate(
          (widget) => widget is ColoredBox && widget.color == Colors.green,
        ),
        findsWidgets,
      );

      await tester.tap(find.byIcon(Icons.color_lens));
      await tester.pumpAndSettle();

      // current tab is second with blue color
      expect(
        find.descendant(
          of: find.byType(TabNavigator),
          matching: find.byKey(keys[0]),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(TabNavigator),
          matching: find.byKey(keys[1]),
        ),
        findsWidgets,
      );
    });
  });

  tearDown(() async {
    await tabController.close();
  });
}

class TestTab extends TabType {
  static const first = TestTab._(0);
  static const second = TestTab._(1);
  static const third = TestTab._(2);

  const TestTab._(int value) : super(value);

  static TestTab byValue(int value) {
    switch (value) {
      case 0:
        return first;
      case 1:
        return second;
      case 2:
        return third;
      default:
        throw Exception('no tab for such value');
    }
  }
}
