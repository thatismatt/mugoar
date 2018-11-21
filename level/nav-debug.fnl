(local nav (require "nav"))
(local draw (require "draw"))

(local level {:name :nav-debug})

(fn level.init
  [state]
  (nav.init state)
  (nav.run state))

(set level.arrows {:N  [[0.4 0.8] [0.6 0.8] [0.5 0.2]]
                   :NE [[0.7 0.3] [0.4 0.8] [0.2 0.6]]
                   :E  [[0.2 0.4] [0.2 0.6] [0.8 0.5]]
                   :SE [[0.7 0.7] [0.4 0.2] [0.2 0.4]]
                   :S  [[0.4 0.2] [0.6 0.2] [0.5 0.8]]
                   :SW [[0.3 0.7] [0.6 0.2] [0.8 0.4]]
                   :W  [[0.8 0.4] [0.8 0.6] [0.2 0.5]]
                   :NW [[0.3 0.3] [0.6 0.8] [0.8 0.6]]})

(fn level.draw
  [state]
  (for [i 1 state.world.w]
    (for [j 1 state.world.h]
      (let [dist (-> state.nav.distance (. i) (. j))
            flow (-> state.nav.flow (. i) (. j))]
        (love.graphics.setColor (if (= dist 0)
                                    [1 1 1] ;; destination
                                    [1 0 0 (/ dist 20)]))
        (draw.shape {:shape :polygon
                     :pts [[0.1 0.1] [0.1 0.9] [0.9 0.9] [0.9 0.1]]}
                    [(- i 1) (- j 1)])
        (when flow
          (love.graphics.setColor [0 1 0])
          (draw.shape {:shape :polygon
                       :pts (. level.arrows flow)}
                      [(- i 1) (- j 1)]))))))

level
