class StringUtils {
  static bool isEmpty(String value) {
    return value == null || value.length < 1 || value.toLowerCase == "null";
  }

  static bool isValidEmail(String email) {
    String p =
        r"[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
            "\\@" +
            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
            "(" +
            "\\." +
            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
            ")+";
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(email);
  }
}
