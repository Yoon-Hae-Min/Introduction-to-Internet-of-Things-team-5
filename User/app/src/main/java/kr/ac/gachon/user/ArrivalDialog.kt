package kr.ac.gachon.user

import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.DialogFragment
import kr.ac.gachon.user.databinding.DialogArrivalBinding

class ArrivalDialog : DialogFragment() {
    private lateinit var binding: DialogArrivalBinding

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        super.onCreate(savedInstanceState)
        binding = DialogArrivalBinding.inflate(inflater, container, false)
        setDialog()
        isCancelable = false
        return binding.root
    }

    // Set custom dialog
    private fun setDialog() = with(binding) {
        // Transparent background for visible corner radius
        dialog?.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        // Set click event of delete button
        btnOk.setOnClickListener {
            activity?.finish()
        }
    }
}