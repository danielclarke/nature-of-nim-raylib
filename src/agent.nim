import nimprof

import std/random
import std/math
import std/strformat

import nimraylib_now

import vec2
import perlin

type
  Vehicle = object
    location, velocity, acceleration: Vec2
    mass, maxSpeed, maxForce: float

  FlowField[W, H: static[int]] = object
    width, height: int
    field: array[W, array[H, Vec2]]

func applyForce*(self: var Vehicle, force: Vec2) =
  let da = force / self.mass
  self.acceleration = self.acceleration + da

func seek(self: var Vehicle; target: Vec2) =
  var desired = (target - self.location)
  desired = desired.norm * self.maxSpeed
  let steer = (desired - self.velocity).limit(self.maxForce)
  self.applyForce(steer)

proc update*(self: var Vehicle, dt: float) =
  self.velocity = self.velocity + self.acceleration * dt
  self.velocity = self.velocity.limit(self.maxSpeed)
  self.location = self.location + self.velocity * dt
  self.acceleration = Vec2(x: 0.0, y: 0.0)

proc newVehicle(location: Vec2; mass, maxSpeed, maxForce: float): Vehicle =
  Vehicle(
    location: location,
    velocity: Vec2(x: 0.0, y: 0.0),
    acceleration: Vec2(x: 0.0, y: 0.0),
    mass: mass,
    maxSpeed: maxSpeed,
    maxForce: maxForce
  )

proc newFlowField[W, H: static[int]](t: float): FlowField[W, H] =
  var field: array[W, array[H, Vec2]]
  for i in 0 ..< W:
    for j in 0 ..< H:
      field[i][j] = 10.0 * vec2FromAngle(2 * PI * noise(i.float / 33.33,
          j.float / 33.33, t))
  FlowField[W, H](width: W, height: H, field: field)

proc popFlowField(ff: var FlowField, t: float) =
  for i in 0 ..< ff.width:
    for j in 0 ..< ff.height:
      ff.field[i][j] = 10.0 * vec2FromAngle(2 * PI * noise(i.float / 33.33,
          j.float / 33.33, t))

proc getFlow(self: FlowField; location: Vec2; screenWidth,
    screenHeight: int): Vec2 =
  let x = floor(location.x / screenWidth.float * self.width.float).int
  let y = floor(location.y / screenHeight.float * self.height.float).int

  let i = min(self.field.len - 1, max(0, x))
  let j = min(self.field[i].len - 1, max(0, y))
  self.field[i][j]

func renderFlowField(f: FlowField; screenWidth, screenHeight: int) =
  for i, row in pairs(f.field):
    for j, cell in pairs(row):
      drawLine(
        (i * (screenWidth / f.field.len).int).cint,
        (j * (screenHeight / row.len).int).cint,
        ((cell.x).int + i * (screenWidth / f.field.len).int).cint,
        ((cell.y).int + j * (screenHeight / row.len).int).cint,
        Black
      )
      drawCircle(
        ((cell.x).int + i * (screenWidth / f.field.len).int).cint,
        ((cell.y).int + j * (screenHeight / row.len).int).cint,
        2.0,
        Blue
      )

proc visualise =
  const SCALE = 3
  const TILE_WIDTH = 8
  const WIDTH = 32
  const HEIGHT = 28
  const SCREEN_WIDTH: int = WIDTH * TILE_WIDTH * SCALE
  const SCREEN_HEIGHT: int = HEIGHT * TILE_WIDTH * SCALE
  const FRAME_RATE = 60

  initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib nim - agents")
  setTargetFPS(FRAME_RATE)
  defer:
    closeWindow()

  var vehicles: array[250, Vehicle]
  for i in 0 ..< 250:
    vehicles[i] = newVehicle(
      randVec2(Vec2(x: 0.0, y: 0.0), Vec2(x: SCREEN_WIDTH.float,
          y: SCREEN_HEIGHT.float)),
      1.0,
      100.0,
      100.0
    )

  var t = 0.0
  var ff = newFlowField[40, 40](t)
  while not windowShouldClose():
    t += 0.0011
    popFlowField(ff, t)
    for i, v in mpairs(vehicles):
      v.seek(v.location + ff.getFlow(v.location, SCREEN_WIDTH,
          SCREEN_HEIGHT).norm)
      v.update(1.0 / 60.0)
      if v.location.x < 0.0 or SCREEN_WIDTH.float < v.location.x or
          v.location.y < 0.0 or SCREEN_HEIGHT.float < v.location.y:
        v.location = randVec2(Vec2(x: 0.0, y: 0.0), Vec2(x: SCREEN_WIDTH.float,
            y: SCREEN_HEIGHT.float))
    beginDrawing:
      clearBackground(Darkgray)
      for v in vehicles:
        drawRectangle((v.location.x).cint, (v.location.y).cint, 5, 5, Orange)
      drawCircle(getMouseX(), getMouseY(), 10, Red)
      renderFlowField(ff, SCREEN_WIDTH, SCREEN_HEIGHT)

proc perfTest =
  const SCALE = 2
  const TILE_WIDTH = 8
  const WIDTH = 32
  const HEIGHT = 28
  const SCREEN_WIDTH: int = WIDTH * TILE_WIDTH * SCALE
  const SCREEN_HEIGHT: int = HEIGHT * TILE_WIDTH * SCALE
  const FRAME_RATE = 60

  var vehicles: array[250, Vehicle]
  for i in 0 ..< 250:
    vehicles[i] = newVehicle(
      randVec2(Vec2(x: 0.0, y: 0.0), Vec2(x: SCREEN_WIDTH.float,
          y: SCREEN_HEIGHT.float)),
      1.0,
      100.0,
      100.0
    )

  var t = 0.0
  for i in 0 ..< 100_000:
    t += 0.0011
    let ff = newFlowField[40, 40](t)
    for i, v in mpairs(vehicles):
      v.seek(v.location + ff.getFlow(v.location, SCREEN_WIDTH,
          SCREEN_HEIGHT).norm)
      v.update(1.0 / 60.0)
      if v.location.x < 0.0 or SCREEN_WIDTH.float < v.location.x or
          v.location.y < 0.0 or SCREEN_HEIGHT.float < v.location.y:
        v.location = randVec2(Vec2(x: 0.0, y: 0.0), Vec2(x: SCREEN_WIDTH.float,
            y: SCREEN_HEIGHT.float))

proc main =
  when defined(profile):
    perfTest()
  else:
    visualise()

main()
