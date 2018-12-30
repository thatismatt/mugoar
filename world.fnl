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

(fn same-cell?
  [[ax ay] [bx by]]
  (and (= (math.floor (+ ax 1))
          (math.floor (+ bx 1)))
       (= (math.floor (+ ay 1))
          (math.floor (+ by 1)))))

(fn flow-next
  [state destination-pt current-pt]
  ;; if its the last step, use the actual command point
  (if (same-cell? destination-pt current-pt)
      destination-pt
      (let [cmd-hash (-> destination-pt (utils.nearest-cell) (utils.hash))
            [cx cy] (utils.nearest-cell current-pt)
            flow (-> state.nav.flow (. cmd-hash) (. cx) (. cy))]
        [(+ cx (. {:N  0 :NE  1 :E 1 :SE 1 :S 0 :SW -1 :W -1 :NW -1} flow) -0.5)
         (+ cy (. {:N -1 :NE -1 :E 0 :SE 1 :S 1 :SW  1 :W  0 :NW -1} flow) -0.5)])))

(fn rect-mid
  [[rx ry] [w h]]
  [(+ rx (/ w 2)) (+ ry (/ h 2))])

(fn world.update-entities [state]
  (-> state.entities
      (lume.filter (fn [entity] (-?> entity.commands (fu.not-empty?))))
      (lume.map (fn [entity]
                  (let [unit (. units entity.unit)
                        [cmd-x cmd-y] (lume.first entity.commands)
                        [cur-x cur-y] (rect-mid (world.position state entity) unit.size)
                        [px py] (flow-next state [cmd-x cmd-y] [cur-x cur-y])
                        [dx dy] [(- px cur-x) (- py cur-y)]]
                    (if (< (utils.euclidean [cmd-x cmd-y] [cur-x cur-y]) 0.01)
                        (do (table.remove entity.commands 1)
                            (set entity.heading nil)
                            (set entity.speed nil))
                        (do (set entity.heading (math.atan2 dy dx))
                            (set entity.speed unit.speed))))))))

(fn world.move-entities [state dt]
  (-> state.entities
      (lume.filter :speed)
      (lume.map (fn [e] (world.move state dt e (fn [x y] :slide))))))

(fn world.position [state entity]
  [(: state.world.physics :getRect entity)])

(fn world.query-rect [state x y w h]
  (-> (: state.world.physics :queryRect x y w h)
      (lume.filter :id))) ;; remove non id-ed "rects" i.e. world edges

(fn world.query-point [state x y d]
  (world.query-rect state (- x d) (- y d) (* 2 d) (* 2 d)))

world
