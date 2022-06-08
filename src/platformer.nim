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

const TILE_WIDTH = 8
const WIDTH = 32
const HEIGHT = 28
const SCALE = 1

const SCREEN_WIDTH: int = WIDTH * TILE_WIDTH * SCALE
const SCREEN_HEIGHT: int = HEIGHT * TILE_WIDTH * SCALE
const SCREEN_WIDTH_F = toFloat(SCREEN_WIDTH)
const SCREEN_HEIGHT_F = toFloat(SCREEN_HEIGHT)

const FRAME_RATE = 60

const TILES = [
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
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
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]

type
  Mover = object
    location, velocity, acceleration: Vec2
    mass, c: float

  Wall = object
    p0, p1: Vec2

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

func checkCollision(a, b: Aabb): bool =
  if a.p1.x < b.p0.x:
    return false
  elif b.p1.x < a.p0.x:
    return false
  elif a.p1.y < b.p0.y:
    return false
  elif b.p1.y < a.p0.y:
    return false
  return true

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

proc render(w: Wall; c: Color = Lightgray) =
  drawRectangle(
    toInt(w.p0.x) * TILE_WIDTH * SCALE,
    toInt(w.p0.y) * TILE_WIDTH * SCALE,
    toInt(w.p1.x - w.p0.x) * TILE_WIDTH * SCALE,
    toInt(w.p1.y - w.p0.y) * TILE_WIDTH * SCALE,
    c
  )

proc renderWall(i, j: int) =
  drawRectangle(i * TILE_WIDTH * SCALE, j * TILE_WIDTH * SCALE, TILE_WIDTH *
      SCALE, TILE_WIDTH * SCALE, Lightgray)

proc countWalls[w, h](tiles: array[w, array[h, int]]): int =
  var numWalls = 0
  for i, row in tiles:
    for j, tile in row:
      if tile > 0:
        inc numWalls
  return numWalls

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

func checkCollision[T, U: Aabb](a: T; b: U; va, vb: Vec2): bool =
  let collisionTime = timeToCollision(a, b, va, vb)
  if collisionTime.isSome() and collisionTime.get() < 1.0:
    return true
  else:
    return false

proc main() =

  randomize()

  const numWalls = countWalls(TILES)
  var walls: array[numWalls, Wall]
  loadWalls(walls, TILES)

  const epsilon = 0.01
  var g = Vec2(x: 0.0, y: 15.75)
  var walkVelocity = 0.25
  var walkAcceleration = walkVelocity * 0.1
  var jumpImpulse = -0.421875

  var doubleJump: bool = false
  var jumpPower: array[2, float] = [0.0, 0.0]

  var player = newMover(1.0, HEIGHT - 2.0, 12.0, 0.75)
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
      g = g * 2.0
      echo(fmt"g: {g}")
    elif isKeyPressed(KeyboardKey.S):
      g = g * 0.75
      echo(fmt"g: {g}")

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

    let cx = toInt(player.location.x)
    let cy = toInt(player.location.y)

    let cx0 = toInt(floor(player.p0.x + epsilon))
    let cx1 = toInt(floor(player.p1.x - epsilon))
    let cy0 = toInt(floor(player.p0.y + epsilon))
    let cy1 = toInt(floor(player.p1.y - epsilon))

    # echo(fmt"p0x {player.p0.x}, p1x {player.p1.x}; cx0 {cx0}, cx1 {cx1}")
    # echo(fmt"p0y {player.p0.y}, p1y {player.p1.y}; cy0 {cy0}, cy1 {cy1}")

    beginDrawing:
      clearBackground(Darkgray)
      render(player)
      for wall in walls:
        render(wall)
      # for i, row in m.mpairs:
      #   for j, wall in row.mpairs:
      #     if wall == 1:
      #       renderWall(i, j)
      drawFPS(10, 10)

      # if player.velocity.x > 0.0 and (m[cx1][cy0] == 1 or m[cx1][cy1] == 1):
      #   player.velocity.x = min(0.0, player.velocity.x)
      #   player.acceleration.x = min(0.0, player.acceleration.x)
      #   player.location.x = toFloat(cx0)
      # if player.velocity.x < 0.0 and (m[cx0][cy0] == 1 or m[cx0][cy1] == 1):
      #   player.velocity.x = max(0.0, player.velocity.x)
      #   player.acceleration.x = max(0.0, player.acceleration.x)
      #   player.location.x = toFloat(cx1)
      # if player.velocity.y >= 0.0 and m[cx][cy + 1] == 1:
      #   player.velocity.y = 0.0
      #   player.acceleration.y = 0.0
      #   player.location.y = toFloat(cy)
      #   doubleJump = false
        # if not isKeyDown(KeyboardKey.LEFT) and not isKeyDown(KeyboardKey.RIGHT):
        #   player.drag()
        # if isKeyPressed(KeyboardKey.UP):
        #   player.velocity.y = jumpImpulse
      # if not doubleJump and isKeyPressed(KeyboardKey.UP):
      #   player.velocity.y = jumpImpulse
      #   doubleJump = true
      # if player.velocity.y <= 0.0 and (m[cx0][cy - 1] == 1 or m[cx1][cy - 1] == 1):
      #   player.velocity.y = max(0.0, player.velocity.y)
      #   player.acceleration.y = max(0.0, player.acceleration.y)
      #   player.location.y = toFloat(cy)
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

      player.update()

main()
