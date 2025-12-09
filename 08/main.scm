(use-modules (ice-9 rdelim))
(use-modules (srfi srfi-1)
             (srfi srfi-13))

(define (nth lst n) (if (= 0 n) (car lst) (nth (cdr lst) (- n 1))))
(define (print args) (begin (display args) (newline)))

(define 
    (contents port) 
    (let ((line (read-line port)))
    
    (if (eof-object? line) 
        (list) 
    ; else
        (cons line (contents port)))
    )
)

(define 
    (line-to-nums line)
    (let* ((raw-nums (string-split line #\,))
        (nums (map string->number raw-nums)))
        nums
    )
)

(define
    (range s e)
        (if (= s e)
            (list)
        ; else
            (cons s (range (+ 1 s) e)))
)

(define 
    (distance v1 v2)
    (let* (
        (x1 (nth v1 0))
        (x2 (nth v2 0))
        (y1 (nth v1 1))
        (y2 (nth v2 1))
        (z1 (nth v1 2))
        (z2 (nth v2 2))
        (dx (- x1 x2))
        (dy (- y1 y2))
        (dz (- z1 z2))
    )
    (sqrt (+ (* dx dx) (* dy dy) (* dz dz)))
    )
)

(define 
    (combinations lst)
    (if (= (length lst) 0)
        (list)
    ; else
        (append (map (lambda (x) (list (car lst) x)) (cdr lst)) (combinations (cdr lst)))
    )
)

(define (take n lst) (if (= n 0) (list) (cons (car lst) (take (- n 1) (cdr lst)))))

(define (get-circuit vec list-of-hash-sets) 
    (let 
        ((res (filter (lambda (hash-set) (eq? #t (hash-ref hash-set vec))) list-of-hash-sets)))
        (if (< 0 (length res))
            (car res)
        ; else
            (let ((table (make-hash-table)))
                (hash-set! table vec #t)
                table
            )
        )
    )
)

(define (hash-merge! target source)
(hash-for-each
(lambda (key value)
    (hash-set! target key value))
source)
target)

(define (hash-merge set1 set2)
    (let 
        ((result (make-hash-table)))
        (hash-for-each (lambda (key value) (hash-set! result key value)) set1)
        (hash-for-each (lambda (key value) (hash-set! result key value)) set2)
        result
    )
)

(define (part-one-step pair-and-distance list-of-hash-sets)
    (let* (
        (pair (nth pair-and-distance 0))
        (dist (nth pair-and-distance 1))
        (v1 (nth pair 0))
        (v2 (nth pair 1))
        (v1-circuit (get-circuit v1 list-of-hash-sets))
        (v2-circuit (get-circuit v2 list-of-hash-sets))
        (merge (hash-merge v1-circuit v2-circuit))
        (filtered-hash-sets (filter (lambda (set) (and (not (equal? v1-circuit set)) (not (equal? v2-circuit set)))) list-of-hash-sets))
    )
        (cons merge filtered-hash-sets)
    )
)

(define (get-largest-three circuits)
    (take 3 (sort circuits (lambda (c1 c2) (> (hash-count (const #t) c1) (hash-count (const #t) c2)))))
)

(define (part2 pair-and-distances circuits)
    (let* (
        (next-pair (car pair-and-distances))
        (next-pair-and-distances (cdr pair-and-distances))
        (next-circuits (part-one-step next-pair circuits))
    )
        (if (> 2 (length next-circuits))
            next-pair
            (part2 next-pair-and-distances next-circuits)
        )
    )    
)

(define (extract-x-coords pair-and-distance)
    (let*
        (
            (pair (nth pair-and-distance 0))
            (v1 (nth pair 0))
            (v2 (nth pair 1))
            (x1 (nth v1 0))
            (x2 (nth v2 0))
        )
        (list x1 x2)
    )
)

(let* 
    (
        (file-name (nth (command-line) 1))
        (input (open-input-file file-name))
        (coords (map line-to-nums (contents input)))
        (coord-dist-zip (map (lambda (pair) 
            (list pair (distance (nth pair 0) (nth pair 1)))) (combinations coords)))
        (sort-dist (sort coord-dist-zip (lambda (x y) (< (nth x 1) (nth y 1)))))
        (first-thousand (take 1000 sort-dist))
        (unconnected-circuits (map (lambda (vec) (get-circuit vec (list))) coords))
        (circuits (fold (lambda (elem hash-set-list) (part-one-step elem hash-set-list)) unconnected-circuits first-thousand))
        (largest-three (get-largest-three circuits))
        (prod-largest-three (apply * (map (lambda (set) (hash-count (const #t) set)) largest-three)))
        (result-2 (part2 (drop sort-dist 1000) circuits))
        (x-coords-prod (apply * (extract-x-coords result-2)))
    )
    (display "part 1: ")
    (print prod-largest-three)
    (display "part 2: ")
    (print x-coords-prod)
)
