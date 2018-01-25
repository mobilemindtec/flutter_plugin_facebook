//@file:JvmName("FacebookPlugin")

package io.flutter.plugins.facebook

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import com.facebook.*
import com.facebook.GraphRequest.newGraphPathRequest
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import com.facebook.share.Sharer
import com.facebook.share.model.*
import com.facebook.share.widget.AppInviteDialog
import com.facebook.share.widget.ShareDialog
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.*
import org.json.JSONObject
import org.json.JSONArray
import java.util.ArrayList
import org.json.JSONException
import java.util.HashMap



private val channelName  = "plugins.flutter.io/facebook"
private val methodLogInWithPublishPermissions: String = "logInWithPublishPermissions"
private val methodLogInWithReadPermissions: String = "logInWithReadPermissions"
private val methodLogOut: String = "logOut"
private val methodIsLoggedIn: String = "isLoggedIn"
private val methodGetAccessToken: String = "getAccessToken"
private val methodInitSdk: String = "initSdk"

private val methodIsinstalled: String = "isInstalled"
private val methodCanInvite: String = "canInvite"
private val methodInvite: String = "invite"

private val methodRequestGraphPath: String = "requestGraphPath"
private val methodRequestMe: String = "requestMe"

private val methodShareLink: String = "shareLink"
private val methodSharePhotos: String = "sharePhotos"
private val methodShareVideo: String = "shareVideo"

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

    private var appLinkUrl: String = ""
    private var appPreviewImageUrl: String = ""
    private var graphRequestPath: String = ""
    private var graphRequestParameters: MutableMap<String, String> = mutableMapOf()
    private var shareLinkUrl: String = ""
    private var shareVideoUrl: String = ""
    private var sharePhotosUrl: MutableList<String> = mutableListOf()


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
            methodIsinstalled -> {
                methodResult = result
                isInstalled()
            }
            methodCanInvite -> {
                methodResult = result
                canInvite()
            }
            methodInvite -> {
                methodResult = result
                invite()
            }
            methodRequestGraphPath -> {
                methodResult = result
                requestGraphPath()
            }
            methodRequestMe -> {
                methodResult = result
                requestGraphMe()
            }
            methodShareLink -> {
                methodResult = result
                shareLink()
            }
            methodSharePhotos -> {
                methodResult = result
                sharePhotos()
            }
            methodShareVideo -> {
                methodResult = result
                shareVideo()
            }
            else -> {
                result!!.notImplemented()
            }
        }
    }

    fun readArgs(call: MethodCall){

        if (call.hasArgument("params") && call.argument<Object>("params") is Map<*,*>) {
            var params = call.argument<Map<String, Any>>("params")

            if (params!!["permissions"] != null) {
                var list = params!!["permissions"] as String
                permissions = list.split(",").toTypedArray()
            }

            if (params!!["fields"] != null) {
                fields = params!!["fields"] as String
            }

            if (params!!["appLinkUrl"] != null) {
                this.appLinkUrl = params!!["appLinkUrl"] as String
            }

            if (params!!["appPreviewImageUrl"] != null) {
                this.appPreviewImageUrl = params!!["appPreviewImageUrl"] as String
            }

            if (params!!["graphRequestPath"] != null) {
                this.graphRequestPath = params!!["graphRequestPath"] as String
            }

            if (params!!["graphRequestParameters"] != null && params!!["graphRequestParameters"] is Map<*,*>) {
                var map = params!!["graphRequestParameters"] as Map<String, String>
                graphRequestParameters.clear()
                for ((key, value) in map) {
                graphRequestParameters.put(key, value)
            }
            }

            if (params!!["videoUrl"] != null) {
                this.shareVideoUrl = params!!["videoUrl"] as String
            }

            if (params!!["linkUrl"] != null) {
                this.shareLinkUrl = params!!["linkUrl"] as String
            }

            if (params!!["sharePhotosUrl"] != null && params!!["sharePhotosUrl"] is List<*>) {
                var photos = params!!["sharePhotosUrl"] as List<String>
                this.sharePhotosUrl.clear()

                for (it in photos) {
                    this.sharePhotosUrl.add(it)
                }
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
            this.methodResult!!.success(mapOf(
              "token" to accessToken.token,
              "userId" to accessToken.userId
            ))
        } else {
            this.methodResult!!.success(null)
        }
    }

    fun isInstalled(){
        var installed = isPackageFound("com.facebook.orca") || isPackageFound("com.facebook.katana") || isPackageFound("com.facebook.android")
        this.methodResult!!.success(installed)
    }

    fun isPackageFound(targetPackage: String) : Boolean {

        var packageManager = this.activity!!.packageManager;

        try {
            var info = packageManager.getPackageInfo(targetPackage, PackageManager.GET_META_DATA);
        } catch(e: Exception) {
            return false
        }

        return true
    }

    fun canInvite() {
        var can = AppInviteDialog.canShow()
        this.methodResult!!.success(can)
    }

    fun invite() {
        if (AppInviteDialog.canShow()) {
            var content = AppInviteContent.Builder()
                    .setApplinkUrl(this.appLinkUrl)
                    .setPreviewImageUrl(this.appPreviewImageUrl)
                    .build();

            var appInviteDialog = AppInviteDialog(activity)

            val callback = object : FacebookCallback<AppInviteDialog.Result> {

                override fun  onSuccess(result: AppInviteDialog.Result) {
                    methodResult!!.success(mapOf("status" to "success"))
                }
                override fun  onCancel() {
                    methodResult!!.success(mapOf("status" to "cancel"))
                }
                override fun  onError(e: FacebookException) {
                    methodResult!!.success(mapOf("status" to "error", "message" to e.message))

                }
            }

            appInviteDialog.registerCallback(this.callbackManager, callback)
            appInviteDialog.show(content)

        }else{
            this.methodResult!!.success(mapOf("status" to "success"))
        }
    }

    fun shareContent(content: ShareContent<*, *>){

        var shareDialog = ShareDialog(this.activity)

        var shareCallback = object : FacebookCallback<Sharer.Result> {
            override fun  onSuccess(result: Sharer.Result) {
                methodResult!!.success(mapOf("status" to "success"))
            }
            override fun  onCancel() {
                methodResult!!.success(mapOf("status" to "cancel"))
            }
            override fun  onError(e: FacebookException) {
                methodResult!!.success(mapOf("status" to "error", "message" to e.message))
            }
        }

        shareDialog.registerCallback(this.callbackManager, shareCallback);
        shareDialog.show(content)
    }

    fun shareVideo() {

        var builder = ShareVideoContent.Builder()
        var video = ShareVideo.Builder()
                .setLocalUrl(Uri.parse(this.shareVideoUrl))
                .build()
        builder.setVideo(video)

        this.shareContent(builder.build())
    }

    fun sharePhotos() {

        var builder = SharePhotoContent.Builder()

        for(it in this.sharePhotosUrl){
            var photo = SharePhoto.Builder()
                    .setImageUrl(Uri.parse(it))
            builder.addPhoto(photo.build())
        }

        this.shareContent(builder.build())
    }

    fun shareLink() {

        var builder = ShareLinkContent.Builder()
        builder.setContentUrl(Uri.parse(this.shareLinkUrl))
        this.shareContent(builder.build())
    }

    fun requestGraphMe(){
        this.graphPathRequest("me", mapOf("fields" to this.fields))
    }

    fun requestGraphPath(){
        this.graphPathRequest(this.graphRequestPath, this.graphRequestParameters)
    }


    fun graphPathRequest(graphPath: String, parameters: Map<String, String>) {

        var accessToken = AccessToken.getCurrentAccessToken()
        var callback = GraphRequest.Callback { response ->
            if(response?.error != null){
                methodResult!!.success(mapOf("status" to "error", "message" to response?.error.errorMessage))
            } else {

                var result: Any? = null

                if(response.jsonObject != null){
                    result = toMap(response.jsonObject)
                } else if (response.jsonArray != null){
                    result = toList(response.jsonArray)
                }

                methodResult!!.success(mapOf("status" to "success", "result" to result))
            }
        }


        var request = newGraphPathRequest(accessToken, graphPath, callback)

        if(!parameters.isEmpty()) {

            var bundle = Bundle()
            for((key, value) in parameters){
                bundle.putString(key, value)
            }

            request.setParameters(bundle);
        }

        request.executeAsync()
    }


    fun toMap(jsonobj: JSONObject): Map<String, Any> {
        val map = HashMap<String, Any>()
        val keys = jsonobj.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            var value = jsonobj.get(key)
            if (value is JSONArray) {
                value = toList(value)
            } else if (value is JSONObject) {
                value = toMap(value)
            }
            map[key] = value
        }
        return map
    }

    fun toList(array: JSONArray): List<Any> {
        val list = ArrayList<Any>()
        for (i in 0 until array.length()) {
            var value = array.get(i)
            if (value is JSONArray) {
                value = toList(value)
            } else if (value is JSONObject) {
                value = toMap(value)
            }
            list.add(value)
        }
        return list
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
