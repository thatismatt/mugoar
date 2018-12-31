(local world (require "world"))
(local nav (require "nav"))
(local units (require "units"))
(local utils (require "utils"))

(local entity {})

(fn same-cell?
  [[ax ay] [bx by]]
  (and (= (math.floor (+ ax 1))
          (math.floor (+ bx 1)))
       (= (math.floor (+ ay 1))
          (math.floor (+ by 1)))))

(fn flow-at
  [state entity destination-hash [x y]]
  (-> (world.neighbours state [x y])
      (lume.map (fn [[nx ny]] {:n [nx ny]
                               :cost (-> state.nav.integration (. destination-hash) (. nx) (. ny))}))
      (lume.sort :cost)
      (lume.first)
      (. :n)))

(fn entity-waypoint
  [state entity destination-pt current-pt]
  ;; if this is the first request for this destination, then create the integration field
  (when (= nil (. state.nav.integration (-> destination-pt (utils.nearest-cell) (utils.hash))))
    (nav.run state (utils.nearest-cell destination-pt))) ;; HACK: undo me

  ;; if its the last step, use the actual command point
  (if (same-cell? destination-pt current-pt)
      destination-pt
      (let [destination-hash (-> destination-pt (utils.nearest-cell) (utils.hash))
            [cx cy] (utils.nearest-cell current-pt)
            [flow-x flow-y] (flow-at state entity destination-hash [cx cy])]
        [(- flow-x 0.5) (- flow-y 0.5)])))

(fn rect-mid
  [[rx ry] [w h]]
  [(+ rx (/ w 2)) (+ ry (/ h 2))])

(fn entity.update-entities [state]
  (-> state.entities
      (lume.filter (fn [entity] (-?> entity.commands (fu.not-empty?))))
      (lume.map (fn [entity]
                  (let [unit (. units entity.unit)
                        destination-pt (lume.first entity.commands)
                        [cur-x cur-y] (rect-mid (world.position state entity) unit.size)
                        [px py] (entity-waypoint state entity destination-pt [cur-x cur-y])
                        [dx dy] [(- px cur-x) (- py cur-y)]]
                    (if (< (utils.euclidean destination-pt [cur-x cur-y]) 0.01)
                        (do (table.remove entity.commands 1)
                            (set entity.heading nil)
                            (set entity.speed nil))
                        (do (set entity.heading (math.atan2 dy dx))
                            (set entity.speed unit.speed))))))))

(fn entity.move-entities [state dt]
  (-> state.entities
      (lume.filter :speed)
      (lume.map (fn [e] (world.move state dt e (fn [x y] :slide))))))

entity
