import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

/// A service accessor for the Tide services to get an instance to an object.
typedef TideServicesAccessor = GetIt;

enum TidePosition { left, top, center, right, bottom }

class TideId extends Equatable {
  const TideId(this.id);

  final String id;

  @override
  List<Object?> get props => [id];

  @override
  String toString() {
    return id;
  }

  factory TideId.uniqueId() {
    // Generate a v4 (random) UUID
    String uniqueId = _uuid.v4();
    return TideId(uniqueId);
  }

  static String get uuid => _uuid.v4();

  static const TideId empty = TideId('');
}

class TideRegistry {}

const _uuid = Uuid();

class TideLogicalKeyIntent extends Intent {
  const TideLogicalKeyIntent(this.key);

  final LogicalKeyboardKey key;
}
