import vec2

type
  Particle* = object
    location*, velocity*, acceleration*: Vec2
    lifespan*: float

proc newParticle*(location: Vec2; lifespan: float): Particle =
  Particle(
    location: location,
    velocity: (x: 0.0, y: 0.0),
    acceleration: (x: 0.0, y: 0.0),
    lifespan: lifespan
  )

proc update*(self: var Particle) =
  self.velocity = self.velocity + self.acceleration
  self.velocity = self.velocity.limit(10.0)
  self.location = self.location + self.velocity
  self.lifespan -= 1.0
  self.acceleration = self.acceleration * 0.0

func isDead*(self: Particle): bool =
  self.lifespan <= 0.0