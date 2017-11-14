
# AsmGame
Dungeon Crawler game in assembly for CS-278 

## Goals:
1. Direction retrieval without user pressing 'enter'
2. Smooth redrawing of map
3. Different maps and areas within game 

-----------
## Psuedo Code
-----------
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
