package io.getstream.encryptedchat

import androidx.annotation.NonNull
import com.virgilsecurity.android.common.exceptions.RegistrationException
import com.virgilsecurity.android.ethree.kotlin.callback.OnGetTokenCallback
import com.virgilsecurity.android.ethree.kotlin.interaction.EThree
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.*
import kotlin.coroutines.CoroutineContext

class MainActivity : FlutterActivity(), CoroutineScope by MainScope() {
  private val CHANNEL = "io.getstream/virgil"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "initVirgil") {
        initVirgil(call.argument<String>("token")!!, result)
      }
    }
  }

  private fun initVirgil(token: String, result: MethodChannel.Result) {
    val eThree = EThree.initialize(context, object : OnGetTokenCallback {
      override fun onGetToken() = token
    }).get()

    launch(Dispatchers.IO) {
      try {
        eThree.register().execute()
      } catch (e: RegistrationException) {
        // already registered
      }
      launch(Dispatchers.Main) {
        result.success(true)
      }
    }
  }
}
