(local units {})

(set units.dragster
     {:shapes [{:shape :polygon
                :pts [[1 0.25] [0 0.7] [0.6 0.7]]}
               {:shape :polygon
                :pts [[0.1 0.7] [0.3 0.75] [0.2 0.7]]}
               {:shape :ellipse
                :c [0.84 0.62] :r 0.13}]
      :size [1 1]})

(set units.factory
     {:shapes [{:shape :polygon
                :pts [[0.2 0.2] [2.8 0.2] [2.8 0.8] [0.2 0.8]]}
               {:shape :polygon
                :pts [[0.2 -0.3] [1 0.2] [0.2 0.2]]}
               {:shape :polygon
                :pts [[1 -0.3] [1.5 0.2] [1 0.2]]}
               {:shape :polygon
                :pts [[2 -0.3] [2 0.2] [1.5 0.2]]}
               {:shape :polygon
                :pts [[2.8 -0.3] [2.8 0.2] [2 0.2]]}]
      :size [3 1]})

units
