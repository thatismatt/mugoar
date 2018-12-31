(local world (require "world"))
(local units (require "units"))
(local utils (require "utils"))

(local nav {})

;; ref: http://www.gameaipro.com/GameAIPro/GameAIPro_Chapter23_Crowd_Pathfinding_and_Steering_Using_Flow_Field_Tiles.pdf

(fn nav.direction
  [[fx fy] [tx ty]]
  (.. (if (< ty fy) "N"
          (< fy ty) "S"
          :else "")
      (if (< tx fx) "W"
          (< fx tx) "E"
          :else "")))

(fn nav.cost
  [state]
  (for [x 1 state.world.w]
    (for [y 1 state.world.h]
      ;; TODO: other cost fields
      (tset state.nav.cost.static
            (utils.hash [x y])
            (if (->> (world.query-rect state (- x 1) (- y 1) 1 1)
                     (fu.any? units.building?))
                20
                (->> (world.query-rect state (- x 2) (- y 2) 3 3)
                     (fu.any? units.building?))
                10
                1)))))

(fn nav.integration-init
  [state request]
  (tset state.nav.integration request.hash [])
  (for [x 1 state.world.w]
    (-> state.nav.integration (. request.hash) (tset x []))
    (for [y 1 state.world.h]
      (-> state.nav.integration (. request.hash) (. x) (tset y math.huge))
      (table.insert request.open [x y])))
  (-> state.nav.integration (. request.hash) (. request.x) (tset request.y 0)))

(fn nav.integration-step
  [state request]
  (table.sort request.open (fn [[ax ay] [bx by]]
                             (let [ac (-> state.nav.integration (. request.hash) (. ax) (. ay))
                                   bc (-> state.nav.integration (. request.hash) (. bx) (. by))]
                               (< ac bc))))
  (let [[px py] (table.remove request.open 1)
        p-dist (-> state.nav.integration (. request.hash) (. px) (. py))]
    (-> (world.neighbours state [px py])
        (lume.map (fn [[nx ny]]
                    (let [old-n-dist (-> state.nav.integration (. request.hash) (. nx) (. ny))
                          dist-delta (utils.euclidean [px py] [nx ny])
                          n-cost (. state.nav.cost.static (utils.hash [nx ny])) ;; TODO: other cost fields
                          n-dist (+ p-dist (* dist-delta n-cost))]
                      (when (> old-n-dist n-dist)
                        (-> state.nav.integration (. request.hash) (. nx) (tset ny n-dist)))))))))

(fn nav.integration
  [state request]
  (nav.integration-init state request)
    (while (fu.not-empty? request.open)
      (nav.integration-step state request)))

(fn nav.flow
  [state request]
  (-> state.nav.flow (tset request.hash []))
  (for [x 1 state.world.w]
    (-> state.nav.flow (. request.hash) (tset x []))
    (for [y 1 state.world.h]
      (let [min-n (-> (world.neighbours state [x y])
                      (lume.map (fn [[nx ny]] {:n [nx ny]
                                               :d (-> state.nav.integration (. request.hash) (. nx) (. ny))}))
                      (lume.sort :d)
                      (lume.first)
                      (. :n))
            flow (nav.direction [x y] min-n)]
        (-> state.nav.flow (. request.hash) (. x) (tset y flow))))))

(fn nav.init
  [state]
  (set state.nav {:cost {:permanent []
                         :static []
                         :dynamic []}
                  :integration {}
                  :flow {}}))

;; create the transient state required for a path request
(fn nav.request
  [[x y]]
  {:x x
   :y y
   :hash (utils.hash [x y])
   :open []})

(fn nav.run
  [state destination]
  (nav.cost state)
  (let [request (nav.request destination)]
    (nav.integration state request)
    (nav.flow state request)))

nav
