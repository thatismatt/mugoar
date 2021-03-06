(local units {})

(set units.dragster
     {:category :vehicle
      :speed 10
      :shapes [{:shape :polygon
                :pts [[1 0.25] [0 0.7] [0.6 0.7]]}
               {:shape :polygon
                :pts [[0.1 0.7] [0.3 0.75] [0.2 0.7]]}
               {:shape :ellipse
                :c [0.84 0.62] :r 0.13}]
      :size [1 1]})

(set units.tank
     {:category :vehicle
      :speed 1
      :shapes [{:shape :polygon
                :pts [[0.1 0.2] [1 0.2] [0.9 0.6] [0 0.6]]}
               {:shape :ellipse
                :c [0.2 0.62] :r 0.13}
               {:shape :ellipse
                :c [0.7 0.62] :r 0.13}]
      :size [1 1]})

(set units.factory
     {:category :building
      :shapes [{:shape :polygon
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

(set units.barracks
     {:category :building
      :shapes [{:shape :polygon
                :pts [[0.2 0.2] [1.8 0.2] [1.8 0.8] [0.2 0.8]]}
               {:shape :polygon
                :pts [[0.2 -0.1] [1 0.2] [0.2 0.2]]}
               {:shape :polygon
                :pts [[1 -0.1] [1.8 0.2] [1 0.2]]}]
      :size [2 1]})

(fn units.category? [entity category]
  (let [unit (. units entity.unit)]
    (= unit.category category)))

(fn units.building? [entity]
  (units.category? entity :building))

(fn units.vehicle? [entity]
  (units.category? entity :vehicle))

units
