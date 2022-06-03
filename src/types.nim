type
  Cat = object
    lives: int

  Dog = object
    good: bool

  Noiser[T] = concept
    proc makeNoise(self: T)

proc meow(cat: Cat) =
  echo("meow")

proc woof(dog: Dog) =
  echo("woof")

proc makeNoise(cat: Cat) =
  cat.meow()

proc makeNoise(dog: Dog) =
  dog.woof()

proc makeLoudNoise(noiser: Noiser) =
  noiser.makeNoise()
  echo("!")

proc main() =
  let cat = Cat()
  let dog = Dog()

  cat.makeLoudNoise()
  dog.makeLoudNoise()

main()

# meow
# !
# woof
# !
