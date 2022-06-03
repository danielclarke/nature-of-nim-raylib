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

func bound(m: Mover, radius: float): Vec3 =
  let r = mag(m.location)
  if r < radius:
    return (x: 0.0, y: 0.0, z: 0.0)
  else:
    return m.mass * norm(-m.location) * (r - radius)

func slowing(m: Mover): Vec3 =
  return m.velocity * -0.1


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
  camera.projection = PERSPECTIVE

  const radius = 25.0
  const numPreys = 10
  const numPredators = 1

  var preys: array[0 .. numPreys - 1, Mover]
  var predators: array[0 .. numPredators - 1, Mover]

  for i in 0 ..< numPreys:
    preys[i] = (
      location: (x: math.cos(toFloat(i) * 2.0 * math.PI / toFloat(numPreys)) *
          10.0, y: 0.0, z: math.sin(toFloat(i) * 2.0 * math.PI / toFloat(
          numPreys)) * 10.0),
      velocity: (x: 0.0, y: 0.0, z: 0.0),
      acceleration: (x: 0.0, y: 0.0, z: 0.0),
      mass: 25.0
    )

  for i in 0 ..< numPredators:
    predators[i] = (
      location: (x: 1.0, y: 0.0, z: 1.0),
      velocity: (x: 0.0, y: 0.0, z: 0.0),
      acceleration: (x: 0.0, y: 0.0, z: 0.0),
      mass: 25.0
    )

  var theta = 0.0
  while not windowShouldClose():
    # camera.position = (0.0, math.sin(theta) * 50.0, math.cos(theta) * 50.0)

    for _, prey in preys.mpairs:
      for _, predator in predators.mpairs:
        let g = gravity(predator, prey)
        discard applyForce(predator, g)
        discard applyForce(prey, g * 1.1)

    for _, prey in preys.mpairs:
      let boundingForce = bound(prey, radius)
      discard applyForce(prey, boundingForce)
      let sf = prey.slowing()
      discard applyForce(prey, sf)
      prey.update()
      prey.velocity = prey.velocity.limit(1.0)
      prey.acceleration = prey.acceleration * 0.0

    for _, predator in predators.mpairs:
      let boundingForce = bound(predator, radius)
      discard applyForce(predator, boundingForce)
      let sf = predator.slowing()
      discard applyForce(predator, sf)
      predator.update()
      predator.velocity = predator.velocity.limit(1.0)
      predator.acceleration = predator.acceleration * 0.0

    beginDrawing()
    clearBackground(White)
    beginMode3D(camera)
    for prey in preys:
      drawSphere(prey.location, 2.0, Red)
    for predator in predators:
      drawSphere(predator.location, 2.0, Black)
    endMode3D()
    drawFPS(10, 10)
    endDrawing()
    theta = theta + 0.05 / math.PI

main()
