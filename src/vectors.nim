import std/strformat
import std/random
import std/math
import nimraylib_now
import perlin

const SCREEN_WIDTH: int = 800
const SCREEN_HEIGHT: int = 450

type
  Vec2 = tuple
    x, y: float

  Mover = tuple
    location, velocity, acceleration: Vec2

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

func `/`(s: float, v: Vec2): Vec2 =
  v / s

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

proc randomMover(): Mover =
  return (
    location: (
      x: toFloat(SCREEN_WIDTH) / 2.0 * random.gauss(1.0, 0.5),
      y: toFloat(SCREEN_HEIGHT) / 2.0 * random.gauss(1.0, 0.5)
    ),
    velocity: (
      x: 0.0, #5.0 * random.gauss(0.0, 1.0),
      y: 0.0, #5.0 * random.gauss(0.0, 1.0)
    ),
    acceleration: (x: 0.0, y: 0.0)
  )

proc update(self: var Mover) =
  self.velocity = self.velocity + self.acceleration / 60.0
  self.velocity = self.velocity.limit(10.0)
  self.location = self.location + self.velocity

proc bound(self: var Mover) =
  if self.location.x < 0.0:
    self.velocity.x = self.velocity.x * -1
    self.location.x = 1.0
  elif toFloat(SCREEN_WIDTH) < self.location.x:
    self.velocity.x = self.velocity.x * -1
    self.location.x = toFloat(SCREEN_WIDTH) - 1.0

  if self.location.y < 0.0:
    self.velocity.y = self.velocity.y * -1.0
    self.location.y = 1.0
  elif toFloat(SCREEN_HEIGHT) < self.location.y:
    self.velocity.y = self.velocity.y * -1.0
    self.location.y = toFloat(SCREEN_HEIGHT) - 1.0

# proc react(self: var Mover, mousePos: Vec2): Vec2 =
#   norm(mousePos - self.location) * 10.0

proc react(self: var Mover, mousePos: Vec2): Vec2 =
  let delta = (mousePos - self.location)
  let m = mag(delta) / 250.0
  let r = (
    x: noise(self.location.x + 0.137, self.location.y + 0.259, 127.127) * 10.0,
    y: noise(self.location.x + 0.137, self.location.y + 0.259, 249.249) * 10.0
  )
  return - norm(delta) / (m * m * m) + r

proc main() =

  randomize()

  const numMovers = 5
  var movers: array[0 .. numMovers - 1, Mover]
  for i in 0 ..< numMovers:
    movers[i] = randomMover()

  initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window")
  setTargetFPS(60)
  defer:
    closeWindow()

  while not windowShouldClose():

    let mousePos = (x: toFloat(getMouseX()), y: toFloat(getMouseY()))

    for _, mover in movers.mpairs:
      mover.acceleration = mover.react(mousePos)
      mover.update()
      mover.bound()

    beginDrawing:
      clearBackground(Black)
      for mover in movers:
        drawCircle(toInt(mover.location.x), toInt(mover.location.y), 10,
          colorFromHSV(mag(mousePos - mover.location) / 5.0, 1.0, 1.0))
      drawFPS(10, 10)

main()
