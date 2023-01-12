(require '[clojure.string :as str])

(defn parse-line [line]
  (map #(Integer/parseInt %) (str/split line #","))
  )

(def voxels (set
  (map parse-line
    (str/split-lines (slurp "test")))))

(defn inbounds [p]
  (and 
    (every? #(>= % 0) p)
    (every? #(< % 20) p)))

(defn neighbors [p]
  (filter inbounds 
    (map #(map + p %1) 
      [[1 0 0] [-1 0 0] [0 1 0] [0 -1 0] [0 0 1] [0 0 -1]])))

(defn islava [p]
  (contains? voxels p))

(def ans1 (  
  
  ))

(print (neighbors '(19 0 0)))
(print (islava '(1 2 2)))
;(run! println voxels)
