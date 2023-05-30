package kr.ac.gachon.user.model

// Request data class for getting my point
data class GetPointRequest(
    val data: ArrayList<Data>
)

data class Data(
    val ssid: String,
    val bssid: String,
    val quality: Int
)

// Response data class for getting my point
data class GetPointResponse(
    val location: String
)