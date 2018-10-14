(local units (require "units"))
(local bump (require "lib.bump"))

(local world {})

(fn world.new [w h]
  {:physics (bump.newWorld)
   :w w
   :h h})

(fn world.add [state id entity coords]
  (let [[x y] coords
        unit (. units entity.unit)
        [w h] unit.size]
    (: state.world.physics :add entity x y w h)
    (tset state.entities id entity)))

(fn world.move [state dt entity on-collide]
  (let [(x y) (: state.world.physics :getRect entity)
        new-x (+ x (* (math.cos entity.heading) entity.speed dt))
        new-y (+ y (* (math.sin entity.heading) entity.speed dt))]
    (: state.world.physics :move entity new-x new-y on-collide)))

(fn world.position [state entity]
  [(: state.world.physics :getRect entity)])

world
