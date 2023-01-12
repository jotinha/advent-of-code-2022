(require '[clojure.string :as str])

(defn parse-line [line]
  (map #(Integer/parseInt %) (str/split line #","))
  )

(def voxels 
  (map parse-line
    (str/split-lines (slurp "test"))))

(prn voxels)
;(run! println voxels)
