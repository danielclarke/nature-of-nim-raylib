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
import tiles
import map
import mover
import particle_system

const TILE_WIDTH = 8
const WIDTH = 32
const HEIGHT = 28
const SCALE = 2
const SCALED_TILE_WIDTH = SCALE * TILE_WIDTH

const SCREEN_WIDTH: int = WIDTH * TILE_WIDTH * SCALE
const SCREEN_HEIGHT: int = HEIGHT * TILE_WIDTH * SCALE

when defined(emscripten):
  const FRAME_RATE = 60
else:
  const FRAME_RATE = 60

converter toVector2(v: Vec2): Vector2 =
  Vector2(x: v.x, y: v.y)

converter toVec2(v: Vector2): Vec2 =
  Vec2(x: v.x, y: v.y)

func dead(self: var Mover) =
  self.location = Vec2(x: 1.0, y: HEIGHT - 10.0)
  self.velocity = Vec2(x: 0.0, y: 0.0)
  self.acceleration = Vec2(x: 0.0, y: 0.0)

proc render(a: Aabb; c: Color = Lightgray) =
  drawRectangle(
    (a.p0.x * TILE_WIDTH * SCALE).cint,
    (a.p0.y * TILE_WIDTH * SCALE).cint,
    ((a.p1.x - a.p0.x) * TILE_WIDTH * SCALE).cint,
    ((a.p1.y - a.p0.y) * TILE_WIDTH * SCALE).cint,
    c
  )

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
  var g = Vec2(x: 0.0, y: 50.0) #15.75)
  var walkVelocity = 15.0
  var walkAcceleration = walkVelocity * 0.1
  var jumpImpulse = -20.0 #-0.421875 * FRAME_RATE
  var c = 10.0

  var breath = 5.0
  var doubleJump = false

  var player = newMover(1.0, HEIGHT - 10.0, 12.0, 0.75)
  var onGround = false
  
  var particleSystem = newParticleSystem(
    (x: 1.0, y: HEIGHT - 10.0), 
    (x: -0.5, y: 0.0),
    (x: 0.5, y: 1.0),
    (x: 0.0, y: -3.0),
    1.0,
    1.5,
    128
  )

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


  const PARTICLE_WIDTH = SCALED_TILE_WIDTH
  var particleTexture = loadRenderTexture(PARTICLE_WIDTH, PARTICLE_WIDTH)
  beginTextureMode(particleTexture):
    clearBackground(Blank)
    let pColor = colorFromHSV(15.0, 1.0, 1.0)
    for i in 0 ..< PARTICLE_WIDTH:
      for j in 0 ..< PARTICLE_WIDTH:
        let distance = (PARTICLE_WIDTH / 2 - i.float) * (PARTICLE_WIDTH / 2 - i.float) + (PARTICLE_WIDTH / 2 - j.float) * (PARTICLE_WIDTH / 2 - j.float)
        let norm = (PARTICLE_WIDTH / 2) * (PARTICLE_WIDTH / 2) + (PARTICLE_WIDTH / 2) * (PARTICLE_WIDTH / 2)
        drawPixel(i, j, pColor.colorAlpha(1.0 - sqrt(distance / norm)))
        # drawPixel(i, j, pColor)

  var particleSystemTexture = loadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)
  beginTextureMode(particleSystemTexture):
    clearBackground(Blank)
  defer:
    unloadRenderTexture(particleSystemTexture)

  let font: Font = loadFont("assets/font/pixantiqua.ttf")

  setTargetFPS(FRAME_RATE)
  defer:
    closeWindow()

  while not windowShouldClose():
    let dt = getFrameTime()

    player.acceleration += g

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

    beginTextureMode(particleSystemTexture):
      clearBackground(Blank)
      beginBlendMode(BlendMode.ADDITIVE):
        # let pColor = colorFromHSV(15.0, 1.0, 1.0)
        for particle in particleSystem.particles:
          if not particle.isDead:
            drawTexture(particleTexture.texture, (particle.location.x * SCALED_TILE_WIDTH).cint, (particle.location.y * SCALED_TILE_WIDTH).cint, colorFromHSV(15.0, 1.0, 1.0).colorAlpha(particle.lifespan / particleSystem.lifespan))
            # render(particle, pColor.colorAlpha(particle.lifespan / particleSystem.lifespan))

    beginDrawing:
      clearBackground(Darkgray)
      drawFPS(10, 10)

      # drawTextEx(font, fmt"P {proportional}".cstring, Vec2(x: 1.0, y: 1.0) * TILE_WIDTH * SCALE, 2.0 * TILE_WIDTH * SCALE, 2.0, Red)
      # drawTextEx(font, fmt"I {integral}".cstring, Vec2(x: 1.0, y: 4.0) * TILE_WIDTH * SCALE, 2.0 * TILE_WIDTH * SCALE, 2.0, Red)
      # drawTextEx(font, fmt"D {derivative}".cstring, Vec2(x: 1.0, y: 7.0) * TILE_WIDTH * SCALE, 2.0 * TILE_WIDTH * SCALE, 2.0, Red)

      beginMode2D(camera)

      for water in waters:
        render(water, Skyblue)

      for wall in walls:
        render(wall)

      let source = Rectangle(x: 0, y: 0, width: particleSystemTexture.texture.width.float, height: -particleSystemTexture.texture.height.float)
      drawTextureRec(particleSystemTexture.texture, source, Vec2(x:0, y:0), White)

      render(player, colorFromHSV(15.0, 1.0, 1.0))

      if onGround and isKeyPressed(KeyboardKey.UP):
        player.velocity.y = jumpImpulse
      elif not doubleJump and isKeyPressed(KeyboardKey.UP):
        player.velocity.y = jumpImpulse
        doubleJump = true
      let velocity = player.getUpdateVelocity(dt)
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

      # for wall in walls:
      #   for _, particle in mpairs(particleSystem.particles):
      #      if checkCollision(particle, wall, velocity, Vec2(x: 0.0, y: 0.0)):
      #       render(wall, Red)

      block underWater:
        for water in waters:
          if checkCollision(player, water):
            breath -= dt
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

      player.update(dt)
      # particleSystem.location = player.location
      particleSystem.update(dt)
      # drawTextEx(font, fmt"Num ps: {particleSystem.particles.len}".cstring, Vec2(x: 1.0, y: 1.0) * TILE_WIDTH * SCALE, 2.0 * TILE_WIDTH * SCALE, 2.0, Red)

main()
