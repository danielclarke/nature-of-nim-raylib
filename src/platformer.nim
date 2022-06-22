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
import particle_system

const TILE_WIDTH = 8
const WIDTH = 32
const HEIGHT = 28
const SCALE = 2

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

converter toVector2(v: Vec2): Vector2 =
  Vector2(x: v.x, y: v.y)

converter toVec2(v: Vector2): Vec2 =
  Vec2(x: v.x, y: v.y)

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

proc render(p: Particle) =
  drawCircle((p.location.x * TILE_WIDTH * SCALE).cint, (p.location.y * TILE_WIDTH * SCALE).cint, TILE_WIDTH * SCALE, Red)

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
  var c = 450.0

  var breath = 5.0
  var doubleJump = false
  var jumpPower: array[2, float] = [0.0, 0.0]

  var player = newMover(1.0, HEIGHT - 10.0, 12.0, 0.75)
  var onGround = false
  
  var particleSystem = newParticleSystem((x: 1.0, y: HEIGHT - 10.0), 120, FRAME_RATE * 2)
  var particleSystem2 = newParticleSystem((x: 10.0, y: HEIGHT - 10.0), 120, FRAME_RATE * 2)

  var camera = Camera2D()
  camera.target = player.location
  camera.offset = (x: SCREEN_WIDTH / 2, y: SCREEN_HEIGHT / 2)
  camera.rotation = 0.0
  camera.zoom = 1.0

  var cameraError = Vec2(x: 0.0, y: 0.0)

  var proportional: Vec2 = (x: 0.0675, y: 0.025)
  var integral: Vec2 = (x: 0.0, y: 0.0)
  var derivative: Vec2 = (x: 0.0, y: 0.0)
  var pTargetDelta: Vec2 = (x: 0.0, y: 0.0)

  initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib nim - platformer")

  let font: Font = loadFont("assets/font/pixantiqua.ttf")

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
    # particle.applyForce(g)

    if isKeyPressed(KeyboardKey.W):
      proportional.x = proportional.x * 2.0
      echo(fmt"proportional.x: {proportional.x}")
    elif isKeyPressed(KeyboardKey.Q):
      proportional.x = proportional.x * 0.75
      echo(fmt"proportional.x: {proportional.x}")

    if isKeyPressed(KeyboardKey.S):
      proportional.y = proportional.y * 2.0
      echo(fmt"proportional.y: {proportional.y}")
    elif isKeyPressed(KeyboardKey.A):
      proportional.y = proportional.y * 0.75
      echo(fmt"proportional.y: {proportional.y}")

    if isKeyPressed(KeyboardKey.R):
      integral.x = integral.x * 2.0
      echo(fmt"integral.x: {integral.x}")
    elif isKeyPressed(KeyboardKey.E):
      integral.x = integral.x * 0.75
      echo(fmt"integral.x: {integral.x}")

    if isKeyPressed(KeyboardKey.F):
      integral.y = integral.y * 2.0
      echo(fmt"integral.y: {integral.y}")
    elif isKeyPressed(KeyboardKey.D):
      integral.y = integral.y * 0.75
      echo(fmt"integral.y: {integral.y}")

    if isKeyPressed(KeyboardKey.Y):
      derivative.x = derivative.x * 2.0
      echo(fmt"derivative.x: {derivative.x}")
    elif isKeyPressed(KeyboardKey.T):
      derivative.x = derivative.x * 0.75
      echo(fmt"derivative.x: {derivative.x}")

    if isKeyPressed(KeyboardKey.H):
      derivative.y = derivative.y * 2.0
      echo(fmt"derivative.y: {derivative.y}")
    elif isKeyPressed(KeyboardKey.G):
      derivative.y = derivative.y * 0.75
      echo(fmt"derivative.y: {derivative.y}")

    if isKeyDown(KeyboardKey.LEFT):
      player.velocity.x = max(-walkVelocity, player.velocity.x - walkAcceleration)
    elif isKeyDown(KeyboardKey.RIGHT):
      player.velocity.x = min(walkVelocity, player.velocity.x + walkAcceleration)

    beginDrawing:
      clearBackground(Darkgray)
      # drawFPS(10, 10)

      # drawTextEx(font, fmt"P {proportional}".cstring, Vec2(x: 1.0, y: 1.0) * TILE_WIDTH * SCALE, 2.0 * TILE_WIDTH * SCALE, 2.0, Red)
      # drawTextEx(font, fmt"I {integral}".cstring, Vec2(x: 1.0, y: 4.0) * TILE_WIDTH * SCALE, 2.0 * TILE_WIDTH * SCALE, 2.0, Red)
      # drawTextEx(font, fmt"D {derivative}".cstring, Vec2(x: 1.0, y: 7.0) * TILE_WIDTH * SCALE, 2.0 * TILE_WIDTH * SCALE, 2.0, Red)

      beginMode2D(camera)

      for water in waters:
        render(water, Skyblue)

      for wall in walls:
        render(wall)

      render(player)
      for particle in particleSystem.particles:
        if not particle.isDead:
          render(particle)
      for particle in particleSystem2.particles:
        if not particle.isDead:
          render(particle)

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
            drawTextEx(font, ($toInt(breath)).cstring, (player.location - Vec2(x: 1.0, y: 1.0)) * TILE_WIDTH * SCALE, TILE_WIDTH * SCALE, 2.0, Red)
            break underWater
        breath = 5.0
      
      var targetDelta: Vec2 = (player.location + player.velocity.norm * (x: 7.0, y: 7.0)) * TILE_WIDTH * SCALE - camera.target.toVec2
      # if player.velocity.x > 0:
      #   targetDelta = (player.location + (x: 7.0, y: 0.0)) * TILE_WIDTH * SCALE - camera.target.toVec2
      # elif player.velocity.x < 0:
      #   targetDelta = (player.location + (x: -7.0, y: 0.0)) * TILE_WIDTH * SCALE - camera.target.toVec2
      # else:
      #   targetDelta = player.location * TILE_WIDTH * SCALE - camera.target.toVec2
      
      # camera.target = camera.target + (targetDelta / 15.0).toVector2 + (cameraError * 0.0025).toVector2
      camera.target = camera.target + (targetDelta * proportional).toVector2 + (cameraError * integral).toVector2 + ((targetDelta - pTargetDelta) * derivative / FRAME_RATE).toVector2
      pTargetDelta = targetDelta
      cameraError += targetDelta

      drawRectangle(
        toInt(camera.target.x),
        toInt(camera.target.y),
        1 * TILE_WIDTH * SCALE,
        1 * TILE_WIDTH * SCALE,
        Color(r: 253, g: 249, b: 0, a: 100)
      )

      drawRectangle(
        toInt((player.location.x + player.velocity.norm.x * 7.0) * TILE_WIDTH * SCALE),
        toInt((player.location.y + player.velocity.norm.y * 3.5) * TILE_WIDTH * SCALE),
        1 * TILE_WIDTH * SCALE,
        1 * TILE_WIDTH * SCALE,
        Color(r: 255, g: 161, b: 0, a: 100)
      )

      endMode2D()

      player.update()
      particleSystem.update()
      particleSystem2.update()
      drawTextEx(font, fmt"Num ps: {particleSystem.particles.len}".cstring, Vec2(x: 1.0, y: 1.0) * TILE_WIDTH * SCALE, 2.0 * TILE_WIDTH * SCALE, 2.0, Red)

main()
