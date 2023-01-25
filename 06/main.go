package main

import (
    "fmt"
    "os"
)

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

func findStartPackage(data []byte, packetSize int) int {
    for i, _ := range data[packetSize:] {
        if allDifferent(data[i:packetSize+i]) {
            return i+packetSize;
        }
    } 
    return 0; 
}

func main() {
    tests()

    dat, err := os.ReadFile("input")
    if err != nil {
        panic(err)
    } 

    fmt.Printf("%d,%d\n", findStartPackage(dat, 4), findStartPackage(dat, 14))
}

