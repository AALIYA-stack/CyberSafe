import 'package:flutter_test/flutter_test.dart';

import 'package:cybersafe/app.dart';

void main() {
testWidgets(
'CyberSafe app starts successfully',
(WidgetTester tester) async {
// Build CyberSafe application.
await tester.pumpWidget(
const CyberSafeApp(),
);

// Allow initial animations/build to complete.
await tester.pump();

// App should render without throwing an exception.
expect(
find.byType(CyberSafeApp),
findsOneWidget,
);
},
);
}
