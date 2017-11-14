
# AsmGame
Dungeon Crawler game in assembly for CS-278 

Goal is to have a mainloop that waits for the user to enter a direction for the player 
to move. Psuedo code below:

-----------
#Psuedo Code
-----------
`
while playing:

  drawMap(map)

  input = getInput()
  
  testInput(input)
  
  dir = direction(input)
  
  if(playerPosition == doorway)
  
  {map = otherMap}
  
  updateMap(map, direction)
`
