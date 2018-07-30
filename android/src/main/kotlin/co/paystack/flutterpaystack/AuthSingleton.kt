package co.paystack.flutterpaystack

/**
 * Created by Wilberforce on 29/07/18 at 06:00.
 */
class AuthSingleton private constructor() {
    var responseJson = "{\"status\":\"requery\",\"message\":\"Reaffirm Transaction Status on Server\"}"
    var url = ""

    companion object {
        val instance = AuthSingleton()
    }

}
