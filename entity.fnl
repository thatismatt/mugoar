(local world (require "world"))
(local nav (require "nav"))
(local units (require "units"))
(local utils (require "utils"))

(local entity {})

(fn entity.same-cell?
  [[ax ay] [bx by]]
  (and (= (math.floor (+ ax 1))
          (math.floor (+ bx 1)))
       (= (math.floor (+ ay 1))
          (math.floor (+ by 1)))))

(fn entity.flow-at
  [state e destination-hash [x y]]
  (-> (world.neighbours state [x y])
      (lume.map (fn [[nx ny]] {:n [nx ny]
                               :cost (-> state.nav.integration (. destination-hash) (. nx) (. ny))}))
      (lume.sort :cost)
      (lume.first)
      (. :n)))

(fn entity.waypoint
  [state e destination-pt current-pt]
  ;; if this is the first request for this destination, then create the integration field
  (when (= nil (. state.nav.integration (-> destination-pt (utils.nearest-cell) (utils.hash))))
    (nav.run state (utils.nearest-cell destination-pt))) ;; HACK: undo me

  ;; if its the last step, use the actual command point
  (if (entity.same-cell? destination-pt current-pt)
      destination-pt
      (let [destination-hash (-> destination-pt (utils.nearest-cell) (utils.hash))
            [cx cy] (utils.nearest-cell current-pt)
            [flow-x flow-y] (entity.flow-at state e destination-hash [cx cy])]
        [(- flow-x 0.5) (- flow-y 0.5)])))

(fn entity.update-entities [state]
  (-> state.entities
      (lume.filter (fn [e] (-?> e.commands (fu.not-empty?))))
      (lume.map (fn [e]
                  (let [unit (. units e.unit)
                        destination-pt (lume.first e.commands)
                        [cur-x cur-y] (world.position state e)
                        [px py] (entity.waypoint state e destination-pt [cur-x cur-y])
                        [dx dy] [(- px cur-x) (- py cur-y)]]
                    (if (< (utils.euclidean destination-pt [cur-x cur-y]) 0.01)
                        (do (table.remove e.commands 1)
                            (set e.heading nil)
                            (set e.speed nil))
                        (do (set e.heading (math.atan2 dy dx))
                            (set e.speed unit.speed))))))))

(fn entity.move-entities [state dt]
  (-> state.entities
      (lume.filter :speed)
      (lume.map (fn [e] (world.move state dt e (fn [x y] :slide))))))

entity
