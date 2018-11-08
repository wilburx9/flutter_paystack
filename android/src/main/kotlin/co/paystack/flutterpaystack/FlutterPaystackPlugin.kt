package co.paystack.flutterpaystack

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterPaystackPlugin(val appContext: Context, val authDelegate: AuthDelegate) : MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_paystack")
      val authDelegate = AuthDelegate(activity = registrar.activity())
      val plugin = FlutterPaystackPlugin(appContext = registrar.context(), authDelegate = authDelegate)
      channel.setMethodCallHandler(plugin)
    }
  }

  @SuppressLint("HardwareIds")
  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
      "getDeviceId" -> {
        result.success("androidsdk_" + Settings.Secure.getString(appContext.contentResolver,
                Settings.Secure.ANDROID_ID))
      }
      "getUserAgent" -> {
        result.success("Android_" + Build.VERSION.SDK_INT + "_Paystack_" + BuildConfig.VERSION_NAME)
      }

      "getVersionCode" -> {
        result.success(BuildConfig.VERSION_CODE.toString())
      }

      "getAuthorization" -> {
        authDelegate.handleAuthorization(result, call)
      }
      "getEncryptedData" -> {
        val encryptedData = Crypto.encrypt(call.argument<String>("stringData").toString())
        result.success(encryptedData)
      }

      else -> result.notImplemented()
    }

  }

}