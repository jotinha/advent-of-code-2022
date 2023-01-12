(require '[clojure.string :as str])
(require '[clojure.set :as set])

(defn parse-line [line]
  (map #(Integer/parseInt %) (str/split line #","))
  )

(def voxels (set
  (map parse-line
    (str/split-lines (slurp "input")))))

(defn inbounds [p]
  (every? #(<= -1 % 20) p))

(defn neighbors [p] (set
  (filter inbounds 
    (map #(map + p %1) 
      [[1 0 0] [-1 0 0] [0 1 0] [0 -1 0] [0 0 1] [0 0 -1]]))))

(defn count_exposed_faces [v] 
  ;; for each neighbor, if not in the voxels set, it's an exposed face
  ;; i.e, len(n for n in neighbors(v) if n not in voxels)
  (count (set/difference (neighbors v) voxels)))

(def ans1   
  (reduce + (map count_exposed_faces voxels)))

;;(print (neighbors '(19 0 0)))
;;(run! println voxels)
(println ans1) ;;3496
