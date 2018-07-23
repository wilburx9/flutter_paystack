package co.paystack.paystackflutter

import android.app.Application
import android.content.Context

/**
 * Created by Wilberforce on 23/07/18 at 19:21.
 */
class App: Application() {
    override fun onCreate() {
        super.onCreate()
        appContext = applicationContext
    }
    companion object {
        lateinit var appContext: Context
            private set
    }
}