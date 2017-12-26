//@file:JvmName("FacebookPlugin")

package io.flutter.plugins.facebook

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.os.Bundle
import com.facebook.*
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.*

private val channelName  = "plugins.flutter.io/facebook"
private val methodLogInWithPublishPermissions: String = "logInWithPublishPermissions"
private val methodLogInWithReadPermissions: String = "logInWithReadPermissions"
private val methodLogOut: String = "logOut"
private val methodIsLoggedIn: String = "isLoggedIn"
private val methodGetAccessToken: String = "getAccessToken"
private val methodInitSdk: String = "initSdk"

public class FacebookPlugin : MethodCallHandler {

    private var registrar: PluginRegistry.Registrar? = null
    private val activityHandler: ActivityHandler = ActivityHandler()
    private var application: Application? = null
    private var activity: Activity? = null

    private var callbackManager: CallbackManager? = null
    private var methodResult: Result? = null

    private var loginManager: LoginManager? = null
    private var permissions: Array<String> = arrayOf("public_profile","email")
    private var fields: String = "id,name,email"

    private var initialized: Boolean = false

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar){
            var channel = MethodChannel(registrar.messenger(), channelName)
            channel.setMethodCallHandler(FacebookPlugin(registrar))
        }
    }

    private constructor(registrar: PluginRegistry.Registrar) {

        this.registrar = registrar
        this.application = registrar.context() as Application
        this.activity = registrar.activity()

        this.application!!.registerActivityLifecycleCallbacks(activityHandler)
        registrar.addActivityResultListener(activityHandler)

    }

    override fun onMethodCall(call: MethodCall?, result: Result?) {

        when(call!!.method){
            methodLogInWithPublishPermissions -> {
                methodResult = result
                readArgs(call)
                logInWithPublishPermissions()
            }
            methodLogInWithReadPermissions -> {
                methodResult = result
                readArgs(call)
                logInWithReadPermissions()
            }
            methodLogOut -> {
                methodResult = result
                logOut()
            }
            methodIsLoggedIn -> {
                methodResult = result
                isLoggedIn()
            }
            methodGetAccessToken -> {
                methodResult = result
                getAccessToken()
            }
            methodInitSdk -> {
                methodResult = result
                initSdk()
            }
            else -> {
                result!!.notImplemented()
            }
        }
    }

    fun readArgs(call: MethodCall){

        if (call.hasArgument("params")) {
            var params = call.argument<Map<String, String>>("params")

            if (params!!["permissions"] != null) {
                var list = params!!["permissions"] as String
                permissions = list.split(",").toTypedArray()
            }

            if (params!!["fields"] != null) {
                fields = params!!["fields"] as String
            }
        }
    }

    fun initSdk(){

        if(!this.initialized) {
            try {
                FacebookSdk.sdkInitialize(this.application)
                this.loginManager = LoginManager.getInstance();
                this.callbackManager = CallbackManager.Factory.create()
                this.loginManager!!.registerCallback(this.callbackManager, LoginCallback())
                this.initialized = true
                this.methodResult!!.success(mapOf("status" to "success"))
            }catch (error: Exception){
                var data = mapOf(
                        "status" to "error",
                        "message" to error!!.message
                )
                this.methodResult!!.success(data)
            }
        }

    }

    fun logInWithReadPermissions(){
        this.loginManager!!.logInWithReadPermissions(this.activity, Arrays.asList("public_profile"))
    }

    fun logInWithPublishPermissions(){
        this.loginManager!!.logInWithPublishPermissions(this.activity, Arrays.asList("public_profile"))
    }

    fun logOut() {
        this.loginManager!!.logOut()
        this.methodResult!!.success(true)

    }

    fun isLoggedIn() {
        var loggedIn = AccessToken.getCurrentAccessToken() != null
        this.methodResult!!.success(loggedIn)
    }

    fun getAccessToken() {
        var current = AccessToken.getCurrentAccessToken()
        if(current != null) {
            var accessToken = AccessToken.getCurrentAccessToken()
            this.methodResult!!.success({
              "token" to accessToken.token,
              "userId" to accessToken.userId
            })
        } else {
            this.methodResult!!.success(null)
        }
    }


    inner class ActivityHandler : Application.ActivityLifecycleCallbacks,
        PluginRegistry.ActivityResultListener{

        override fun onActivityPaused(activity: Activity?) {

        }

        override fun onActivityResumed(activity: Activity?) {

        }

        override fun onActivityStarted(activity: Activity?) {

        }

        override fun onActivityDestroyed(activity: Activity?) {

        }

        override fun onActivitySaveInstanceState(activity: Activity?, bundle: Bundle?) {

        }

        override fun onActivityStopped(activity: Activity?) {

        }

        override fun onActivityCreated(activity: Activity?, bundle: Bundle?) {

        }

        override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {

            if(FacebookSdk.isFacebookRequestCode(requestCode))
                callbackManager!!.onActivityResult(requestCode, resultCode, intent)

            return true
        }
    }

    inner class LoginCallback: FacebookCallback<LoginResult> {

        override fun onSuccess(result: LoginResult?) {
            var data = mapOf(
                    "status" to "success",
                    "token" to result!!.accessToken.token,
                    "userId" to result!!.accessToken.userId
            )
            methodResult!!.success(data)
        }

        override fun onCancel() {
            var data = mapOf(
                    "status" to "cancel"
            )
            methodResult!!.success(data)
        }

        override fun onError(error: FacebookException?) {
            var data = mapOf(
                    "status" to "error",
                    "message" to error!!.message
            )
            methodResult!!.success(data)
        }

    }
}
