import vec2

type
  Mover* = object
    location*, velocity*, acceleration*: Vec2
    mass*, c*: float

proc newMover*(x, y, m, c: float): Mover =
  return Mover(
    location: Vec2(x: x, y: y),
    velocity: Vec2(x: 0.0, y: 0.0),
    acceleration: Vec2(x: 0.0, y: 0.0),
    mass: m,
    c: c
  )

func p0*(self: Mover): Vec2 =
  self.location

func p1*(self: Mover): Vec2 =
  self.location + Vec2(x: 1.0, y: 1.0)

proc update*(self: var Mover, dt: float) =
  self.velocity = self.velocity + self.acceleration * dt
  self.velocity = self.velocity.limit(40.0)
  self.location = self.location + self.velocity * dt
  self.acceleration = self.acceleration * 0.0

func getUpdateVelocity*(self: Mover, dt: float): Vec2 =
  return self.velocity * dt + self.acceleration * dt * dt

func applyForce*(self: var Mover, force: Vec2) =
  let da = force / self.mass
  self.acceleration = self.acceleration + da

func drag*(self: var Mover) =
  self.velocity *= self.c

func drag*(self: var Mover, c: float) =
  let speed = self.velocity.mag()
  let f = - 0.5 * c * speed * speed * self.velocity.norm() * (self.p1.x - self.p0.x)
  self.applyForce(f)