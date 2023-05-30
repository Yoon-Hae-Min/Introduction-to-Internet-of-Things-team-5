package kr.ac.gachon.user.config

import android.os.Bundle
import android.view.LayoutInflater
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.viewbinding.ViewBinding

// BaseActivity for view binding
abstract class BaseActivity<B : ViewBinding>(private val inflate: (LayoutInflater) -> B) : AppCompatActivity() {
    protected lateinit var binding: B
        private set
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = inflate(layoutInflater)
        setContentView(binding.root)
    }

    // Show toast message
    fun showCustomToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
}
