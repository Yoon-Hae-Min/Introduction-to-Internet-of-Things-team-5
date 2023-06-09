package kr.ac.gachon.user

import kr.ac.gachon.user.model.GetPointRequest
import kr.ac.gachon.user.model.GetPointResponse
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST

interface RetrofitInterface {

    // POST API for predicting my location
    @POST("/predict")
    fun getMyPoint(
        @Body getPointRequest: GetPointRequest
    ): Call<GetPointResponse>
}