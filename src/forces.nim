# import std/strformat
import std/random
import std/math
import std/times
import nimraylib_now
# import perlin

const SCREEN_WIDTH: int = 800
const SCREEN_HEIGHT: int = 450

type
  Vec2 = tuple
    x, y: float

  Mover = tuple
    location, velocity, acceleration: Vec2
    mass: float

  Liquid = tuple
    p0, p1: Vec2
    c: float

func `+`(u, v: Vec2): Vec2 =
  (x: u.x + v.x, y: u.y + v.y)

func `-`(u, v: Vec2): Vec2 =
  (x: u.x - v.x, y: u.y - v.y)

func `-`(v: Vec2): Vec2 =
  (x: -v.x, y: -v.y)

func `*`(v: Vec2, s: float): Vec2 =
  (x: v.x * s, y: v.y * s)

func `*`(s: float, v: Vec2): Vec2 =
  v * s

func `/`(v: Vec2, s: float): Vec2 =
  (x: v.x / s, y: v.y / s)

func mag(v: Vec2): float =
  sqrt(v.x * v.x + v.y * v.y)

func norm(v: Vec2): Vec2 =
  let m = mag(v)
  if m == 0.0:
    return v
  else:
    return v / m

func limit(v: Vec2, l: float): Vec2 =
  let m = mag(v)
  if l < m:
    return v / m * l
  else:
    return v

proc newMover(x, y, m: float): Mover =
  return (
    location: (x: x, y: y),
    velocity: (x: 0.0, y: 0.0),
    acceleration: (x: 0.0, y: 0.0),
    mass: m
  )

# proc randomMover(): Mover =
#   return (
#     location: (
#       x: toFloat(SCREEN_WIDTH) / 2.0 * random.gauss(1.0, 0.5),
#       y: toFloat(SCREEN_HEIGHT) / 2.0 * random.gauss(1.0, 0.5)
#     ),
#     velocity: (
#       x: 0.0, #5.0 * random.gauss(0.0, 1.0),
#       y: 0.0, #5.0 * random.gauss(0.0, 1.0)
#     ),
#     acceleration: (x: 0.0, y: 0.0),
#     mass: random.gauss(10.0, 0.5)
#   )

func p0(mover: Mover): Vec2 =
  mover.location - (x: mover.mass / 2.0, y: mover.mass / 2.0)

func p1(mover: Mover): Vec2 =
  mover.location + (x: mover.mass / 2.0, y: mover.mass / 2.0)

proc update(self: var Mover) =
  self.velocity = self.velocity + self.acceleration / 60.0
  self.velocity = self.velocity.limit(10.0)
  self.location = self.location + self.velocity

proc bound(self: var Mover) =
  if self.location.x - self.mass / 2.0 < 0.0:
    self.velocity.x = self.velocity.x * -1.0
    self.location.x = 1.0 + self.mass / 2.0
  elif toFloat(SCREEN_WIDTH) < self.location.x + self.mass / 2.0:
    self.velocity.x = self.velocity.x * -1.0
    self.location.x = toFloat(SCREEN_WIDTH) - 1.0 - self.mass / 2.0

  if self.location.y - self.mass / 2.0 < 0.0:
    self.velocity.y = self.velocity.y * -1.0
    self.location.y = 1.0 + self.mass / 2.0
  elif toFloat(SCREEN_HEIGHT) < self.location.y + self.mass / 2.0:
    self.velocity.y = self.velocity.y * -1.0
    self.location.y = toFloat(SCREEN_HEIGHT) - 1.0 - self.mass / 2.0

# proc react(self: var Mover, mousePos: Vec2): Vec2 =
#   norm(mousePos - self.location) * 10.0

# proc react(self: Mover, mousePos: Vec2): Vec2 =
#   let delta = (mousePos - self.location)
#   let m = mag(delta) / 250.0
#   let r = (
#     x: noise(self.location.x + 0.137, self.location.y + 0.259, 127.127) * 10.0,
#     y: noise(self.location.x + 0.137, self.location.y + 0.259, 249.249) * 10.0
#   )
#   return - norm(delta) / (m * m * m) + r

func applyForce(self: var Mover, force: Vec2): Mover =
  let da = force / self.mass
  self.acceleration = self.acceleration + da
  return self

func drag(self: Mover, c: float): Vec2 =
  let speed = self.velocity.mag()
  return - 0.5 * c * speed * speed * self.velocity.norm() * (self.p1.x - self.p0.x)

func lift(self: Mover, c: float): Vec2 =
  let drag = self.drag(c)
  let l = math.sqrt(0.5 * drag.x * c * self.velocity.x * math.PI)

  # func drag(self: Mover, c: float): Vec2 =
  # - 0.5 * liquid.c * speed * speed * self.velocity.norm() * (self.p1.x - self.p0.x)

# proc boundingForce(self: var Mover) =
#   let f = 50.0
#   let left = 1.0 / (max(0.1, self.location.x) / f)
#   let right = 1.0 / (max(0.1, toFloat(SCREEN_WIDTH) - self.location.x) / f)
#   let up = 1.0 / (max(0.1, self.location.y) / f)
#   let down = 1.0 / (max(0.1, toFloat(SCREEN_HEIGHT) - self.location.y) / f)
#   discard self.applyForce(
#     (
#       x: left * left * left * left - right * right * right * right,
#       y: up * up * up * up - down * down * down * down
#     )
#   )

func checkCollision[T, U](t: T, u: U): bool =
  if t.p1.x < u.p0.x:
    return false
  elif u.p1.x < t.p0.x:
    return false
  elif t.p1.y < u.p0.y:
    return false
  elif u.p1.y < t.p0.y:
    return false
  return true

# proc wind(pos: Vec2, time: float): Vec2 =
#   (
#     x: noise(pos.y + 0.137, pos.y + 0.259, 2.0 * time) * 10.0,
#     y: noise(pos.y + 0.137, pos.y + 0.259, 3.0 * time) * 10.0
#   )

proc main() =

  randomize()

  const numMovers = 10
  var movers: array[0 .. numMovers - 1, Mover]
  for i in 0 ..< numMovers:
    movers[i] = newMover(
      toFloat(i * SCREEN_WIDTH) / toFloat(numMovers) + 25.0,
      25.0 + random.rand(150.0),
      random.rand(10.0)
    )

  initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window")
  setTargetFPS(60)
  defer:
    closeWindow()

  const wind = (x: 0.1, y: 0.0)
  const gravity = (x: 0.0, y: 10.0)
  const mu = 0.6
  const liquid: Liquid = (
    p0: (x: 0.0, y: toFloat(SCREEN_HEIGHT) / 2.0),
    p1: (x: toFloat(SCREEN_WIDTH), y: toFloat(SCREEN_HEIGHT)),
    c: 24.0
  )
  while not windowShouldClose():
    for _, mover in movers.mpairs:
      # let friction = - mu * mover.velocity.norm()
      if checkCollision(mover, liquid):
        let d = mover.drag(liquid.c)
        discard mover.applyForce(d)
      discard mover.applyForce(wind)
      discard mover.applyForce(gravity * mover.mass)
      # mover.boundingForce()
      mover.update()
      mover.bound()
      mover.acceleration = mover.acceleration * 0.0

    beginDrawing:
      clearBackground(Lightgray)
      drawRectangle(
          toInt(liquid.p0.x), toInt(liquid.p0.y),
          toInt(liquid.p1.x - liquid.p0.x), toInt(liquid.p1.y - liquid.p0.y),
          Blue
        )
      for mover in movers:
        drawCircle(toInt(mover.location.x), toInt(mover.location.y), mover.mass,
          colorFromHSV(mover.location.y / 255.0, 1.0, 1.0))
      drawFPS(10, 10)

main()
