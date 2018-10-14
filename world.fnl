(local units (require "units"))

(local world {})

(fn world.add [state id entity coords]
  (let [[x y] coords
        unit (. units entity.unit)
        [w h] unit.size]
    (: state.world :add entity x y w h)
    (tset state.entities id entity)))

(fn world.move [state dt entity on-collide]
  (let [(x y) (: state.world :getRect entity)
        new-x (+ x (* (math.cos entity.heading) entity.speed dt))
        new-y (+ y (* (math.sin entity.heading) entity.speed dt))]
    (: state.world :move entity new-x new-y on-collide)))

world
