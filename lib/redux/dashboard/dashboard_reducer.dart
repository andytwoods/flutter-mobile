import 'package:redux/redux.dart';
import 'package:invoiceninja/redux/dashboard/dashboard_actions.dart';
import 'package:invoiceninja/redux/dashboard/dashboard_state.dart';

final dashboardReducer = combineReducers<DashboardState>([
  TypedReducer<DashboardState, DashboardLoadedAction>(_setLoadedDashboards),
  TypedReducer<DashboardState, DashboardNotLoadedAction>(_setNoDashboards),
]);

DashboardState _setLoadedDashboards(DashboardState dashboardState, DashboardLoadedAction action) {
  return dashboardState.rebuild((b) => b
      ..lastUpdated = DateTime.now().millisecondsSinceEpoch
      ..data.replace(action.data)
  );
}

DashboardState _setNoDashboards(DashboardState dashboardState, DashboardNotLoadedAction action) {
  return dashboardState.rebuild((b) => b
      ..data = null
  );
}