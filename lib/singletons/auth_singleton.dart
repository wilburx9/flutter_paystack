class AuthSingleton {
  var responseMap = {
    'status': 'requery',
    'message': 'Reaffirm Transaction Status on Server'
  };
  var url = '';

  static final AuthSingleton _singleton = AuthSingleton._internal();

  factory AuthSingleton() {
    return _singleton;
  }

  AuthSingleton._internal();
}
