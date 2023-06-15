package kr.ac.gachon.user

import android.R
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner
import kr.ac.gachon.user.config.ApplicationClass
import kr.ac.gachon.user.config.BaseActivity
import kr.ac.gachon.user.databinding.ActivitySetDestBinding
import kr.ac.gachon.user.model.GetDestinationsResponse
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

// Page to set destination from the list
class SetDestActivity : BaseActivity<ActivitySetDestBinding>(ActivitySetDestBinding::inflate) {
    private var destList: ArrayList<String> = arrayListOf()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get destination list
        getDestinations()

        // Set click event of start navigation btn
        binding.btnNavi.setOnClickListener {
            // Set intent to pass data
            val intent = Intent(this, NavigationActivity::class.java)
            intent.putExtra("dest", "${binding.spnDest.selectedItem}")
            // Start navigation page
            startActivity(intent)
        }
    }

    // Get destination list through API
    private fun getDestinations() {
        val service = ApplicationClass.sRetrofit.create(RetrofitInterface::class.java)
        service.getDestinations().enqueue(object : Callback<GetDestinationsResponse> {
            override fun onResponse(call: Call<GetDestinationsResponse>, response: Response<GetDestinationsResponse>) {
                if (response.isSuccessful) {
                    val body = response.body()
                    destList = body?.locations?.let { it } ?: return
                    destList.sort()
                    Log.d("get dest", "$destList")

                    // Set spinner data
                    setSpinner(binding.spnDest, destList)
                } else {
                    // If fail, show toast message to user
                    showCustomToast("네트워크 연결에 실패했습니다")
                }
            }
            // If fail, show toast message to user
            override fun onFailure(call: Call<GetDestinationsResponse>, t: Throwable) {
                showCustomToast("네트워크 연결에 실패했습니다")
            }
        })
    }

    // Fill data to spinner
    private fun setSpinner(spinner: Spinner, arr: ArrayList<String>) {
        // Process data to show
        var spinnerDataList = arrayListOf<String>()
        for (data in arr) {
            if (!data.isEmpty()) {
                spinnerDataList.add(data)
            }
        }

        // Creating adapter for spinner
        val dataAdapter = ArrayAdapter(this, R.layout.simple_spinner_item, spinnerDataList)

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