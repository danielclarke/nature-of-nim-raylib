import std/strformat
import std/random
import std/math
import nimraylib_now

const SCREEN_WIDTH: int = 256 * 3
const SCREEN_HEIGHT: int = 224 * 3
const SCREEN_WIDTH_F = toFloat(SCREEN_WIDTH)
const SCREEN_HEIGHT_F = toFloat(SCREEN_HEIGHT)

const FRAME_RATE = 60

type
  Vec2 = tuple
    x, y: float

  Mover = tuple
    location, velocity, acceleration: Vec2
    mass: float

  Wall = tuple
    p0, p1: Vec2

  Aabb = concept
    proc p0[T](self: T): Vec2
    proc p1[T](self: T): Vec2

func map[T](ar: openArray[T], f: proc(x: T){.noSideEffect.}) =
  for v in ar:
    f(v)

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

proc p0(self: Mover): Vec2 =
  echo(fmt"location {self.location}")
  self.location - (x: self.mass, y: self.mass)

func p1(self: Mover): Vec2 =
  self.location + (x: self.mass, y: self.mass)

func aabb(self: Mover): Aabb =
  (p0: self.p0, p1: self.p1)

proc update(self: var Mover) =
  self.velocity = self.velocity + self.acceleration / FRAME_RATE
  self.velocity = self.velocity.limit(10.0)
  self.location = self.location + self.velocity
  self.acceleration = self.acceleration * 0.0

proc projectLocation(self: Mover): Vec2 =
  var velocity = self.velocity + self.acceleration / FRAME_RATE
  velocity = velocity.limit(10.0)
  return self.location + self.velocity

proc bound(self: var Mover) =
  if self.location.x - self.mass / 2.0 < 0.0:
    self.velocity.x = self.velocity.x * -1.0
    self.location.x = 1.0 + self.mass / 2.0
  elif SCREEN_WIDTH_F < self.location.x + self.mass / 2.0:
    self.velocity.x = self.velocity.x * -1.0
    self.location.x = SCREEN_WIDTH_F - 1.0 - self.mass / 2.0

  if self.location.y - self.mass / 2.0 < 0.0:
    self.velocity.y = self.velocity.y * -1.0
    self.location.y = 1.0 + self.mass / 2.0
  elif SCREEN_HEIGHT_F < self.location.y + self.mass / 2.0:
    self.velocity.y = self.velocity.y * -1.0
    self.location.y = SCREEN_HEIGHT_F - 1.0 - self.mass / 2.0

func applyForce(self: var Mover, force: Vec2) =
  let da = force / self.mass
  self.acceleration = self.acceleration + da

func drag(self: var Mover) =
  let speed = self.velocity.mag()
  let f = - 25.0 * speed * speed * self.velocity.norm()
  self.applyForce(f)

proc checkCollision[T, U](t: T, u: U): bool =
  if t.p1.x < u.p0.x:
    return false
  elif u.p1.x < t.p0.x:
    return false
  elif t.p1.y < u.p0.y:
    return false
  elif u.p1.y < t.p0.y:
    return false
  return true

proc getCollisionCorrection(a, b: Aabb): Vec2 =
  var dx = 0.0
  if a.p0.x < b.p0.x and a.p1.x > b.p0.x:
    dx = b.p0.x - a.p1.x
  elif a.p0.x < b.p1.x and a.p1.x > b.p1.x:
    dx = b.p1.x - a.p0.x

  var dy = 0.0
  if a.p0.y < b.p0.y and a.p1.y > b.p0.y:
    dy = b.p0.y - a.p1.y
  elif a.p0.y < b.p1.y and a.p1.y > b.p1.y:
    dy = b.p1.y - a.p0.y

  echo (fmt"p1: {p1(a)}")
  return (x: dx, y: dy)

proc render(m: Mover) =
  let fl = m.projectLocation()
  drawCircle(toInt(fl.x), toInt(fl.y), m.mass,
    colorFromHSV(55.0, 1.0, 1.0))
  drawCircle(toInt(m.location.x), toInt(m.location.y), m.mass,
    colorFromHSV(15.0, 1.0, 1.0))

proc render(w: Wall) =
  drawRectangle(toInt(w.p0.x), toInt(w.p0.y), toInt(w.p1.x - w.p0.x),
    toInt(w.p1.y - w.p0.y), Lightgray)

proc main() =

  randomize()

  const g = (x: 0.0, y: SCREEN_HEIGHT_F / 2.0)

  var doubleJump: bool = false

  var player = newMover(
    SCREEN_WIDTH_F / 2.0,
    SCREEN_HEIGHT_F / 4.0 * 3.0,
    SCREEN_WIDTH_F / 64.0
  )

  const wallWidth = SCREEN_HEIGHT_F / 50.0
  var walls: array[4, Wall]
  walls[0] = (
    p0: (x: 0.0, y: 0.0),
    p1: (x: wallWidth, y: SCREEN_HEIGHT_F),
  )
  walls[1] = (
    p0: (x: SCREEN_WIDTH_F - wallWidth, y: 0.0),
    p1: (x: SCREEN_WIDTH_F, y: SCREEN_HEIGHT_F),
  )
  walls[2] = (
    p0: (x: 0.0, y: 0.0),
    p1: (x: SCREEN_WIDTH_F, y: wallWidth),
  )
  walls[3] = (
    p0: (x: 0.0, y: SCREEN_HEIGHT_F - wallWidth),
    p1: (x: SCREEN_WIDTH_F, y: SCREEN_HEIGHT_F),
  )

  initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib nim - platformer")
  setTargetFPS(FRAME_RATE)
  defer:
    closeWindow()

  while not windowShouldClose():
    # player.applyForce(g)

    # if isKeyDown(KeyboardKey.LEFT):
    #   player.velocity.x = -5.0
    # elif isKeyDown(KeyboardKey.RIGHT):
    #   player.velocity.x = 5.0

    # if checkCollision(player, walls[3]):
    #   doubleJump = false
    #   if not isKeyDown(KeyboardKey.LEFT) and not isKeyDown(KeyboardKey.RIGHT):
    #     player.drag()
    #   if isKeyPressed(KeyboardKey.UP):
    #     player.velocity.y = - SCREEN_HEIGHT_F / 2.0
    # else:
    #   if not doubleJump and isKeyPressed(KeyboardKey.UP):
    #     player.velocity.y = - SCREEN_HEIGHT_F / 2.0
    #     doubleJump = true

    # player.update()

    # if checkCollision(player, walls[0]):
    #   player.velocity.x = max(0.0, player.velocity.x)
    #   player.acceleration.x = max(0.0, player.acceleration.x)
    #   player.location = player.location + getCollisionCorrection(player, walls[0])
    # if checkCollision(player, walls[1]):
    #   player.velocity.x = min(0.0, player.velocity.x)
    #   player.acceleration.x = min(0.0, player.acceleration.x)
    #   player.location = player.location + getCollisionCorrection((p0: player.p0, p1: player.p1), walls[1])
    # if checkCollision(player, walls[2]):
    #   player.velocity.y = max(0.0, player.velocity.y)
    #   player.acceleration.y = max(0.0, player.acceleration.y)
    #   player.location = player.location + getCollisionCorrection((p0: player.p0, p1: player.p1), walls[2])
    # if checkCollision(player, walls[3]):
    #   player.velocity.y = 0.0
    #   player.acceleration.y = 0.0
    #   player.location = player.location + getCollisionCorrection(player, walls[3])
    player.location = player.location + getCollisionCorrection(player, walls[3])

    beginDrawing:
      clearBackground(Darkgray)
      # render(player)
      walls.map(render)
      drawFPS(10, 10)

main()
