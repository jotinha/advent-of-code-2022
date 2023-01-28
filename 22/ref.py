import re
import numpy as np

data = open("input").readlines()
board = data[:-2]
pwd = data[-1]

w = max(len(b) for b in board)
board = [[1 if c == '.' else 2 if c == '#' else 0 for c in b.ljust(w)] for b in board]
board = np.array(board)

board = np.pad(board, pad_width=1, mode="constant", constant_values=0)

moves = re.findall('([0-9]+|R|L)',pwd)

def move(state, steps, bm):
    for _ in range(steps):
        state = move1(state, bm)
    return state

def rotate(state, dir):
    pos, facing = state
    if dir == 'L':
        facing = facing - 1
    elif dir == 'R':
        facing = facing + 1
    else:
        raise ValueError
    facing = facing % 4
    return (pos, facing)

def move1(state, bm):
    (x,y), facing = state
    if facing == 0:
        x = x + 1
    elif facing == 1:
        y = y + 1
    elif facing == 2:
        x = x - 1
    elif facing == 3:
        y = y - 1
    else: raise ValueError
    if bm[y,x] == 0: #void
        if facing == 0:
            x = x - sum(bm[y] > 0)
        elif facing == 1:
            y = y - sum(bm[:,x] > 0)
        elif facing == 2:
            x = x + sum(bm[y] > 0)
        elif facing == 3:
            y = y + sum(bm[:,x] > 0)
    if bm[y,x] == 2: return state # wall, do nothing
    assert x > 0
    assert y > 0
    return (x,y), facing

def walk(state, moves, bm):
    for m in moves:
        if m in 'LR':
            state = rotate(state, m)
            print(m, state)
        else:
            for _ in range(int(m)):
                state = move1(state, bm)
                print(m, state)
    return state

def ans1(moves, bm):
    y0 = 1
    x0 = np.argwhere(bm[y0] == 1)[0][0]

    state0 = (x0,y0),0
    state = walk(state0, moves, board)
    (col,row),facing = state     
    return row*1000 + 4*col + facing

print(ans1(moves, board))
