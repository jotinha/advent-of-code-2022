(module
  (import "js" "mem" (memory 1))
  (global $nmoves (import "js" "nmoves") i32)
  (global $world_start (import "js" "world_start") i32)
  (global $world_size (import "js" "world_size") i32)
  
  (func $getpiece (param $i i32) (result i32)
    ;;load((i%5)*4)
    (i32.rem_u
      (local.get $i)
      (i32.const 5))
    i32.const 4      
    i32.mul 
    i32.load)
          
  (func $getmove (param $i i32) (result i32)
    (i32.rem_u
      (local.get $i)
      (global.get $nmoves))
    i32.const 20
    i32.add  ;;20 + i%load(20)
    i32.load8_u)
        
  (func $getframe (param $y i32) (result i32)
    (i32.add (local.get $y) (global.get $world_start))
    i32.load
  )
 
  (func $setframe (param $frame i32) (param $y i32)
    (i32.add (local.get $y) (global.get $world_start))
    local.get $frame
    i32.store
  )
  
  (func $hits_world (param $piece i32) (param $y i32) (result i32)
    ;; (piece & getframe(y))
    (i32.and (local.get $piece) (call $getframe (local.get $y))) 
  )

  (func $piece_height (param $piece i32) (result i32)
    (local $i i32)
    (local.set $i (i32.const 0))
    (loop
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (local.set $piece  ;; piece = piece >> 8
        (i32.shr_u (local.get $piece) (i32.const 8)))
      (i32.eqz ;; piece & 0xFF == 0
        (i32.and (local.get $piece) (i32.const 0xFF)))
      (br_if 0 (i32.eqz)) ;; continue loop if not previous cond
      )
    (return (local.get $i)))
 
  (func $move_wind (param $moveidx i32) (param $piece i32) (result i32)    
    ;; shift $piece 1 bit right if getmove(moveidx) == 1 else shift 1 bit left
    (if (result i32)  
      (call $getmove (local.get $moveidx))
      (then (i32.shr_u (local.get $piece) (i32.const 1)))
      (else (i32.shl   (local.get $piece) (i32.const 1))))
  )

  (func $move_wind_unless_hit (param $moveidx i32) (param $piece i32) (param $y i32) (result i32)
    (local $candidate i32)
    (local.set $candidate 
      (call $move_wind (local.get 0) (local.get 1)))

    (if (result i32) ;; return piece if hits_world(candidate,y) else candidate
      (call $hits_world (local.get $candidate) (local.get $y))
      (then local.get $piece)
      (else local.get $candidate))
  )

  (func $place (param $piece i32) (param $y i32)
    (call $setframe 
      (i32.or (local.get $piece) (call $getframe (local.get $y)))
      (local.get $y))
  )
      
  (func $simulate (result i32)
    (local $piece_idx i32)
    (local $move_idx i32)
    (local $piece i32)
    (local $y i32)
    (local $n i32)
    (local $height i32)

    (local.set $piece_idx (i32.const 0))
    (local.set $move_idx (i32.const 0))
    (local.set $y (i32.const 4))
    (local.set $n (i32.const 1_000_000_00)) ;;1_000_000_000_0000
    (local.set $height (i32.const 0))
    (local.set $height (i32.const 0))

    ;;put a temp floor on the world
    (call $place (i32.const 0xFF) (i32.const 0))

    (local.set $piece (call $getpiece (local.get $piece_idx))) ;; piece=getpiece(piece_idx)
  
    (loop

      ;;(local.set $piece ;; piece = move_wind(move_idx, piece)
      ;;  (call $move_wind (local.get $move_idx) (local.get $piece)))

      (local.set $piece ;; piece = move_wind_unless_hit(move_idx, piece, y)
        (call $move_wind_unless_hit (local.get $move_idx) (local.get $piece) (local.get $y)))

      (local.set $y (i32.sub (local.get $y) (i32.const 1))) ;; y-- 

      (if 
        (call $hits_world (local.get $piece) (local.get $y)) 
        (then 
          (local.set $y (i32.add (local.get $y) (i32.const 1))) ;; y++     

          (call $place (local.get $piece) (local.get $y)) ;; place(piece, y)

          (local.set $y  ;; y+=piece_height
            (i32.add (local.get $y) (call $piece_height (local.get $piece))))
          
          (local.set $height ;; height = max(y,height)
            (call $max_u (local.get $y) (local.get $height)))

          (local.set $y (i32.add (local.get $height) (i32.const 3))) ;; y=height + 3

          (local.set $piece_idx ;;piece_idx++
            (i32.add (local.get $piece_idx) (i32.const 1)))

          (local.set $n ;;n--
            (i32.sub (local.get $n) (i32.const 1)))
          (local.set $piece (call $getpiece (local.get $piece_idx))) ;; piece=getpiece(piece_idx)
          )
      )

      (local.set $move_idx (i32.add (local.get $move_idx) (i32.const 1))) ;;move_idx++
      
      local.get $n
      br_if 0  ;;
      )

    (i32.sub (local.get $height) (i32.const 1)) ;; return h -1
  )

  (func $max_u (param i32) (param i32) (result i32)
    (select 
      (local.get 0) (local.get 1)
      (i32.gt_u (local.get 0) (local.get 1))))
    
  (func $build_world (param $y i32)
    (local $wall i32)
    (local.set $wall (i32.const 0x01010101))
    
    (loop ;;do setframe(wall,y); y++ while i < 2000
      (call $setframe (local.get $wall) (local.get $y))
      (local.tee $y (i32.add (local.get $y) (i32.const 4))) ;; y+=1; y
      (i32.sub (global.get $world_size) (i32.const 4))
      i32.le_u ;; loop if i <= (world_size-4)
      br_if 0))

  (func (export "main") (result i32)
    (call $build_world (i32.const 0)) ;; init world as just a wall
    ;;(call $place (call $getpiece (i32.const 1)) (i32.const 0))
    ;;(call $max_u (i32.const 0) (i32.const 10))
    call $simulate
    return)

)    

