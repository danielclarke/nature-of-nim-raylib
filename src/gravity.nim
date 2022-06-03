import nimraylib_now
import std/math

const SCREEN_WIDTH: int = 800
const SCREEN_HEIGHT: int = 450

type
  Vec3 = tuple
    x, y, z: float

  Mover = tuple
    location, velocity, acceleration: Vec3
    mass: float

func `+`(u, v: Vec3): Vec3 =
  (x: u.x + v.x, y: u.y + v.y, z: u.z + v.z)

func `-`(u, v: Vec3): Vec3 =
  (x: u.x - v.x, y: u.y - v.y, z: u.z - v.z)

func `-`(v: Vec3): Vec3 =
  (x: -v.x, y: -v.y, z: -v.z)

func `*`(v: Vec3, s: float): Vec3 =
  (x: v.x * s, y: v.y * s, z: v.z * s)

func `*`(s: float, v: Vec3): Vec3 =
  v * s

func `/`(v: Vec3, s: float): Vec3 =
  (x: v.x / s, y: v.y / s, z: v.z / s)

func mag(v: Vec3): float =
  sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

func norm(v: Vec3): Vec3 =
  let m = mag(v)
  if m == 0.0:
    return v
  else:
    return v / m

func limit(v: Vec3, l: float): Vec3 =
  let m = mag(v)
  if l < m:
    return v / m * l
  else:
    return v

proc newMover(x, y, z, m: float): Mover =
  return (
    location: (x: x, y: y, z: z),
    velocity: (x: 0.2, y: 0.0, z: 0.0),
    acceleration: (x: 0.0, y: 0.0, z: 0.0),
    mass: m
  )

proc update(self: var Mover) =
  self.velocity = self.velocity + self.acceleration / 60.0
  self.velocity = self.velocity.limit(25.0)
  self.location = self.location + self.velocity

func applyForce(self: var Mover, force: Vec3): Mover =
  let da = force / self.mass
  self.acceleration = self.acceleration + da
  return self

func gravity(m1, m2: Mover): Vec3 =
  let r = max(mag(m1.location - m2.location), 1.0)
  return m1.mass * m2.mass / (r * r) * norm(m2.location - m1.location)

proc main() =
  initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "nim raylib gravity")
  setTargetFPS(60)
  defer:
    closeWindow()

  var camera = Camera3D()
  camera.position = (0.0, 200.0, 200.0)
  camera.target = (0.0, 0.0, 0.0)
  camera.up = (0.0, 1.0, 0.0)
  camera.fovy = 45.0
  camera.projection = Perspective

  const numMovers = 8
  var movers: array[0 .. numMovers - 1, Mover]
  for i in 0 ..< numMovers:
    movers[i] = (
      location: (x: math.cos(toFloat(i) * 2.0 * math.PI / toFloat(numMovers)) *
          10.0, y: 0.0, z: math.sin(toFloat(i) * 2.0 * math.PI / toFloat(
          numMovers)) * 10.0),
      velocity: (x: -math.sin(toFloat(i) * 2.0 * math.PI / toFloat(numMovers)) *
          0.3, y: 0.0, z: math.cos(toFloat(i) * 2.0 * math.PI / toFloat(
          numMovers)) * 0.3),
      acceleration: (x: 0.0, y: 0.0, z: 0.0),
      mass: 25.0
    )
    # newMover(
    #   math.sin(toFloat(i) * 2.0 * math.PI / 10.0) * 10.0,
    #   0.0,
    #   math.cos(toFloat(i) * 2.0 * math.PI / 10.0) * 10.0,
    #   10.0
    # )

  # var nonMover = newMover(
  #   0.0,
  #   0.0,
  #   0.0,
  #   100.0
  # )

  var theta = 0.0
  while not windowShouldClose():
    # camera.position = (0.0, math.sin(theta) * 50.0, math.cos(theta) * 50.0)

    # nonMover.location.x = (toFloat(getMouseX()) - toFloat(SCREEN_WIDTH) / 2.0) / 10.0
    # nonMover.location.y = (- toFloat(getMouseY()) + toFloat(SCREEN_HEIGHT) / 2.0) / 10.0

    for i in 0 ..< numMovers:
      for j in i + 1 ..< numMovers:
        let g = gravity(movers[i], movers[j])
        discard applyForce(movers[i], g)
        discard applyForce(movers[j], -g)
      movers[i].update()
      movers[i].acceleration = movers[i].acceleration * 0.0
    # for i, moverA in movers.mpairs:
    #   for j, moverB in movers.mpairs:
    #     if i != j:
    #       let g = gravity(moverA, moverB)
    #       discard applyForce(moverA, g)

    # for _, mover in movers.mpairs:
    #   mover.update()
    #   mover.acceleration = mover.acceleration * 0.0

    beginDrawing()
    clearBackground(White)
    beginMode3D(camera)
    for i, mover in movers:
      drawSphere(mover.location, 2.0, colorFromHSV(toFloat(i) / toFloat(
          numMovers) * 255.0, 1.0, 1.0))
    # drawSphere(nonMover.location, 2.0, Black)
    endMode3D()
    drawFPS(10, 10)
    endDrawing()
    theta = theta + 0.05 / math.PI

main()
