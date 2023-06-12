package kr.ac.gachon.user.model

// Request data class for posting my point
data class PostPointRequest(
    val data: ArrayList<Data>
)

data class Data(
    val ssid: String,
    val bssid: String,
    val quality: Int
)

// Response data class for posting my point
data class PostPointResponse(
    val location: String
)