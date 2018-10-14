(local units {})

(set units.dragster
     {:shapes [{:shape :polygon
                :pts [[1 0.5] [0 0.95] [0.6 0.95]]}
               {:shape :polygon
                :pts [[0.1 0.95] [0.3 1] [0.2 0.95]]}
               {:shape :ellipse
                :c [0.84 0.87] :r 0.13}]
      :size [1 1]})

(set units.factory
     {:shapes [{:shape :polygon
                :pts [[0 0] [3 0] [3 1] [0 1]]}
               {:shape :polygon
                :pts [[0 -0.5] [1   0] [0   0]]}
               {:shape :polygon
                :pts [[1 -0.5] [1.5   0] [1 0]]}
               {:shape :polygon
                :pts [[2 -0.5] [2 0] [1.5 0]]}
               {:shape :polygon
                :pts [[3 -0.5] [3   0] [2 0]]}]
      :size [3 1]})

units
