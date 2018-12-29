(local fu {})

(fn fu.any?
  [p? tbl]
  ;; TODO: early exit
  (var r false)
  (each [k v (pairs tbl)]
    (set r (or r (p? v))))
  r)

fu
