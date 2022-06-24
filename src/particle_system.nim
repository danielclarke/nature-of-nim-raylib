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
    velocity: (x: (rand(10.0) - 5.0), y: rand(10.0) * -1.0),
    acceleration: (x: 0.0, y: 3.0),
    lifespan: lifespan
  )

proc update*(self: var Particle, dt: float) =
  self.velocity = self.velocity + self.acceleration * dt
  self.velocity = self.velocity.limit(10.0)
  self.location = self.location + self.velocity * dt
  self.lifespan -= 1.0
  # self.acceleration = self.acceleration * 0.0

func isDead*(self: Particle): bool =
  self.lifespan <= 0.0

func p0*(self: Particle): Vec2 =
  self.location

func p1*(self: Particle): Vec2 =
  self.location + Vec2(x: 0.5, y: 0.5)

proc newParticleSystem*(location: Vec2; numParticles: int; lifespan: float): ParticleSystem =
  var particles: seq[Particle] = @[]
  for i in 0 .. numParticles:
    particles.add(newParticle(location, lifespan))
  ParticleSystem(particles: particles, location: location, lifespan: lifespan)

proc update*(self: var ParticleSystem, dt: float) =
  for _, particle in mpairs(self.particles):
    particle.update(dt)
  self.particles = self.particles.filter(proc(p: Particle): bool = not p.isDead)
  self.particles.add(newParticle(self.location, self.lifespan))