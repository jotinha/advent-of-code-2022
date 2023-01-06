(module
  (import "js" "mem" (memory 1))
  (data (i32.const 0) "Hello")
  
  (func $getpiece (export "getpiece") (result i32)
    (local $piece i32)
    i32.const 1062928 ;; piece 1
    local.set $piece
    local.get $piece 
    return)

  (func (export "main") (result i32)
    call $getpiece
    i32.const 1
    i32.shl
    return)

)    

