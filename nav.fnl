(local world (require "world"))
(local units (require "units"))

(local nav {})

;; ref: http://www.gameaipro.com/GameAIPro/GameAIPro_Chapter23_Crowd_Pathfinding_and_Steering_Using_Flow_Field_Tiles.pdf

(fn nav.hash
  [[x y]]
  (.. x "-" y))

(fn nav.euclidean
  [[x1 y1] [x2 y2]]
  (let [dx (- x2 x1)
        dy (- y2 y1)]
    (+ (* dx dx) (* dy dy))))

(fn nav.neighbours
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
            (nav.hash [x y])
            (-> (world.query-rect state (- x 1) (- y 1) 1 1)
                (lume.filter (fn [entity]
                               (let [unit (. units entity.unit)]
                                 (= unit.category :building))))
                (lume.count)
                (~= 0))))))

;; cost fields are universal
;; integration fields are per destination
;;  - are they also per unit size?
;; flow fields are per destination
(fn nav.init-path
  [state request]
  (tset state.nav.integration request.hash [])
  (for [x 1 state.world.w]
    (-> state.nav.integration (. request.hash) (tset x []))
    (for [y 1 state.world.h]
      (-> state.nav.integration (. request.hash) (. x) (tset y math.huge))
      (table.insert request.open [x y])))
  (-> state.nav.integration (. request.hash) (. request.x) (tset request.y 0)))

(fn nav.step
  [state request]
  (table.sort request.open (fn [[ax ay] [bx by]]
                             (let [ac (-> state.nav.integration (. request.hash) (. ax) (. ay))
                                   bc (-> state.nav.integration (. request.hash) (. bx) (. by))]
                               (< ac bc))))
  (let [[px py] (table.remove request.open 1)
        p-dist (-> state.nav.integration (. request.hash) (. px) (. py))]
    (-> (nav.neighbours state [px py])
        (lume.filter (fn [[nx ny]] (not (. request.closed (nav.hash [nx ny])))))
        (lume.filter (fn [[nx ny]] (not (. state.nav.cost.static (nav.hash [nx ny]))))) ;; TODO: calculate costs - don't just remove them
        ;; TODO: other cost fields
        (lume.map (fn [[nx ny]]
                    (let [old-n-dist (-> state.nav.integration (. request.hash) (. nx) (. ny))
                          dist-delta (nav.euclidean [px py] [nx ny])
                          n-dist (+ p-dist dist-delta)]
                      (when (> old-n-dist n-dist)
                        (-> state.nav.integration (. request.hash) (. nx) (tset ny n-dist)))))))
    (tset request.closed (nav.hash [px py]) true)))

(fn nav.flow
  [state request]
  (-> state.nav.flow (tset request.hash []))
  (for [x 1 state.world.w]
    (-> state.nav.flow (. request.hash) (tset x []))
    (for [y 1 state.world.h]
      (let [min-n (-> (nav.neighbours state [x y])
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
   :hash (nav.hash [x y])
   :open []
   :closed {}})

(fn nav.run
  [state destination]
  (nav.cost state)
  (let [request (nav.request destination)]
    (nav.init-path state request)
    (while (not (= (# request.open) 0))
      (nav.step state request))
    (nav.flow state request)))

nav
