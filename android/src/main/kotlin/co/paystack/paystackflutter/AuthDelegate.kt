package co.paystack.paystackflutter

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * Created by Wilberforce on 26/07/18 at 18:35.
 */
class AuthDelegate(private val activity: Activity) : PluginRegistry.ActivityResultListener {

    private var pendingResult: MethodChannel.Result? = null

    companion object {
        const val AUTHORIZATION_KEY = 666
        const val WEB_URL = "co.paystack.paystackflutter.AuthDelegate.WebUrl"
        const val WEB_RESPONSE = "co.paystack.paystackflutter.AuthDelegate.WebResponse"
        const val DEFAULT_RESPONSE = "{\"status\":\"requery\",\"message\":\"Reaffirm Transaction Status on Server\"}"
    }

    fun handleAuthorization(pendingResult: MethodChannel.Result, methodCall: MethodCall) {
        if (!setPendingResult(pendingResult)) {
            finishWithPendingAuthError()
            return
        }
        val intent = Intent()
        intent.putExtra(WEB_URL, methodCall.argument<String>("authUrl"))
        activity.startActivityForResult(intent, AUTHORIZATION_KEY)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return when (requestCode) {
            AUTHORIZATION_KEY -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val webResponse = data.getStringExtra(WEB_RESPONSE)
                    finishWithSuccess(webResponse)
                } else {
                    finishWithSuccess(DEFAULT_RESPONSE)
                }
                true
            }
            else -> false
        }
    }

    private fun setPendingResult(result: MethodChannel.Result): Boolean {
        return if (pendingResult == null) {
            pendingResult = result
            true
        } else {
            false
        }
    }

    private fun finishWithSuccess(webResponse: String) {
        pendingResult?.success(webResponse)
        clearResult()
    }

    private fun finishWithPendingAuthError() {
        finishWithError("pending_authorization", "Authentication is already pending")
    }

    private fun finishWithError(errorCode: String, errorMessage: String) {
        pendingResult?.error(errorCode, errorMessage, null)
        clearResult()
    }

    private fun clearResult() {
        pendingResult = null
    }
}