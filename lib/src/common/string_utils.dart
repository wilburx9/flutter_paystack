class StringUtils {
  static bool isEmpty(String? value) {
    return value == null || value.length < 1 || value.toLowerCase() == "null";
  }

  static bool isValidEmail(String? email) {
    if (isEmpty(email)) return false;
    RegExp regExp = new RegExp(_emailRegex);
    return regExp.hasMatch(email!);
  }

  ///  Method to nullify an empty String.
  ///  [value] - A string we want to be sure to keep null if empty
  ///  Returns null if a value is empty or null, otherwise, returns the value
  static String? nullify(String? value) {
    if (isEmpty(value)) {
      return null;
    }
    return value;
  }
}

const _emailRegex = r"[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
    "\\@" +
    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
    "(" +
    "\\." +
    "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
    ")+";
