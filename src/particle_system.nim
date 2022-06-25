import std/random
import std/math
import sequtils

import vec2

type
  Particle* = object
    location*, velocity*, acceleration*: Vec2
    lifespan*: float
  
  ParticleSystem* = object
    particles*: seq[Particle]
    location, velocityMin, velocityMax, acceleration: Vec2
    generationRate, generationCount, lifespan: float

proc newParticle*(location, velocity, acceleration: Vec2; lifespan: float): Particle =
  Particle(
    location: location,
    velocity: velocity, #(x: (rand(10.0) - 5.0), y: rand(10.0) * -1.0),
    acceleration: acceleration, #(x: 0.0, y: 3.0),
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

proc newParticleSystem*(
    location, velocityMin, velocityMax, acceleration: Vec2;
    generationRate, lifespan: float
  ): ParticleSystem =
  var particles: seq[Particle] = @[]
  ParticleSystem(
    particles: particles,
    location: location,
    velocityMin: velocityMin,
    velocityMax: velocityMax,
    acceleration: acceleration,
    generationRate: generationRate,
    generationCount: 0.0,
    lifespan: lifespan
  )

proc update*(self: var ParticleSystem, dt: float) =
  for _, particle in mpairs(self.particles):
    particle.update(dt)

  self.particles = self.particles.filter(proc(p: Particle): bool = not p.isDead)

  self.generationCount += self.generationRate
  for i in 1 .. floor(self.generationCount).toInt:
    self.particles.add(
      newParticle(
        self.location,
        randVec2(self.velocityMin, self.velocityMax),
        self.acceleration,
        self.lifespan
      )
    )
    self.generationCount -= 1.0