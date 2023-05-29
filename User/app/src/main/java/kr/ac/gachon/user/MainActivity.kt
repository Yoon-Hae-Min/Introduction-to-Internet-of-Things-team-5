package kr.ac.gachon.user

import android.content.Intent
import android.os.Bundle
import android.util.Log
import kr.ac.gachon.user.databinding.ActivityMainBinding

class MainActivity : BaseActivity<ActivityMainBinding>(ActivityMainBinding::inflate) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set click event of start button
        binding.run {
            btnStart.setOnClickListener {
                Log.d("seori", "Click start")
                var intent = Intent(this@MainActivity, SensorActivity::class.java)
                startActivity(intent)
            }
        }
    }
}