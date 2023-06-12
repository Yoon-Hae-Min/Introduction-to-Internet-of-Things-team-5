package kr.ac.gachon.user

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
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
import kr.ac.gachon.user.model.Data
import kr.ac.gachon.user.model.PostPointRequest
import kr.ac.gachon.user.model.PostPointResponse
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*
import kotlin.math.absoluteValue
import kotlin.properties.Delegates


class NavigationActivity : BaseActivity<ActivityNavigationBinding>(ActivityNavigationBinding::inflate), SensorEventListener {
    private var mSensorManager: SensorManager? = null
    private var mAccelerometer: Sensor? = null
    private var mMagnetometer: Sensor? = null
    private val mLastAccelerometer = FloatArray(3)
    private val mLastMagnetometer = FloatArray(3)
    private var mLastAccelerometerSet = false
    private var mLastMagnetometerSet = false
    private var mCurrentDegree = 0f
    private lateinit var wifiManager: WifiManager
    private var bssid by Delegates.notNull<String>()
    private var ssid by Delegates.notNull<String>()
    private var rssi by Delegates.notNull<Int>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding.tvDestinationContent.text = intent.getStringExtra("dest")

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
        val timer = Timer()
        val timerTask: TimerTask = object : TimerTask() {
            override fun run() {
                getWifiStrengthPercentage(this@NavigationActivity)
            }
        }
        timer.schedule(timerTask, 0, 1000)
    }

    override fun onPause() {
        super.onPause()
        // Unregister sensor
        mSensorManager?.unregisterListener(this, mAccelerometer)
        mSensorManager?.unregisterListener(this, mMagnetometer)
    }

    fun computeOrientation(accel: FloatArray?, magnetic: FloatArray?): FloatArray {
        val inR = FloatArray(16)
        val I = FloatArray(16)
        val outR = FloatArray(16)
        val values = FloatArray(3)
        SensorManager.getRotationMatrix(inR, I, accel, magnetic)
        SensorManager.remapCoordinateSystem(inR, SensorManager.AXIS_X, SensorManager.AXIS_Y, outR)
        SensorManager.getOrientation(outR, values)
        return values
    }

    // 센서를 통해 현재 디바이스 방향 감지
    @RequiresApi(Build.VERSION_CODES.R)
    override fun onSensorChanged(event: SensorEvent) {
        val lastComputedTime: Long = 0
        if (event.sensor == mAccelerometer) {
            System.arraycopy(event.values, 0, mLastAccelerometer, 0, event.values.size)
            mLastAccelerometerSet = true
        } else if (event.sensor == mMagnetometer) {
            System.arraycopy(event.values, 0, mLastMagnetometer, 0, event.values.size)
            mLastMagnetometerSet = true
        }
        if (mLastAccelerometerSet && mLastMagnetometerSet) {
            val tempTime = System.currentTimeMillis()
            if (tempTime - lastComputedTime > 1000) {
                val orientationValues = computeOrientation(mLastAccelerometer, mLastMagnetometer)
//                Log.e("seori", "${orientationValues[1]}, ${orientationValues[2]}")
                val pitch = (360 * orientationValues[1] / (2 * Math.PI)).toInt()
                val roll = (360 * orientationValues[2] / (2 * Math.PI)).toInt()
//                Log.e("seori1", "${pitch}, ${roll}, ${mCurrentDegree}")

                //경사도
                binding.tvDistanceContent.text = "pitch=$pitch"
                //좌우회전
                binding.tvSpeedContent.text = "roll=$roll"
                // 이미지 회전
                rotateArrow(90F)
            }
        }
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

    // Rotate arrow image
    // value = 0F -> 앞으로 가는 화살표
    // value = -90F -> 왼쪽 화살표
    // value = 90F -> 오른쪽 화살표
    // value = 180F -> 뒤로 가는 화살표
    private fun rotateArrow(value: Float) {
        val ra = RotateAnimation(
            mCurrentDegree,
            value,
            Animation.RELATIVE_TO_SELF, 0.5f,
            Animation.RELATIVE_TO_SELF,
            0.5f
        )
        ra.duration = 250
        ra.fillAfter = true

        binding.run {
            imgNaviArrow.startAnimation(ra)
            mCurrentDegree = value
        }
    }

    // Send and Post my point to server through API
    private fun postMyPoint(dataList: PostPointRequest) {
        val service = ApplicationClass.sRetrofit.create(RetrofitInterface::class.java)

        service.postMyPoint(dataList).enqueue(object : Callback<PostPointResponse> {
            override fun onResponse(call: Call<PostPointResponse>, response: Response<PostPointResponse>) {
                if (response.isSuccessful) {
                    val body = response.body()
                    val location = body?.location
                    Log.d("post mypoint", "$location")
                    binding.tvMyPoint.text = "테스트용: 이곳은 $location"
                } else {
                    // If fail, show toast message to user
                    showCustomToast("네트워크 연결에 실패했습니다")
                }
            }
            // If fail, show toast message to user
            override fun onFailure(call: Call<PostPointResponse>, t: Throwable) {
                showCustomToast("네트워크 연결에 실패했습니다")
            }
        })
    }
}