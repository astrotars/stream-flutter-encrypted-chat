package io.getstream.encryptedchat

import androidx.annotation.NonNull
import com.virgilsecurity.android.common.exceptions.RegistrationException
import com.virgilsecurity.android.ethree.kotlin.callback.OnGetTokenCallback
import com.virgilsecurity.android.ethree.kotlin.interaction.EThree
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity(), CoroutineScope by MainScope() {
  private val CHANNEL = "io.getstream/virgil"
  private var eThree: EThree? = null

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "initVirgil" -> {
          initVirgil(call.argument<String>("token")!!, result)
        }
        "encrypt" -> {
          encrypt(
            call.argument<String>("otherUser")!!,
            call.argument<String>("text")!!,
            result
          )
        }
        "decryptMine" -> {
          decryptMine(
            call.argument<String>("text")!!,
            result
          )
        }
        "decryptTheirs" -> {
          decryptTheirs(
            call.argument<String>("text")!!,
            call.argument<String>("otherUser")!!,
            result
          )
        }
      }
    }
  }

  private fun initVirgil(token: String, result: MethodChannel.Result) {
    eThree = EThree.initialize(context, object : OnGetTokenCallback {
      override fun onGetToken() = token
    }).get()

    launch(Dispatchers.IO) {
      try {
        eThree!!.register().execute()
      } catch (e: RegistrationException) {
        // already registered
      }
      launch(Dispatchers.Main) {
        result.success(true)
      }
    }
  }

  private fun encrypt(otherUser: String, text: String, result: MethodChannel.Result) {
    launch(Dispatchers.IO) {
      val publicKeys = eThree!!.lookupPublicKeys(otherUser).get()
      val encryptedText = eThree!!.encrypt(text, publicKeys)

      launch(Dispatchers.Main) {
        result.success(encryptedText)
      }
    }
  }

  private fun decryptMine(text: String, result: MethodChannel.Result) {
    result.success(eThree!!.decrypt(text))
  }

  private fun decryptTheirs(text: String, otherUser: String, result: MethodChannel.Result) {
    launch(Dispatchers.IO) {
      val publicKey = eThree!!.lookupPublicKeys(otherUser).get()[otherUser]
      launch(Dispatchers.Main) {
        result.success(eThree!!.decrypt(text, publicKey))
      }
    }
  }
}
