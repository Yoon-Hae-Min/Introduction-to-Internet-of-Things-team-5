package kr.ac.gachon.user

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.animation.Animation
import android.view.animation.RotateAnimation
import kr.ac.gachon.user.config.ApplicationClass
import kr.ac.gachon.user.config.BaseActivity
import kr.ac.gachon.user.databinding.ActivityNavigationBinding
import kr.ac.gachon.user.model.Data
import kr.ac.gachon.user.model.GetPointRequest
import kr.ac.gachon.user.model.GetPointResponse
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class NavigationActivity : BaseActivity<ActivityNavigationBinding>(ActivityNavigationBinding::inflate), SensorEventListener {
    private var mSensorManager: SensorManager? = null
    private var mAccelerometer: Sensor? = null
    private var mMagnetometer: Sensor? = null
    private val mLastAccelerometer = FloatArray(3)
    private val mLastMagnetometer = FloatArray(3)
    private var mLastAccelerometerSet = false
    private var mLastMagnetometerSet = false
    private var mCurrentDegree = 0f

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

        // Test API
        getMyPoint()
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
                Log.e("seori", "${orientationValues[1]}, ${orientationValues[2]}")
                val pitch = (360 * orientationValues[1] / (2 * Math.PI)).toInt()
                val roll = (360 * orientationValues[2] / (2 * Math.PI)).toInt()
                Log.e("seori1", "${pitch}, ${roll}, ${mCurrentDegree}")

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

    // Send and Get my point to server through API
    private fun getMyPoint() {
        val service = ApplicationClass.sRetrofit.create(RetrofitInterface::class.java)
        val request = GetPointRequest(
            arrayListOf(
                Data("95:1f:33:ac:35:11", 40),
                Data("91:9f:33:5c:23:02", 20),
                Data("96:7f:23:55:29:11", 50)
            )
        )

        service.getMyPoint(request).enqueue(object : Callback<GetPointResponse> {
            override fun onResponse(call: Call<GetPointResponse>, response: Response<GetPointResponse>) {
                if (response.isSuccessful) {
                    val body = response.body()
                    val location = body?.location
                    binding.tvMyPoint.text = location
                } else {
                    // If fail, show toast message to user
                    showCustomToast("네트워크 연결에 실패했습니다")
                }
            }
            // If fail, show toast message to user
            override fun onFailure(call: Call<GetPointResponse>, t: Throwable) {
                showCustomToast("네트워크 연결에 실패했습니다")
            }
        })
    }
}