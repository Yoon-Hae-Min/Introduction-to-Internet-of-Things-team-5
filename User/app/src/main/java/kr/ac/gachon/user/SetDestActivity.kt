package kr.ac.gachon.user

import android.R
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner
import kr.ac.gachon.user.config.BaseActivity
import kr.ac.gachon.user.databinding.ActivitySetDestBinding

// Page to set destination from the list
class SetDestActivity : BaseActivity<ActivitySetDestBinding>(ActivitySetDestBinding::inflate) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 10 Destinations
        val destList: ArrayList<String> = arrayListOf(
            "AI - 414호", "AI - 415호", "AI - 416호", "AI - 417호", "AI - 418호",
            "AI - 419호", "AI - 420호", "AI - 421호", "AI - 422호", "AI - 423호"
        )
        // Set spinner data
        setSpinner(binding.spnDest, destList)

        // Set click event of start navigation btn
        binding.btnNavi.setOnClickListener {
            // Set intent to pass data
            val intent = Intent(this, NavigationActivity::class.java)
            intent.putExtra("dest", "${binding.spnDest.selectedItem}")
            // Start navigation page
            startActivity(intent)
        }
    }

    private fun setSpinner(spinner: Spinner, arr: ArrayList<String>) {
        // Creating adapter for spinner
        val dataAdapter = ArrayAdapter(this, R.layout.simple_spinner_item, arr)

        // Drop down layout style - list view with radio button
        dataAdapter.setDropDownViewResource(R.layout.simple_spinner_dropdown_item)

        // Attaching data adapter to spinner
        spinner.adapter = dataAdapter
        spinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(
                parent: AdapterView<*>?,
                view: View?,
                position: Int,
                id: Long
            ) {}
            override fun onNothingSelected(arg0: AdapterView<*>?) {}
        }
    }
}