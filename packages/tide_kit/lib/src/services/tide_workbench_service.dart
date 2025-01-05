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
  }

  /// The accessor instance for this workbench.
  late final TideServicesAccessor accessor;

  TideWorkbenchLayoutService get layoutService =>
      accessor.get<TideWorkbenchLayoutService>();
}
