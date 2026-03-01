package com.example.nativ

import android.content.*
import android.hardware.*
import android.net.*
import android.os.*
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val BATTERY_CHANNEL = "battery_channel"
    private val BATTERY_EVENT_CHANNEL = "battery_Event_channel"
    private val NETWORK_EVENT_CHANNEL = "network_Event_channel"
    private val GYROSCOPE_EVENT_CHANNEL = "gyroo_scoope"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 🔹 MethodChannel (Battery Level)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getBatteryLevel") {
                    val batteryLevel = getBatteryLevel()
                    result.success(batteryLevel)
                } else {
                    result.notImplemented()
                }
            }

        // 🔹 EventChannel (Battery Status)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_EVENT_CHANNEL)
            .setStreamHandler(BatteryStreamHandler(this))

        // 🔹 EventChannel (Network Status)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, NETWORK_EVENT_CHANNEL)
            .setStreamHandler(NetworkStreamHandler(this))

        // 🔹 EventChannel (Gyroscope)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, GYROSCOPE_EVENT_CHANNEL)
            .setStreamHandler(GyroscopeStreamHandler(this))
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }
}


class BatteryStreamHandler(private val context: Context) : EventChannel.StreamHandler {

    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1)

                val batteryStatus = when (status) {
                    BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
                    BatteryManager.BATTERY_STATUS_FULL -> "Full"
                    BatteryManager.BATTERY_STATUS_DISCHARGING -> "Discharging"
                    else -> "Unknown"
                }

                events?.success(batteryStatus)
            }
        }
        context.registerReceiver(receiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    }

    override fun onCancel(arguments: Any?) {
        receiver?.let { context.unregisterReceiver(it) }
        receiver = null
    }
}



class NetworkStreamHandler(private val context: Context) : EventChannel.StreamHandler {

    private var connectivityManager: ConnectivityManager? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {

        connectivityManager =
            context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        networkCallback = object : ConnectivityManager.NetworkCallback() {

            override fun onAvailable(network: Network) {
                events?.success(getConnectionType())
            }

            override fun onLost(network: Network) {
                events?.success("No Internet")
            }
        }

        connectivityManager?.registerDefaultNetworkCallback(networkCallback!!)
    }

    override fun onCancel(arguments: Any?) {
        networkCallback?.let {
            connectivityManager?.unregisterNetworkCallback(it)
        }
    }

    private fun getConnectionType(): String {
        val activeNetwork = connectivityManager?.activeNetwork ?: return "No Internet"
        val capabilities = connectivityManager?.getNetworkCapabilities(activeNetwork)
            ?: return "No Internet"

        return when {
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "WiFi"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "Mobile Data"
            else -> "Other"
        }
    }
}


class GyroscopeStreamHandler(context: Context) :
    EventChannel.StreamHandler, SensorEventListener {

    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

    private val gyroscopeSensor: Sensor? =
        sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        gyroscopeSensor?.let {
            sensorManager.registerListener(
                this,
                it,
                SensorManager.SENSOR_DELAY_NORMAL
            )
        }
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        eventSink = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_GYROSCOPE) {

            val data = mapOf(
                "x" to event.values[0],
                "y" to event.values[1],
                "z" to event.values[2]
            )

            eventSink?.success(data)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
