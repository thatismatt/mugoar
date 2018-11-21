(local nav {})

(fn nav.euclidean-distance [[x1 y1] [x2 y2]]
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

(fn nav.init
  [state]
  (set state.nav {:walls {} ;; cost field
                  :distance [] ;; integration field
                  :flow [] ;; flow field
                  ;; TODO: remove open & closed from the global state
                  ;;  - they are per goal (like the integration field)
                  ;;  - not required after integration field calculation
                  :open []
                  :closed {}})
  (for [_ 1 100]
    ;; TODO: create a proper cost field
    (tset state.nav.walls
          (.. (math.floor (lume.random state.world.w))
              "-"
              (math.floor (lume.random state.world.h)))
          true))
  ;; TODO: have a distance (AKA integration) field per goal
  (for [x 1 state.world.w]
    (tset state.nav.distance x [])
    (tset state.nav.flow x [])
    (for [y 1 state.world.h]
      (tset (. state.nav.distance x) y math.huge)
      (table.insert state.nav.open [x y])))
  (let [[sx sy] [10 5]] ;; TODO: don't hard code the goal
    (tset (. state.nav.distance sx) sy 0)))

(fn nav.step
  [state]
  (table.sort state.nav.open (fn [[ax ay] [bx by]]
                               (let [ac (-> state.nav.distance (. ax) (. ay))
                                     bc (-> state.nav.distance (. bx) (. by))]
                                 (< ac bc))))
  (let [[px py] (table.remove state.nav.open 1)
        p-dist (-> state.nav.distance (. px) (. py))]
    (-> (nav.neighbours state [px py])
        (lume.filter (fn [[nx ny]] (not (. state.nav.closed (.. nx "-" ny)))))
        (lume.filter (fn [[nx ny]] (not (. state.nav.walls (.. nx "-" ny)))))
        (lume.map (fn [[nx ny]]
                    (let [old-n-dist (-> state.nav.distance (. nx) (. ny))
                          dist-delta (nav.euclidean-distance [px py] [nx ny])
                          n-dist (+ p-dist dist-delta)]
                      (when (> old-n-dist n-dist)
                        (tset (. state.nav.distance nx) ny n-dist))))))
    (tset state.nav.closed (.. px "-" py) true)))

(fn nav.flow
  [state]
  (for [x 1 state.world.w]
    (for [y 1 state.world.h]
      (let [min-n (-> (nav.neighbours state [x y])
                      (lume.map (fn [[nx ny]] {:n [nx ny]
                                               :d (-> state.nav.distance (. nx) (. ny))}))
                      (lume.sort :d)
                      (lume.first)
                      (. :n))
            flow (nav.direction [x y] min-n)]
        (tset (. state.nav.flow x) y flow)))))

(fn nav.run
  [state]
  (while (not (= (# state.nav.open) 0))
    (nav.step state))
  (nav.flow state))

nav
