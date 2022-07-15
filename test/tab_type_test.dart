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

import 'package:flutter_test/flutter_test.dart';
import 'package:tabnavigator/tabnavigator.dart';

void main() {
  test('TabType append', () {
    final tabs = [
      TestTab.first,
      TestTab.second,
      TestTab.third,
    ]..forEach(TabType.append);

    expect(TabType.values, equals(tabs));
  });

  test('TabType byValue', () {
    final tabs = [
      TestTab.first,
      TestTab.second,
      TestTab.third,
    ]..forEach(TabType.append);

    expect(TabType.byValue(0), equals(tabs[0]));
    expect(TabType.byValue(1), equals(tabs[1]));
    expect(TabType.byValue(2), equals(tabs[2]));

    try {
      expect(TabType.byValue(3), throwsException);
    } on Exception catch (_) {}
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
