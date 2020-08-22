package co.paystack.flutterpaystack

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry


class FlutterPaystackPlugin : FlutterPlugin, ActivityAware {

    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var methodCallHandler: MethodCallHandlerImpl? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginBinding = binding
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginBinding = null
    }

    private fun setupMethodHandler(messenger: BinaryMessenger?, activity: Activity) {
        methodCallHandler = MethodCallHandlerImpl(messenger, activity)
    }


    override fun onDetachedFromActivity() {
        methodCallHandler?.disposeHandler()
        methodCallHandler = null
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        setupMethodHandler(pluginBinding?.binaryMessenger, binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)

    companion object {

        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val plugin = FlutterPaystackPlugin()
            plugin.setupMethodHandler(registrar.messenger(), registrar.activity())
        }
    }

}