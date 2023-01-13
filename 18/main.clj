(require '[clojure.string :as str])
(require '[clojure.set :as set])

(defn parse-line [line]
  (mapv #(Integer/parseInt %) (str/split line #","))
  )

(def voxels (set
  (mapv parse-line
    (str/split-lines (slurp "input")))))

(defn inbounds [p]
  (every? #(<= -1 % 20) p))

(defn move [p dir]
  (mapv + p dir))

(defn neighbors [p] (set
  (filterv inbounds
    (mapv #(move p %)
      [[1 0 0] [-1 0 0] [0 1 0] [0 -1 0] [0 0 1] [0 0 -1]]))))

(defn count_exposed_faces [v] 
  ;; for each neighbor, if not in the voxels set, it's an exposed face
  ;; i.e, len(n for n in neighbors(v) if n not in voxels)
  (count (set/difference (neighbors v) voxels)))

(def ans1   
  (reduce + (map count_exposed_faces voxels)))


(defn is-lava [p] (contains? voxels p)) 
(def is-not-lava (complement is-lava))
(defn is-flooded [p fs] (contains? fs p))
(def is-not-flooded (complement is-flooded))

(defn pick-pos-to-flow [neighbs fs]
  (first 
    (filter #(not (or (is-lava %) (is-flooded % fs))) neighbs)))

(defn count_lavas [ps]
  (count (set/intersection ps voxels)))

(defn flow [p fs]
  (def ns (neighbors p))
  (cond 
    (is-lava p) 1 
    (is-flooded p fs) 0
    ;; call flow for first neighbor
    :else (let [ns (neighbors p) fs' (conj fs p)]
      (recur (pick-pos-to-flow ns fs') fs'))))
      
(defn flow2 [p fs]
  (let [ns (neighbors p) ns' (set/intersection ns voxels)]
    (+ 
      (count ns') ; count(neighbors(p) & voxels) 
      (flow2
        (first
          (set/difference (set/difference ns ns') fs)) ; (neighbors(p) - voxels) - fs
      (conj fs p)))))

;; if len(ps) == 0: return walls
;; p = ps[0] 
;; if is-lava(p) or is-flooded(p,fs):
;;   ps' = ps.disj(p)
;; else:
;;   ps' = ps.union(neighbors(p)).disj(p)
;; if is-lava(p):
;;   walls' = walls + 1
;; else:
;;   walls' = walls
;; fs' = fs
;; return flow3(ps',fs',walls')

(defn flow3 [ps fs walls]
  (if (= (count ps) 0) walls
  (let [
    p (first ps) 
    ns (neighbors p)
    fs' (if (is-lava p) fs (conj fs p)) ; only mark as flooded if it's not lava
    unflooded-ns (set/difference ns fs)
    ps' (disj (if (is-lava p) ps (set/union ps unflooded-ns)) p)
    walls' (if (is-lava p) (+ walls 1) walls)]
  (recur ps' fs' walls'))))

(defn flow4 []
  (loop [flooded #{}
         stack #{[0,0,0]}
         result 0] 
    (if (= (count stack) 0) result
    (let [p (first stack)
          flooded' (conj flooded p)
          ns (neighbors p)
          result' (+ result (count (filter is-lava ns)))
          unflooded-ns (filter #(and (is-not-flooded % flooded) (is-not-lava %)) ns)
          stack' (set/union (disj stack p) (set unflooded-ns))
          ]
      ;(print stack')
      (recur flooded' stack' result')))))

; state is a hash-map whose keys are voxels and value is an int (number of faces) or :unvisited

; find all keys with value = :unvisited
(defn get-unvisited [state] 
  (for [[k v] state :when (= v :unvisited)] k))

; sum all values that are different from :unvisited 
(defn count-faces [state] 
  (reduce +
    (for [[k v] state :when (not (= v :unvisited))] v)))

; add neighbors to state as :unvisited unless they are already there
(defn extend-state [state neighbs] 
  (reduce (fn [s n] (if (s n) s (assoc s n :unvisited)))
    (cons state neighbs)))

(def ans2 
  (count-faces 
  (loop [state {[0,0,0] :unvisited}]
    (def p (first (get-unvisited state)))
    (def ps (neighbors p))
    (if (nil? p) state ; no more places left to visit
     (recur (->
        state
        (assoc p (count (filter is-lava ps))) ; state[p] = len(filter(is-lava,neighbors(p)))
        (extend-state (filter is-not-lava ps))))))))

;;(print (neighbors '(19 0 0)))
;;(run! println voxels)
(println ans1) ;;3496
(println ans2)
