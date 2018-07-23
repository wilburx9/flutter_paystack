package co.paystack.paystackflutter

import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class PaystackFlutterPlugin(): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val channel = MethodChannel(registrar.messenger(), "paystack_flutter")
      channel.setMethodCallHandler(PaystackFlutterPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result): Unit {
    when(call.method) {
       "getPlatformVersion" -> {
           result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        "getDeviceId" -> {
            result.success("androidsdk_" + Settings.Secure.getString(App.appContext.contentResolver,
                    Settings.Secure.ANDROID_ID))
        }
        else -> result.notImplemented()
    }

  }
}
