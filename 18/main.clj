(require '[clojure.string :as str])
(require '[clojure.set :as set])

(defn parse-line [line]
  (mapv #(Integer/parseInt %) (str/split line #","))
  )

(def voxels (set
  (mapv parse-line
    (str/split-lines (slurp "test")))))

(defn inbounds [p]
  (every? #(<= -1 % 20) p))

(defn neighbors [p] (set
  (filterv inbounds 
    (mapv #(mapv + p %1) 
      [[1 0 0] [-1 0 0] [0 1 0] [0 -1 0] [0 0 1] [0 0 -1]]))))

(defn count_exposed_faces [v] 
  ;; for each neighbor, if not in the voxels set, it's an exposed face
  ;; i.e, len(n for n in neighbors(v) if n not in voxels)
  (count (set/difference (neighbors v) voxels)))

(def ans1   
  (reduce + (map count_exposed_faces voxels)))

(def flooded (atom (set []))) ;; keep track of the positions already flooded

(defn is-lava [p] (contains? voxels p)) 
(defn is-not-flooded [p] (not (contains? @flooded p)))

(defn flow [p]
  (swap! flooded conj p) ;; add p to flooded set
  (reduce + 
    (mapv 
      #(cond 
        (is-lava %) 1
        (is-not-flooded %) (flow %)
        :else 0) (neighbors p))))

(def ans2
  (flow '(0 0 0)))

;;(print (neighbors '(19 0 0)))
;;(run! println voxels)
(println ans1) ;;3496
(println ans2)
