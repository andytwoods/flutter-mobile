import 'package:redux/redux.dart';
import 'package:invoiceninja/redux/auth/auth_actions.dart';
import 'package:invoiceninja/redux/app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invoiceninja/data/file_storage.dart';
import 'package:invoiceninja/data/repositories/auth_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:invoiceninja/redux/company/company_actions.dart';

List<Middleware<AppState>> createStoreAuthMiddleware([
  AuthRepository repository = const AuthRepository(
    fileStorage: const FileStorage(
      '__invoiceninja__',
      getApplicationDocumentsDirectory,
    ),
  ),
]) {
  final loginInit = _createLoginInit();
  final loginRequest = _createLoginRequest(repository);

  return [
    TypedMiddleware<AppState, LoadUserLogin>(loginInit),
    TypedMiddleware<AppState, UserLoginRequest>(loginRequest),
  ];
}

_saveAuthLocal(action) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('email', action.email);
  prefs.setString('url', action.url);

  if (action.password == 'password') {
    prefs.setString('password', action.password);
  }
  if (action.secret == 'password') {
    prefs.setString('password', action.secret);
  }
}

_loadAuthLocal(Store<AppState> store, action) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String email = prefs.getString('email');
  String password = prefs.getString('password');
  String url = prefs.getString('url');
  String secret = prefs.getString('secret');

  store.dispatch(UserLoginLoaded(email, password, url, secret));
}


Middleware<AppState> _createLoginInit() {
  return (Store<AppState> store, action, NextDispatcher next) {

    _loadAuthLocal(store, action);
    
    next(action);
  };
}

Middleware<AppState> _createLoginRequest(AuthRepository repository) {
  return (Store<AppState> store, action, NextDispatcher next) {

    repository.login(action.email, action.password, action.url).then(
        (data) {
          _saveAuthLocal(action);

          for (int i=0; i<data.length; i++) {
            store.dispatch(SelectCompany(i+1));
            store.dispatch(LoadCompanySuccess(data[i]));
          }

          store.dispatch(SelectCompany(1));
          store.dispatch(UserLoginSuccess());

          action.completer.complete(null);
        }
    ).catchError((error) {
      store.dispatch(UserLoginFailure(error));
    });

    next(action);
  };
}

