package kr.ac.gachon.user.model

// Request data class for posting path
data class PostPathRequest(
    val start: String,
    val end: String
)

// Response data class for posting path
data class PostPathResponse(
    val image: String,
    val path: ArrayList<PointInfo>,
    val start_direction: Float
)
data class PointInfo(
    val angle: Float,
    val distance: Float
)