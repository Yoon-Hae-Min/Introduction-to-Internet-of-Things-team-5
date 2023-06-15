package kr.ac.gachon.user

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.animation.Animation
import android.view.animation.RotateAnimation
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import kr.ac.gachon.user.config.ApplicationClass
import kr.ac.gachon.user.config.BaseActivity
import kr.ac.gachon.user.databinding.ActivityNavigationBinding
import kr.ac.gachon.user.model.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*
import kotlin.properties.Delegates


class NavigationActivity : BaseActivity<ActivityNavigationBinding>(ActivityNavigationBinding::inflate), SensorEventListener {
    private var mSensorManager: SensorManager? = null
    private var mAccelerometer: Sensor? = null
    private var mMagnetometer: Sensor? = null
    private val mLastAccelerometer = FloatArray(3)
    private val mLastMagnetometer = FloatArray(3)
    private val mOrientationDegrees = FloatArray(3)
    private var mCurrentRotateValue = 0f
    private lateinit var wifiManager: WifiManager
    private var bssid by Delegates.notNull<String>()
    private var ssid by Delegates.notNull<String>()
    private var rssi by Delegates.notNull<Int>()
    private var previousLocation: String = "0"
    private var currentLocation: String = "1"
    private var R = FloatArray(9)
    private lateinit var destination: String
    private var currentFixedAngle: Float = 0F
    private lateinit var timer: Timer

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        destination = intent.getStringExtra("dest").toString()
        binding.tvDestinationContent.text = destination

        // Get default sensors
        mSensorManager = getSystemService(SENSOR_SERVICE) as SensorManager?
        mAccelerometer = mSensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        mMagnetometer = mSensorManager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
    }

    override fun onResume() {
        super.onResume()
        // Register sensor
        mSensorManager?.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_UI)
        mSensorManager?.registerListener(this, mMagnetometer, SensorManager.SENSOR_DELAY_UI)

        // Repeat every second to get rssi values
        timer = Timer()
        val timerTask: TimerTask = object : TimerTask() {
            override fun run() {
                getWifiStrengthPercentage(this@NavigationActivity)
            }
        }
        timer.schedule(timerTask, 0, 500)
    }

    override fun onPause() {
        super.onPause()
        // Unregister sensor
        mSensorManager?.unregisterListener(this, mAccelerometer)
        mSensorManager?.unregisterListener(this, mMagnetometer)
    }

    @RequiresApi(Build.VERSION_CODES.R)
    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor == mAccelerometer) {
            System.arraycopy(event.values, 0, mLastAccelerometer, 0, event.values.size)
        } else if (event.sensor === mMagnetometer) {
            System.arraycopy(event.values, 0, mLastMagnetometer, 0, event.values.size)
        }

        SensorManager.getRotationMatrix(R, null, mLastAccelerometer, mLastMagnetometer)
        SensorManager.getOrientation(R, mOrientationDegrees)

        // 센서를 통해 현재 디바이스의 z축 방향(방위각) 감지
        val azimuth = Math.toDegrees(mOrientationDegrees[0].toDouble()).toFloat()
        val rotation = -azimuth

        Log.e("rotation","$azimuth")

        // 목적지의 방향을 가리키도록 이미지 회전
        rotateArrow(rotation + currentFixedAngle)
        Log.d("angle","$currentFixedAngle")
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // TODO Auto-generated method stub
    }

    fun getWifiStrengthPercentage(context: Context) {
        if (applicationContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED){
            // Permission Not Granted
            ActivityCompat.requestPermissions(this, arrayOf<String>(android.Manifest.permission.ACCESS_FINE_LOCATION), 1);
        }
        wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        wifiManager.startScan() // Start signal scan
        val scanResults = wifiManager.scanResults
        Log.e("scan data", "$scanResults")
        var dataList = arrayListOf<Data>()
        for (result in scanResults) {
            bssid = result.BSSID
            ssid = result.SSID
            if (ssid == "GC_free_WiFi" || ssid == "eduroam") {
                rssi = result.level
                if (rssi < 0) {
                    rssi *= -1
                }
                dataList.add(Data(ssid, bssid, rssi))
            }
        }
        Log.e("dataList", "${dataList}")

        // Post my point
        postMyPoint(PostPointRequest(dataList))
    }

    // Rotate arrow image according to degree
    // 0F -> 앞으로 가는 화살표 / -90F -> 왼쪽 화살표 / 90F -> 오른쪽 화살표 / 180F -> 뒤로 가는 화살표
    private fun rotateArrow(rotateValue: Float) {
        // Rotate image
        val ra = RotateAnimation(
            mCurrentRotateValue,
            rotateValue,
            Animation.RELATIVE_TO_SELF, 0.5f,
            Animation.RELATIVE_TO_SELF, 0.5f
        )
        ra.duration = 250
        ra.fillAfter = true

        binding.run {
            imgNaviArrow.startAnimation(ra)
            mCurrentRotateValue = rotateValue
        }
    }

    // Send and Post my point to server through API
    private fun postMyPoint(dataList: PostPointRequest) {
        val service = ApplicationClass.sRetrofit.create(RetrofitInterface::class.java)

        service.postMyPoint(dataList).enqueue(object : Callback<PostPointResponse> {
            override fun onResponse(call: Call<PostPointResponse>, response: Response<PostPointResponse>) {
                if (response.isSuccessful) {
                    val body = response.body()
                    previousLocation = currentLocation
                    currentLocation = body?.location.toString()
                    binding.tvCurrentLocationContent.text = "$currentLocation"
                    Log.d("post mypoint", "$currentLocation")

                    if (currentLocation == destination) {
                        binding.apply {
                            tvDistanceContent.text = "0.0m"
                            // 타이머 종료
                            timer.cancel()
                            // 도착 다이얼로그 띄우기
                            showArrivalDialog()
                        }
                    } else {
                        // 위치가 달라졌을 때에만 /path 호출
                        if (previousLocation != currentLocation) {
                            navigatePath(PostPathRequest(currentLocation, destination))
                        }
                    }
                } else {
                    // If fail, show toast message to user
//                    showCustomToast("postMyPoint 네트워크 연결에 실패했습니다")
                }
            }
            // If fail, show toast message to user
            override fun onFailure(call: Call<PostPointResponse>, t: Throwable) {
//                showCustomToast("postMyPoint 네트워크 연결에 실패했습니다")
            }
        })
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun stringToBitmap(base64: String): Bitmap {
        val encodeByte = Base64.getDecoder().decode(base64)
        return BitmapFactory.decodeByteArray(encodeByte, 0, encodeByte.size)
    }

    // Navigate path from current location to destination through API
    private fun navigatePath(req: PostPathRequest) {
        val service = ApplicationClass.sRetrofit.create(RetrofitInterface::class.java)
        service.postPath(req).enqueue(object : Callback<PostPathResponse> {
            @RequiresApi(Build.VERSION_CODES.O)
            override fun onResponse(call: Call<PostPathResponse>, response: Response<PostPathResponse>) {
                if (response.isSuccessful) {
                    showCustomToast("Find a path!")
                    val body = response.body()
                    val path = body?.path
                    binding.tvDistanceContent.text = path?.sumOf { it.distance.toDouble() }.toString()
                    path?.get(0)?.let { currentFixedAngle = it.angle }

                    if (body?.image != null && body?.image.isNotBlank()) {
                        var bitmapDecode = stringToBitmap(body?.image)
                        binding.imgPath.setImageBitmap(bitmapDecode)
                    }
                } else {
//                    showCustomToast("postMyPoint 네트워크 연결에 실패했습니다")
                    Log.d("navigatePath", "${response}")
                }
            }
            // If fail, show toast message to user
            override fun onFailure(call: Call<PostPathResponse>, t: Throwable) {
//                showCustomToast("navigatePath 네트워크 연결에 실패했습니다")
            }
        })
    }

    // Show arrival dialog
    private fun showArrivalDialog() {
        ArrivalDialog()
            .show(this.supportFragmentManager, "ArrivalDialog")
    }
}