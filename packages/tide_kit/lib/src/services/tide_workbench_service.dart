import '../tide.dart';
import '../tide_core.dart';
import 'tide_workbench_layout_service.dart';

/// The workbench service that is created when [Tide] is initialized.
/// To use a different workbench service, create a class that extends
/// [TideWorkbenchService] and register it before [Tide] is initialized.
/// There should only be one workbench service.
class TideWorkbenchService {
  TideWorkbenchService() {
    Tide.log("Tide: TideWorkbenchService created");
    accessor = TideServicesAccessor.asNewInstance();
    accessor.registerSingleton(TideWorkbenchLayoutService(accessor: accessor));

    builderRegistery.register(const TideId(''), () {});
  }

  final TideBuilderRegistery builderRegistery = TideBuilderRegistery();

  /// The accessor instance for this workbench.
  late final TideServicesAccessor accessor;

  TideWorkbenchLayoutService get layoutService =>
      accessor.get<TideWorkbenchLayoutService>();
}

class TideBuilderRegistery {
  TideBuilderRegistery() {
    Tide.log("Tide: TideBuilderRegistery created");
  }

  final Map<TideId, Function> _builders = {};

  /// Registers a builder callback with the given [id].
  void register(TideId id, Function builder) {
    _builders[id] = builder;
    Tide.log("Tide: Registered builder for $id");
  }

  /// Unregisters the builder callback associated with the given [id].
  void unregister(TideId id) {
    if (_builders.containsKey(id)) {
      _builders.remove(id);
      Tide.log("Tide: Unregistered builder for $id");
    } else {
      Tide.log("Tide: No builder found to unregister for $id");
    }
  }

  /// Retrieves the builder callback associated with the given [id].
  /// Returns null if no builder is found for the [id].
  Function? getBuilder(TideId id) {
    return _builders[id];
  }

  /// Checks if a builder is registered for the given [id].
  bool hasBuilder(TideId id) {
    return _builders.containsKey(id);
  }
}
