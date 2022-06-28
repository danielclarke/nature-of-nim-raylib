import std/random

import nimraylib_now

import vec2

type
  Vehicle = object
    location, velocity, acceleration: Vec2
    mass, maxSpeed, maxForce: float

func applyForce*(self: var Vehicle, force: Vec2) =
  let da = force / self.mass
  self.acceleration = self.acceleration + da

func seek(self: var Vehicle; target: Vec2) =
  let desired = (target - self.location).norm * self.maxSpeed
  let steer = (desired - self.velocity).limit(self.maxForce)
  self.applyForce(steer)

proc update*(self: var Vehicle, dt: float) =
  self.velocity = self.velocity + self.acceleration * dt
  self.velocity = self.velocity.limit(self.maxSpeed)
  self.location = self.location + self.velocity * dt
  self.acceleration = self.acceleration * 0.0

proc newVehicle(location: Vec2; mass, maxSpeed, maxForce: float): Vehicle =
  Vehicle(
    location: location,
    velocity: Vec2(x: 0.0, y: 0.0),
    acceleration: Vec2(x: 0.0, y: 0.0),
    mass: mass,
    maxSpeed: maxSpeed,
    maxForce: maxForce
  )

proc main =
  const SCALE = 2
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

  var vehicles: array[10, Vehicle]
  for i in 0 ..< 10:
    vehicles[i] = newVehicle(Vec2(x: 0.0, y: 0.0), 1.0, 100.0, 100.0)

  while not windowShouldClose():
    for i, v in mpairs(vehicles):
      if i == 0:
        v.seek(Vec2(x: getMouseX().float, y: getMouseY().float))
      else:
        v.seek(vehicles[i - 1].location + vehicles[i - 1].velocity / 60.0 * 10.0)    
      v.update(1.0 / 60.0)
    beginDrawing:
      clearBackground(Darkgray)
      for v in vehicles:
        drawRectangle((v.location.x).cint, (v.location.y).cint, 5, 5, Orange)
      drawCircle(getMouseX(), getMouseY(), 10, Red)


main()