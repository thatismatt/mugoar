(local units (require "units"))
(local utils (require "utils"))
(local splash (require "lib.splash"))

(local world {})

(fn world.init [state w h]
  (let [physics (splash.new)]
    ;; world edges
    (: physics :add {} (splash.seg 0 0 0 h)) ;; left
    (: physics :add {} (splash.seg w 0 0 h)) ;; right
    (: physics :add {} (splash.seg 0 0 w 0)) ;; top
    (: physics :add {} (splash.seg 0 h w 0)) ;; bottom
    (set state.world
         {:physics physics
          :w w
          :h h})))

;; TODO: should this be aware of the shape we are adding?
(fn world.add [state entity coords]
  (set entity.id (.. entity.unit "-" (utils.random-string 10)))
  (let [[x y] coords
        unit (. units entity.unit)]
    (: state.world.physics :add entity (splash.circle x y (/ unit.size 2)))
    (tset state.entities entity.id entity)))

(fn world.remove [state id]
  (let [entity (. state.entities id)]
    (tset state.entities id nil)
    (: state.world.physics :remove entity)))

(fn world.move [state dt entity on-collide]
  (let [(x y) (: state.world.physics :pos entity)
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
  [(: state.world.physics :pos entity)])

(fn world.query-rect [state x y w h]
  (-> (: state.world.physics :queryShape (splash.aabb x y w h))
      (lume.filter :id))) ;; remove non id-ed "rects" i.e. world edges

(fn world.query-point [state x y r]
  (-> (: state.world.physics :queryShape (splash.circle x y r))
      (lume.filter :id)))

world
