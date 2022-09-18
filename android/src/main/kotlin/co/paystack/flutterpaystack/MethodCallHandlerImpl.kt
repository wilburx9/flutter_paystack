package co.paystack.flutterpaystack

import android.annotation.SuppressLint
import android.app.Activity
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class MethodCallHandlerImpl(messenger: BinaryMessenger, private val activity: Activity?) : MethodCallHandler {
    private var channel: MethodChannel? = null
    private var authDelegate: AuthDelegate? = null

    init {
        activity!!.let {
            authDelegate = AuthDelegate(it)
            channel = MethodChannel(messenger, channelName)
            channel?.setMethodCallHandler(this)
        }
    }

    @SuppressLint("HardwareIds")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDeviceId" -> {
                val deviceId = Settings.Secure.getString(activity?.contentResolver, Settings.Secure.ANDROID_ID)
                result.success("androidsdk_$deviceId")
            }
            "getAuthorization" -> {
                authDelegate?.handleAuthorization(result, call)
            }
            "getEncryptedData" -> {
                val encryptedData = Crypto.encrypt(call.argument<String>("stringData").toString())
                result.success(encryptedData)
            }

            else -> result.notImplemented()
        }
    }

    fun disposeHandler() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}

private const val channelName = "plugins.wilburt/flutter_paystack"