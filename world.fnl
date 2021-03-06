(local units (require "units"))
(local utils (require "utils"))
(local bump (require "lib.bump"))

(local world {})

(fn world.init [state w h]
  (let [world (bump.newWorld)]
    ;; world edges
    (: world :add {} -1 -1 1 (+ h 2)) ;; left
    (: world :add {}  w -1 1 (+ h 2)) ;; right
    (: world :add {} -1 -1 (+ w 2) 1) ;; top
    (: world :add {} -1  h (+ w 2) 1) ;; bottom
    (set state.world
         {:physics world
          :w w
          :h h})))

(fn world.add [state entity coords]
  (set entity.id (.. entity.unit "-" (utils.random-string 10)))
  (let [[x y] coords
        unit (. units entity.unit)
        [w h] unit.size]
    (: state.world.physics :add entity x y w h)
    (tset state.entities entity.id entity)))

(fn world.remove [state id]
  (let [entity (. state.entities id)]
    (tset state.entities id nil)
    (: state.world.physics :remove entity)))

(fn world.move [state dt entity on-collide]
  (let [(x y) (: state.world.physics :getRect entity)
        new-x (+ x (* (math.cos entity.heading) entity.speed dt))
        new-y (+ y (* (math.sin entity.heading) entity.speed dt))]
    (: state.world.physics :move entity new-x new-y on-collide)))

(fn world.neighbours
  [state [x y]]
  (let [t []]
    (for [tx (- x 1) (+ x 1)]
      (for [ty (- y 1) (+ y 1)]
        (when (and (> tx 0)
                   (> ty 0)
                   (<= tx state.world.w)
                   (<= ty state.world.h)
                   (not (and (= x tx) (= y ty))))
          (table.insert t [tx ty]))))
    t))

(fn world.position [state entity]
  [(: state.world.physics :getRect entity)])

(fn world.query-rect [state x y w h]
  (-> (: state.world.physics :queryRect x y w h)
      (lume.filter :id))) ;; remove non id-ed "rects" i.e. world edges

(fn world.query-point [state x y d]
  (world.query-rect state (- x d) (- y d) (* 2 d) (* 2 d)))

world
