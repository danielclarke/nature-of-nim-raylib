# separate physics from screen size
# access surrounding tiles from array but use collision detection on those
# spatial data store for collisions
# platforms
# other moving entities

import std/options
import std/strformat
import std/random
import std/math
import nimraylib_now
import vec2
import aabb
# import font

const TILE_WIDTH = 8
const WIDTH = 32
const HEIGHT = 28
const SCALE = 3

const SCREEN_WIDTH: int = WIDTH * TILE_WIDTH * SCALE
const SCREEN_HEIGHT: int = HEIGHT * TILE_WIDTH * SCALE
const SCREEN_WIDTH_F = toFloat(SCREEN_WIDTH)
const SCREEN_HEIGHT_F = toFloat(SCREEN_HEIGHT)

const FRAME_RATE = 60

const TILES = [
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]

const WATERS = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
]

type
  Mover = object
    location, velocity, acceleration: Vec2
    mass, c: float

  Wall = object
    p0, p1: Vec2
  
  Water = object
    p0, p1: Vec2
    c: float

func toVector2(v: Vec2): Vector2 =
  Vector2(x: v.x, y: v.y)

func map[T](ar: openArray[T], f: proc(x: T){.noSideEffect.}) =
  for v in ar:
    f(v)

proc newMover(x, y, m, c: float): Mover =
  return Mover(
    location: Vec2(x: x, y: y),
    velocity: Vec2(x: 0.0, y: 0.0),
    acceleration: Vec2(x: 0.0, y: 0.0),
    mass: m,
    c: c
  )

func p0(self: Mover): Vec2 =
  self.location

func p1(self: Mover): Vec2 =
  self.location + Vec2(x: 1.0, y: 1.0)

# func aabb(self: Mover): Aabb =
#   Aabb(p0: self.p0, p1: self.p1)

# func aabb(self: Wall): Aabb =
#   Aabb(p0: self.p0, p1: self.p1)

proc update(self: var Mover) =
  self.velocity = self.velocity + self.acceleration / FRAME_RATE
  self.velocity = self.velocity.limit(10.0)
  self.location = self.location + self.velocity
  self.acceleration = self.acceleration * 0.0

func getUpdateVelocity(self: Mover): Vec2 =
  return self.velocity + self.acceleration / FRAME_RATE

proc projectLocation(self: Mover): Vec2 =
  var velocity = self.velocity + self.acceleration / FRAME_RATE
  velocity = velocity.limit(10.0)
  return self.location + self.velocity

func applyForce(self: var Mover, force: Vec2) =
  let da = force / self.mass
  self.acceleration = self.acceleration + da

func drag(self: var Mover) =
  self.velocity *= self.c
  # let speed = self.velocity.mag()
  # let f = - self.c * speed * speed * self.velocity.norm()
  # self.applyForce(f)

func drag(self: var Mover, c: float) =
  let speed = self.velocity.mag()
  let f = - 0.5 * c * speed * speed * self.velocity.norm() * (self.p1.x - self.p0.x)
  self.applyForce(f)


func dead(self: var Mover) =
  self.location = Vec2(x: 1.0, y: HEIGHT - 10.0)
  self.velocity = Vec2(x: 0.0, y: 0.0)
  self.acceleration = Vec2(x: 0.0, y: 0.0)

# func checkCollision(a, b: Aabb): bool =
#   if a.p1.x < b.p0.x:
#     return false
#   elif b.p1.x < a.p0.x:
#     return false
#   elif a.p1.y < b.p0.y:
#     return false
#   elif b.p1.y < a.p0.y:
#     return false
#   return true

func getCollisionCorrection(a, b: Aabb): Vec2 =
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

  return Vec2(x: dx, y: dy)

proc render(m: Mover) =
  drawRectangle(toInt(m.p0.x * TILE_WIDTH * SCALE), toInt(m.p0.y * TILE_WIDTH *
      SCALE), TILE_WIDTH * SCALE,
    TILE_WIDTH * SCALE, colorFromHSV(15.0, 1.0, 1.0))

proc render(w: Aabb; c: Color = Lightgray) =
  drawRectangle(
    toInt(w.p0.x) * TILE_WIDTH * SCALE,
    toInt(w.p0.y) * TILE_WIDTH * SCALE,
    toInt(w.p1.x - w.p0.x) * TILE_WIDTH * SCALE,
    toInt(w.p1.y - w.p0.y) * TILE_WIDTH * SCALE,
    c
  )

proc countElems[w, h](tiles: array[w, array[h, int]]): int =
  var count = 0
  for i, row in tiles:
    for j, tile in row:
      if tile > 0:
        inc count
  return count

proc loadWalls[w, h, n](walls: var array[n, Wall]; tiles: array[w, array[h, int]]) =
  var iWall = 0
  for i, row in tiles:
    for j, tile in row:
      if tile > 0:
        walls[iWall] = Wall(
          p0: Vec2(x: toFloat(i), y: toFloat(j)),
          p1: Vec2(x: toFloat(i + 1), y: toFloat(j + 1))
        )
        inc iWall

proc loadWaters[w, h, n](waters: var array[n, Water]; tiles: array[w, array[h, int]], c: float) =
  var iWater = 0
  for i, row in tiles:
    for j, tile in row:
      if tile > 0:
        waters[iWater] = Water(
          p0: Vec2(x: toFloat(i), y: toFloat(j)),
          p1: Vec2(x: toFloat(i + 1), y: toFloat(j + 1)),
          c: c
        )
        inc iWater

func checkCollision[T, U: Aabb](a: T; b: U; va, vb: Vec2 = Vec2(x: 0.0, y: 0.0)): bool =
  let collisionTime = timeToCollision(a, b, va, vb)
  if collisionTime.isSome() and collisionTime.get() < 1.0:
    return true
  else:
    return false

proc main() =

  randomize()

  let font: Font = loadFont("../assets/font/pixantiqua.png")

  const numWalls = countElems(TILES)
  var walls: array[numWalls, Wall]
  loadWalls(walls, TILES)

  const numWaters = countElems(WATERS)
  var waters: array[numWaters, Water]
  loadWaters(waters, WATERS, 0.5)

  const epsilon = 0.01
  var g = Vec2(x: 0.0, y: 15.75)
  var walkVelocity = 0.25
  var walkAcceleration = walkVelocity * 0.1
  var jumpImpulse = -0.421875
  var c = 320.0

  var breath = 5.0
  var doubleJump = false
  var jumpPower: array[2, float] = [0.0, 0.0]

  var player = newMover(1.0, HEIGHT - 10.0, 12.0, 0.75)
  var onGround = false

  initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib nim - platformer")
  setTargetFPS(FRAME_RATE)
  defer:
    closeWindow()

  # let a = Aabb(p0: Vec2(x: 0.0, y: 0.0), p1: Vec2(x: 5.0, y: 5.0))
  # let b = Aabb(p0: Vec2(x: 10.0, y: 10.0), p1: Vec2(x: 15.0, y: 15.0))
  # let collisionTime = timeToCollision(a, b, Vec2(x: 0.0, y: 0.0), Vec2(x: -1.0, y: -0.5))

  # if collisionTime.isSome():
  #   echo(fmt"time to collision: {collisionTime.get()}")
  # else:
  #   echo(fmt"time to collision: None")

  # g = 15.75, jump = -0.421875
  while not windowShouldClose():
    player.applyForce(g)

    if isKeyPressed(KeyboardKey.W):
      c = c * 2.0
      echo(fmt"c: {c}")
    elif isKeyPressed(KeyboardKey.S):
      c = c * 0.75
      echo(fmt"c: {c}")

    if isKeyPressed(KeyboardKey.E):
      jumpImpulse = jumpImpulse * 2.0
      echo(fmt"jumpImpulse: {jumpImpulse}")
    elif isKeyPressed(KeyboardKey.D):
      jumpImpulse = jumpImpulse * 0.75
      echo(fmt"jumpImpulse: {jumpImpulse}")

    if isKeyPressed(KeyboardKey.R):
      player.mass = player.mass * 2.0
      echo(fmt"player.mass: {player.mass}")
    elif isKeyPressed(KeyboardKey.F):
      player.mass = player.mass * 0.75
      echo(fmt"player.mass: {player.mass}")

    if isKeyPressed(KeyboardKey.T):
      player.c = min(1.0, player.c * 2.0)
      echo(fmt"player.c: {player.c}")
    elif isKeyPressed(KeyboardKey.G):
      player.c = player.c * 0.75
      echo(fmt"player.c: {player.c}")

    if isKeyPressed(KeyboardKey.Y):
      walkVelocity = min(1.0, walkVelocity * 2.0)
      echo(fmt"walkVelocity: {walkVelocity}")
    elif isKeyPressed(KeyboardKey.H):
      walkVelocity = walkVelocity * 0.75
      echo(fmt"walkVelocity: {walkVelocity}")

    if isKeyDown(KeyboardKey.LEFT):
      player.velocity.x = max(-walkVelocity, player.velocity.x - walkAcceleration)
    elif isKeyDown(KeyboardKey.RIGHT):
      player.velocity.x = min(walkVelocity, player.velocity.x + walkAcceleration)

    beginDrawing:
      clearBackground(Darkgray)

      for water in waters:
        render(water, Skyblue)

      for wall in walls:
        render(wall)

      render(player)

      drawFPS(10, 10)

      if onGround and isKeyPressed(KeyboardKey.UP):
        player.velocity.y = jumpImpulse
      elif not doubleJump and isKeyPressed(KeyboardKey.UP):
        player.velocity.y = jumpImpulse
        doubleJump = true
      let velocity = player.getUpdateVelocity()
      onGround = false

      for wall in walls:
        if checkCollision(player, wall, velocity, Vec2(x: 0.0, y: 0.0)):
          let aabbOverlap = player.overlap(wall)
          if velocity.x > 0.0 and player.p0.x < wall.p0.x and aabbOverlap.y > epsilon:
            player.velocity.x = 0.0
            player.acceleration.x = min(0.0, player.acceleration.x)
            player.location.x = wall.p0.x - 1.0
            render(wall, Orange)
          if velocity.x < 0.0 and wall.p0.x < player.p0.x and aabbOverlap.y > epsilon:
            player.velocity.x = 0.0
            player.acceleration.x = max(0.0, player.acceleration.x)
            player.location.x = wall.p1.x
            render(wall, Orange)
          if velocity.y > 0.0 and player.p0.y < wall.p0.y and aabbOverlap.x > epsilon:
            onGround = true
            doubleJump = false
            player.velocity.y = 0.0
            player.acceleration.y = 0.0
            player.location.y = wall.p0.y - 1.0
            render(wall, Blue)
            if not isKeyDown(KeyboardKey.LEFT) and not isKeyDown(KeyboardKey.RIGHT):
              player.drag()
          if velocity.y < 0.0 and wall.p1.y < player.p1.y and aabbOverlap.x > epsilon:
            player.velocity.y = 0.0
            player.acceleration.y = 0.0
            player.location.y = wall.p1.y
            render(wall, Blue)

      # breath = breath + 1.0 / FRAME_RATE
      # drawTextEx(font, ($breath).cstring, toVector2((player.location - Vec2(x: 1.0, y: 1.0)) * TILE_WIDTH * SCALE), TILE_WIDTH * SCALE, 2.0, Red)
      block underWater:
        for water in waters:
          if checkCollision(player, water):
            breath -= 1.0 / FRAME_RATE
            if breath < 0.0:
              player.dead
              break underWater
            doubleJump = false
            player.drag(c)
            render(water, Green)
            drawTextEx(font, ($toInt(breath)).cstring, toVector2((player.location - Vec2(x: 1.0, y: 1.0)) * TILE_WIDTH * SCALE), TILE_WIDTH * SCALE, 2.0, Red)
            break underWater
        breath = 5.0
        
      player.update()

main()
