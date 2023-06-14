package kr.ac.gachon.user

import kr.ac.gachon.user.model.*
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST

interface RetrofitInterface {

    // POST API for predicting my location
    @POST("/predict")
    fun postMyPoint(
        @Body postPointRequest: PostPointRequest
    ): Call<PostPointResponse>

    // POST API for path from current location to destination
    @POST("/path")
    fun postPath(
        @Body postPathRequest: PostPathRequest
    ): Call<PostPathResponse>

    // GET API for getting destinations list
    @GET("/locations")
    fun getDestinations(): Call<GetDestinationsResponse>
}