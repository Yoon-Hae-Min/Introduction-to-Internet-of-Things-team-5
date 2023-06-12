package kr.ac.gachon.user.model

// Request data class for posting path
data class PostPathRequest(
    val start: String,
    val end: String
)

// Response data class for posting path
data class PostPathResponse(
    val path: ArrayList<PointInfo>,
    val start_direction: String
)
data class PointInfo(
    val distance: Float,
    val angle: Float
)