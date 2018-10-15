(local units (require "units"))
(local bump (require "lib.bump"))

(local world {})

(fn world.new [w h]
  (let [world (bump.newWorld)]
    ;; world edges
    (: world :add {} -1 -1 1 (+ h 2)) ;; left
    (: world :add {}  w -1 1 (+ h 2)) ;; right
    (: world :add {} -1 -1 (+ w 2) 1) ;; top
    (: world :add {} -1  h (+ w 2) 1) ;; bottom
    {:physics world
     :w w
     :h h}))

(fn world.add [state id entity coords]
  (let [[x y] coords
        unit (. units entity.unit)
        [w h] unit.size]
    (: state.world.physics :add entity x y w h)
    (tset state.entities id entity)))

(fn world.remove [state id]
  (let [entity (. state.entities id)]
    (tset state.entities id nil)
    (: state.world.physics :remove entity)))

(fn world.move [state dt entity on-collide]
  (let [(x y) (: state.world.physics :getRect entity)
        new-x (+ x (* (math.cos entity.heading) entity.speed dt))
        new-y (+ y (* (math.sin entity.heading) entity.speed dt))]
    (: state.world.physics :move entity new-x new-y on-collide)))

(fn world.position [state entity]
  [(: state.world.physics :getRect entity)])

world
