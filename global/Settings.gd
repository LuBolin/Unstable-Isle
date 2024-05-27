extends Node

const CAM_ANGLE: int = -65
const SKY_BOX_ANGLE: int = -205
# -65 is experimented to look at things on the X-Z plane
# CAM_FOV = 75: ~100 degrees
# camera's bottom edge is at -65 - 50 = -115
# camera's 0 degree default is on the X-Z plane
# skybox's 0 degree default has sky up the Y axis
# thus offset by another -90
# thus skybox is at -115 - 90 = -205 degrees

const GRAVITY: int = 200
