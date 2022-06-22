import std/random
import sequtils

import vec2

type
  Particle* = object
    location*, velocity*, acceleration*: Vec2
    lifespan*: float
  
  ParticleSystem* = object
    particles*: seq[Particle]
    location: Vec2
    lifespan: float

proc newParticle*(location: Vec2; lifespan: float): Particle =
  Particle(
    location: location,
    velocity: (x: (rand(10.0) - 5.0) / 60.0, y: rand(10.0) * -1.0 / 60.0),
    acceleration: (x: 0.0, y: 0.1 / 60.0),
    lifespan: lifespan
  )

proc update*(self: var Particle) =
  self.velocity = self.velocity + self.acceleration
  self.velocity = self.velocity.limit(10.0)
  self.location = self.location + self.velocity
  self.lifespan -= 1.0
  # self.acceleration = self.acceleration * 0.0

func isDead*(self: Particle): bool =
  self.lifespan <= 0.0

proc newParticleSystem*(location: Vec2; numParticles: int; lifespan: float): ParticleSystem =
  var particles: seq[Particle] = @[]
  for i in 0 .. numParticles:
    particles.add(newParticle(location, lifespan))
  ParticleSystem(particles: particles, location: location, lifespan: lifespan)

proc update*(self: var ParticleSystem) =
  for _, particle in mpairs(self.particles):
    particle.update()
  self.particles = self.particles.filter(proc(p: Particle): bool = not p.isDead)
  self.particles.add(newParticle(self.location, self.lifespan))