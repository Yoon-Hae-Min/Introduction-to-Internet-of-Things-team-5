package kr.ac.gachon.user

import kr.ac.gachon.user.model.GetPointRequest
import kr.ac.gachon.user.model.GetPointResponse
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST

interface RetrofitInterface {

    // GET API for getting my page
    @POST("/getpoint")
    fun getMyPoint(
        @Body getPointRequest: GetPointRequest
    ): Call<GetPointResponse>
}