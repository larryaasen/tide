import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

/// A service accessor for the Tide services.
typedef TideServicesAccessor = GetIt;

enum TidePosition { left, top, center, right, bottom }

class TideId {
  const TideId(this.id);

  final String id;

  @override
  String toString() {
    return id;
  }

  factory TideId.uniqueId() {
    // Generate a v4 (random) UUID
    String uniqueId = _uuid.v4();
    return TideId(uniqueId);
  }

  static const TideId empty = TideId('');
}

class TideRegistry {}

const _uuid = Uuid();
