package main

import (
    "fmt"
    "os"
)

func check(e error) {
    if e != nil {
        panic(e)
    }
}

func isIn(a byte, vals []byte) bool {
    for _, v := range vals {
        if a == v {
            return true;
        }
    }
    return false;
}

func max(a,b int) int {
    if a > b {
        return a
    } else {
        return b
    }
}

func allDifferent(vals []byte) bool {
    for i, a := range vals[1:] {
        for _, b := range vals[:i+1] {
            if (a == b) {
                return false
            }
        }
    }
    return true
}

func assert(cond bool) {
    if !cond {
        panic("assertion failed")
    }
}

func tests() {
    assert(allDifferent([]byte{0,1,2}))
    assert(!allDifferent([]byte{0,0,1}))
    assert(!allDifferent([]byte{0,1,0}))

}

func main() {
    tests()
    dat, err := os.ReadFile("input")
    check(err)

    answer := 0
    packetSize := 14
    
    for i, c := range dat {
        if (answer == 0 && i >= (packetSize-1) && allDifferent(dat[max(0,i-packetSize+1):i+1])) {
            fmt.Print("*")
            answer = i+1;
        }
        fmt.Print(string(c))

    } 
    //fmt.Print(string(dat))
    fmt.Println(answer,",TODO")
}

