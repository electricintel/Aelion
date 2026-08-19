package io.aelion.app

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    private val historyLines = mutableListOf<String>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val statusText = findViewById<TextView>(R.id.statusText)
        val detailsText = findViewById<TextView>(R.id.detailsText)
        val commandInput = findViewById<EditText>(R.id.commandInput)
        val runButton = findViewById<Button>(R.id.runButton)
        val historyText = findViewById<TextView>(R.id.historyText)
        val historyScroll = findViewById<ScrollView>(R.id.historyScroll)

        statusText.text = nativeStatus()
        detailsText.text = nativeDetails()

        runButton.setOnClickListener {
            val command = commandInput.text.toString().trim()
            if (command.isEmpty()) {
                return@setOnClickListener
            }

            val response = nativeExecuteCommand(command)
            historyLines += "> $command"
            historyLines += response
            historyLines += ""
            historyText.text = historyLines.joinToString("\n")
            commandInput.text?.clear()

            historyScroll.post {
                historyScroll.fullScroll(ScrollView.FOCUS_DOWN)
            }
        }
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
