package kr.ac.gachon.user

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import android.util.Log
import android.view.animation.Animation
import android.view.animation.RotateAnimation
import kr.ac.gachon.user.databinding.ActivityNavigationBinding

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
                binding.tvDistance.text = "pitch=$pitch"
                //좌우회전
                binding.tvSpeed.text = "roll=$roll"
                // 이미지 회전
                rotateArrow(90F)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // TODO Auto-generated method stub
    }

    // 두 지점 사이의 거리 측정
    fun GetDistanceFromLatLonInKm(
        lat1: Double,
        lon1: Double,
        lat2: Double,
        lon2: Double
    ): Double {
        val R = 6371
        // Radius of the earth in km
        val dLat = deg2rad(lat2 - lat1)
        // deg2rad below
        val dLon = deg2rad(lon2 - lon1)
        val a =
            Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(
                deg2rad(lat1)
            ) * Math.cos(deg2rad(lat2)) * Math.sin(dLon / 2) * Math.sin(
                dLon / 2
            )
        val c =
            2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        // Distance in km
        return R * c
    }

    private fun deg2rad(deg: Double): Double {
        return deg * (Math.PI / 180)
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
}