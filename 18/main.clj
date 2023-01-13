(require '[clojure.string :as str])
(require '[clojure.set :as set])

(defn parse-line [line]
  (mapv #(Integer/parseInt %) (str/split line #",")))

(def lavas (set
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

(defn get-non-lavas [ps] 
  (set/difference ps lavas))

(defn get-lavas [ps]
  (set/intersection ps lavas))

(def ans1
  ; for each lava, get the number of non-lava neighbors
  (reduce + (map #(count (get-non-lavas (neighbors %))) lavas)))

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
        (assoc p (count (get-lavas ps)))
        (extend-state (get-non-lavas ps))))))))

(println (format "%d,%d" ans1 ans2))
