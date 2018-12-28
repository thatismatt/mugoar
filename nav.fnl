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

;; cost fields are universal
;; integration fields are per destination
;;  - are they also per unit size?
;; flow fields are per destination
(fn nav.init-path
  [state [goal-x goal-y]]
  (let [goal-hash (nav.hash [goal-x goal-y])]
    (for [x 1 state.world.w]
      (for [y 1 state.world.h]
        (tset state.nav.cost.static
              (nav.hash [x y])
              (-> (world.query-rect state (- x 1) (- y 1) 1 1)
                  (lume.filter (fn [entity]
                                 (let [unit (. units entity.unit)]
                                   (= unit.category :building))))
                  (lume.count)
                  (~= 0)))))
    (tset state.nav.integration goal-hash [])
    (for [x 1 state.world.w]
      (-> state.nav.integration (. goal-hash) (tset x []))
      (for [y 1 state.world.h]
        (-> state.nav.integration (. goal-hash) (. x) (tset y math.huge))
        (table.insert state.nav.open [x y])))
    (-> state.nav.integration (. goal-hash) (. goal-x) (tset goal-y 0))))

(fn nav.step
  [state goal]
  (let [goal-hash (nav.hash goal)]
    (table.sort state.nav.open (fn [[ax ay] [bx by]]
                                 (let [ac (-> state.nav.integration (. goal-hash) (. ax) (. ay))
                                       bc (-> state.nav.integration (. goal-hash) (. bx) (. by))]
                                   (< ac bc))))
    (let [[px py] (table.remove state.nav.open 1)
          p-dist (-> state.nav.integration (. goal-hash) (. px) (. py))]
      (-> (nav.neighbours state [px py])
          (lume.filter (fn [[nx ny]] (not (. state.nav.closed (nav.hash [nx ny])))))
          (lume.filter (fn [[nx ny]] (not (. state.nav.cost.static (nav.hash [nx ny]))))) ;; TODO: calculate costs - don't just remove them
          (lume.map (fn [[nx ny]]
                      (let [old-n-dist (-> state.nav.integration (. goal-hash) (. nx) (. ny))
                            dist-delta (nav.euclidean [px py] [nx ny])
                            n-dist (+ p-dist dist-delta)]
                        (when (> old-n-dist n-dist)
                          (-> state.nav.integration (. goal-hash) (. nx) (tset ny n-dist)))))))
      (tset state.nav.closed (nav.hash [px py]) true))))

(fn nav.flow
  [state goal]
  (let [goal-hash (nav.hash goal)]
    (-> state.nav.flow (tset goal-hash []))
    (for [x 1 state.world.w]
      (-> state.nav.flow (. goal-hash) (tset x []))
      (for [y 1 state.world.h]
        (let [min-n (-> (nav.neighbours state [x y])
                        (lume.map (fn [[nx ny]] {:n [nx ny]
                                                 :d (-> state.nav.integration (. goal-hash) (. nx) (. ny))}))
                        (lume.sort :d)
                        (lume.first)
                        (. :n))
              flow (nav.direction [x y] min-n)]
          (-> state.nav.flow (. goal-hash) (. x) (tset y flow)))))))

(fn nav.init
  [state]
  (set state.nav {:cost {:permanent []
                         :static []
                         :dynamic []}
                  :integration {}
                  :flow {}
                  ;; TODO: remove open & closed from the global state
                  ;;  - they are per goal (like the integration field)
                  ;;  - not required after integration field calculation
                  :open []
                  :closed {}}))

(fn nav.run
  [state goal]
  (nav.init-path state goal)
  (while (not (= (# state.nav.open) 0))
    (nav.step state goal))
  (nav.flow state goal))

nav
