package co.paystack.flutterpaystack

import android.app.Activity
import android.content.Intent
import android.os.AsyncTask
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/**
 * Created by Wilberforce on 26/07/18 at 18:35.
 */
class AuthDelegate(private val activity: Activity) {

    private var pendingResult: MethodChannel.Result? = null

    fun handleAuthorization(pendingResult: MethodChannel.Result, methodCall: MethodCall) {
        if (!setPendingResult(pendingResult)) {
            finishWithPendingAuthError()
            return
        }
        AuthAsyncTask(WeakReference(activity), WeakReference(onAuthCompleteListener))
                .execute(methodCall.argument("authUrl"))
    }

    private val onAuthCompleteListener = object : OnAuthCompleteListener {
        override fun onComplete(webResponse: String) {
            finishWithSuccess(webResponse)
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
        Log.e("AuthDelegate", "finishWithSuccess (line 44): $webResponse")
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

private class AuthAsyncTask(val activityRef: WeakReference<Activity>, val listenerRef:
WeakReference<OnAuthCompleteListener>) : AsyncTask<String,
        Void, String>() {


    override fun doInBackground(vararg params: String): String {
        val authSingleton = AuthSingleton.instance
        authSingleton.url = params[0]
        Log.e("AuthAsyncTask", "doInBackground (line 70): ${authSingleton.url}")
        val activity = activityRef.get()
        if (activity != null) {
            val i = Intent(activity, AuthActivity::class.java)
            activity.startActivity(i)

            synchronized(authSingleton) {
                try {
                    (authSingleton as Object).wait()
                } catch (e: InterruptedException) {
                    return authSingleton.responseJson
                }

            }
        }

        return authSingleton.responseJson
    }

    override fun onPostExecute(responseJson: String) {
        super.onPostExecute(responseJson)
        listenerRef.get()?.onComplete(responseJson)
    }
}

interface OnAuthCompleteListener {
    fun onComplete(webResponse: String) {

    }
}
