package kr.ac.gachon.user

import kr.ac.gachon.user.model.PostPointRequest
import kr.ac.gachon.user.model.PostPointResponse
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST

interface RetrofitInterface {

    // POST API for predicting my location
    @POST("/predict")
    fun postMyPoint(
        @Body postPointRequest: PostPointRequest
    ): Call<PostPointResponse>
}