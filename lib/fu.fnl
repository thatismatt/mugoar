(local fu {})

(fn fu.remove
  [p? tbl]
  (let [r []]
    (each [k v (pairs tbl)]
      (when (not (p? v))
        (tset r k v)))
    r))

(fn fu.any?
  [p? tbl]
  ;; TODO: early exit
  (var r false)
  (each [k v (pairs tbl)]
    (set r (or r (p? v))))
  r)

(fn fu.empty?
  [tbl]
  (= nil ((pairs tbl) tbl)))

(fn fu.not-empty?
  [tbl]
  (~= nil ((pairs tbl) tbl)))

fu
