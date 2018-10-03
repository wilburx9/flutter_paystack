import 'package:meta/meta.dart';

class BaseApiService {
  final Map<String, String> headers;
  final String baseUrl;

  BaseApiService({@required this.headers, @required this.baseUrl});
}
