import std/math
import sequtils

import vec2

type
  Particle* = object
    location*, velocity*, acceleration*: Vec2
    lifespan*: float
  
  ParticleSystem* = object
    particles*: seq[Particle]
    location*, velocityMin, velocityMax, acceleration: Vec2
    generationRate, generationCount, lifespan*: float

proc newParticle*(location, velocity, acceleration: Vec2; lifespan: float): Particle =
  Particle(
    location: location,
    velocity: velocity,
    acceleration: acceleration,
    lifespan: lifespan
  )

proc update*(self: var Particle, dt: float) =
  self.velocity = self.velocity + self.acceleration * dt
  self.velocity = self.velocity.limit(10.0)
  self.location = self.location + self.velocity * dt
  self.lifespan -= dt

func isDead*(self: Particle): bool =
  self.lifespan <= 0.0

func p0*(self: Particle): Vec2 =
  self.location

func p1*(self: Particle): Vec2 =
  self.location + Vec2(x: 0.5, y: 0.5)

proc newParticleSystem*(
    location, velocityMin, velocityMax, acceleration: Vec2;
    generationRate, lifespan: float;
    numInitParticles: int
  ): ParticleSystem =
  var particles: seq[Particle] = newSeq[Particle](numInitParticles)
  for i, p in particles.mpairs:
    p.lifespan = i.float * (lifespan / (numInitParticles.float))
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

  for p in self.particles.mitems:
    if p.isDead:
      p.location = self.location
      p.velocity = randVec2(self.velocityMin, self.velocityMax)
      p.acceleration = self.acceleration
      p.lifespan = self.lifespan

  # self.particles = self.particles.filter(proc(p: Particle): bool = not p.isDead)

  # self.generationCount += self.generationRate
  # for i in 1 .. floor(self.generationCount).toInt:
  #   self.particles.add(
  #     newParticle(
  #       self.location,
  #       randVec2(self.velocityMin, self.velocityMax),
  #       self.acceleration,
  #       self.lifespan
  #     )
  #   )
  #   self.generationCount -= 1.0