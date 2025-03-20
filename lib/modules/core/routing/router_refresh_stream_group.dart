import 'dart:async';

import 'package:flutter/foundation.dart';

class GoRouterRefreshStreamGroup extends ChangeNotifier {
  final List<Stream> _streams;
  final List<StreamSubscription> _subscriptions;

  GoRouterRefreshStreamGroup(this._streams) : _subscriptions = [] {
    for (var stream in _streams) {
      _subscriptions.add(
        stream.listen((_) => notifyListeners())
      );
    }
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
} 