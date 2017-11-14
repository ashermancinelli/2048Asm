# AsmGame
Dungeon Crawler game in assembly for CS-278 

## Members:
1. Asher Mancinelli
2. Nick Little
3. Andrew Peacock
4. Steven 

## Goals:
1. Direction retrieval without user pressing 'enter'
2. Smooth redrawing of map
3. Different maps and areas within game 

## Psuedo Code:
```
while playing:

    drawMap(map)
    input = getInput()
    testInput(input)
    dir = direction(input)
    if(playerPosition == doorway)
    {map = otherMap}
    updateMap(map, direction)
```
