package io.aelion.app

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val statusText = findViewById<TextView>(R.id.statusText)
        val detailsText = findViewById<TextView>(R.id.detailsText)

        statusText.text = nativeStatus()
        detailsText.text = nativeDetails()
    }

    private external fun nativeStatus(): String
    private external fun nativeDetails(): String
    private external fun nativeExecuteCommand(command: String): String

    companion object {
        init {
            System.loadLibrary("aelion_android")
        }
    }
}
