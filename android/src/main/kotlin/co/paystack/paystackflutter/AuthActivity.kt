package co.paystack.paystackflutter

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import kotlinx.android.synthetic.main.co_paystack_android____activity_auth.*

const val API_URL = "https://standard.paystack.co/"

class AuthActivity : Activity() {

    private var responseJson: String? = null
    private lateinit var webUrl: String

    companion object {
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.co_paystack_android____activity_auth)
        webUrl = intent.getStringExtra(AuthDelegate.WEB_URL)
        title = "Authorize your card"
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setup()
    }

    fun handleResponse() {
        if (responseJson == null) {
            responseJson = AuthDelegate.DEFAULT_RESPONSE
        }
        val intent = Intent()
        intent.putExtra(AuthDelegate.WEB_RESPONSE, responseJson)
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

    @SuppressLint("SetJavaScriptEnabled", "AddJavascriptInterface")
    private fun setup() {
        webView!!.keepScreenOn = true

        abstract class AuthResponseJI {
            abstract fun processContent(aContent: String)
        }

        class AuthResponseLegacyJI : AuthResponseJI() {
            override fun processContent(aContent: String) {
                responseJson = aContent
                handleResponse()
            }
        }

        class AuthResponse17JI : AuthResponseJI() {

            @JavascriptInterface
            override fun processContent(aContent: String) {
                responseJson = aContent
                handleResponse()
            }
        }

        class JIFactory {

            val ji: AuthResponseJI
                get() = if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                    AuthResponse17JI()
                } else {
                    AuthResponseLegacyJI()
                }
        }


        webView!!.settings.javaScriptEnabled = true
        webView!!.settings.javaScriptCanOpenWindowsAutomatically = true
        webView!!.addJavascriptInterface(JIFactory().ji, "INTERFACE")
        webView!!.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String) {
                if (url.contains(API_URL + "charge/three_d_response/")) {
                    view.loadUrl("javascript:window.INTERFACE.processContent(document.getElementById('return').innerText);")
                }
            }

            override fun onLoadResource(view: WebView, url: String) {
                super.onLoadResource(view, url)
            }
        }

        webView!!.loadUrl(webUrl)
    }

    public override fun onDestroy() {
        super.onDestroy()
        if (webView != null) {
            webView!!.stopLoading()
            webView!!.removeJavascriptInterface("INTERFACE")
        }
    }

}
