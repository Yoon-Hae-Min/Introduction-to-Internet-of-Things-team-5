package kr.ac.gachon.user

import android.content.Intent
import android.os.Bundle
import android.util.Log
import kr.ac.gachon.user.databinding.ActivityMainBinding

class MainActivity : BaseActivity<ActivityMainBinding>(ActivityMainBinding::inflate) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Buttons for testing
        binding.run {
            btnIndoorNavi.setOnClickListener {
//                var intent = Intent(this@MainActivity, )
//                startActivity(intent)
            }
            btnSensor.setOnClickListener {
                Log.e("seori", "sensor")
                var intent = Intent(this@MainActivity, SensorActivity::class.java)
                startActivity(intent)
            }
        }
    }
}