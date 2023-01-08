(module
  (import "js" "mem" (memory 1))
  (global $memsize (import "js" "memsize") i32)
  (func $getpiece (param $i i32) (result i32)
    (i32.rem_u (local.get $i) (i32.const 5)) ;; offset 
    (i32.mul (i32.const 4)) ;; *4
    i32.load
    return)

  (func $getmove (param $i i32) (result i32)
    local.get $i
    (i32.load (i32.const 20))  ;; n_moves
    i32.rem_u ;; i % n_moves
    (i32.add (i32.const 24)) ;; +24
    i32.load8_u ;; load a byte at offset 24 + i%n_moves
    return)
  
  (func $getframe (param $y i32) (result i32)
    (i32.add (local.get $y) (i32.const 64))  ;; TODO: generalize (world starts at byte 60 for test)
    i32.load
  )
 
  (func $setframe (param $frame i32) (param $y i32)
    (i32.add (local.get $y) (i32.const 64))  ;; TODO: generalize (world starts at byte 60 for test)
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
    (local $ntrims i32)

    (local.set $piece_idx (i32.const 0))
    (local.set $move_idx (i32.const 0))
    (local.set $y (i32.const 4))
    (local.set $n (i32.const 1_000_000_00)) ;;1_000_000_000_0000
    (local.set $height (i32.const 0))
    (local.set $height (i32.const 0))
    (local.set $ntrims (i32.const 0))

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

      (if ;; if height > 1900, trim world
        (i32.gt_u (local.get $height) (i32.const 9000))
        (then 
          (call $trim_world) ;; trim_world()
          (local.set $y (i32.sub (local.get $y) (i32.const 5000))) ;; y -= 1000
          (local.set $height (i32.sub (local.get $height) (i32.const 5000))) ;; h -= 1000
          (local.set $ntrims (i32.add (local.get $ntrims) (i32.const 1))) ;; ntrims++
          )
        )
        
      (local.set $move_idx (i32.add (local.get $move_idx) (i32.const 1))) ;;move_idx++

      ;; TODO: functions to incrememnt move and piece
      ;; so variables it and pieces_idx don't grow too big
      (local.set $move_idx (i32.rem_u (local.get $move_idx) (i32.const 40))) ;;move_idx=%40
      ;;TODO: unhardcode number of moves 40
      (local.set $piece_idx (i32.rem_u (local.get $piece_idx) (i32.const 5))) ;;piece_idx %= 5

      ;;(i32.mul
      ;;  (i32.lt_u (local.get $it) (i32.const 2000))
      (local.get $n)
      br_if 0  ;; loop if it < MAX_ITER and n != 0 
      )

      ;; (call $place ;; place(piece, y)
      ;;   (local.get $piece)
      ;;   (local.get $y))
      
      local.get $ntrims
      i32.const 5000
      i32.mul
      local.get $height
      i32.add
      i32.const 1
      i32.sub ;; (ntrims*1000) + h - 1
      
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
      (local.tee $y (i32.add (local.get $y) (i32.const 1))) ;; y+=1; y
      (i32.const 10_000)
      i32.lt_u ;; loop if i < 10_000
      br_if 0))

  (func $trim_world
    ;;copy n bytes from end to start ;;fill rest with world
    (local $y0 i32)
    (local $y1 i32)
    (local.set $y0 (i32.const 0))
    (local.set $y1 (i32.const 5000))
    (loop 
      (call $setframe 
        (call $getframe (local.get $y1)) 
        (local.get $y0))
      (local.set $y0 (i32.add (local.get $y0) (i32.const 4))) ;; y0 += 4
      (local.set $y1 (i32.add (local.get $y1) (i32.const 4))) ;; y1 += 4
      (i32.lt_u (local.get $y0) (i32.const 5000))
      br_if 0)
    (call $build_world (i32.const 5000))
    )

  (func (export "main") (result i32)
    (call $build_world (i32.const 0)) ;; init world as just a wall
    ;;(call $place (call $getpiece (i32.const 1)) (i32.const 0))
    ;;(call $max_u (i32.const 0) (i32.const 10))
    call $simulate
    return)

)    

