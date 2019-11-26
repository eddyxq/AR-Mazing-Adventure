class Maze 
{
    var maze: [[Int]] = []
	//identifying value in array
    let FLOOR = 0
    let WALL = 1
    let PLAYER = 2
	let BOSS = 3
    let MINION = 4
    let FINISHPOINT = 9
	//size of the maze
    let HEIGHT = 15
    let WIDTH = 15
		
    //generates a random maze
    func generateRandomMaze()
    {
        for _ in 0 ..< HEIGHT 
        {
            maze.append([Int](repeating: WALL, count: WIDTH))
        }
        for i in 0 ..< WIDTH 
        {
            maze[0][i] = FLOOR
            maze[HEIGHT - 1][i] = FLOOR
        }
        for i in 0 ..< HEIGHT 
        {
            maze[i][0] = FLOOR
            maze[i][WIDTH - 1] = FLOOR
        }
        maze[2][2] = FLOOR
        self.carve(x: 2, y: 2)
        maze[1][2] = FLOOR
        maze[HEIGHT - 2][WIDTH - 3] = FLOOR
    }

    //recursively carve out floor and walls of the maze
    func carve(x: Int, y: Int) 
    {
        let upx = [1, -1, 0, 0]
        let upy = [0, 0, 1, -1]
        var dir = Int.random(in: 0 ..< 4)
        var count = 0
        while count < 4 
        {
            let x1 = x + upx[dir]
            let y1 = y + upy[dir]
            let x2 = x1 + upx[dir]
            let y2 = y1 + upy[dir]
            if maze[y1][x1] == WALL && maze[y2][x2] == WALL 
            {
                maze[y1][x1] = FLOOR
                maze[y2][x2] = FLOOR
                carve(x: x2, y: y2)
            } 
            else 
            {
                dir = (dir + 1) % 4
                count += 1
            }
        }
    }

    //returns the maze as a 2d int array
    func newStage() -> [[Int]]
    {
        generateRandomMaze()
        fillOuterWall()
        setFinishPoint()
        setPlayer()
        setBoss()
        //setMinions()
        setTestMinions()
        return maze
    }

    //set player spawn location
    func setPlayer()
    {
        maze[1][2] = PLAYER
    }

    //set minion spawn locations
    func setMinions()
    {
        //number of mininons to spawn
        let numMinions = 5
        //counter to keep track of number of minions
        var count = 0
        while count < numMinions
        {
            //randomly generated locations
            let i = Int.random(in: 2 ... 12)
            let j = Int.random(in: 2 ... 12)
            //ensure minions only spawn on the floors
            if maze[i][j] == FLOOR
            {
                maze[i][j] = MINION
                count += 1
            }
        }
    }
    
    func setTestMinions()
    {
        maze[4][2] = MINION
        maze[2][4] = MINION
        
        maze[2][2] = FLOOR
        maze[3][2] = FLOOR
        maze[2][3] = FLOOR
        
    }
	
	//set boss spawn location
    func setBoss()
    {
        maze[13][12] = BOSS
    }

    //set maze finish point
    func setFinishPoint()
    {
        maze[14][12] = FINISHPOINT
    }
	
    //returns height of maze
	func getHeight() -> Int
	{
		return HEIGHT
	}
	
    //returns width of maze
	func getWidth() -> Int
	{
		return WIDTH
	}
    
    //creates a outter rim to prevent player from falling off
    func fillOuterWall()
    {
        for i in 0 ..< 15
        {
            maze[0][i] = 1
            maze[14][i] = 1
            maze[i][0] = 1
            maze[i][14] = 1
        }
    }
    
    //rotates a array clockwise
     func rotateArrayCW(orig: [[Int]]) -> [[Int]]
     {
         let rows = Maze().getHeight()
         let cols = Maze().getWidth()

         var arr = [[Int]](repeating: [Int](repeating: 0, count: rows), count: cols)
         
         for r in 0 ..< rows
         {
             for c in 0 ..< cols
             {
                 arr[c][rows-1-r] = orig[r][c]
             }
         }
         return arr;
     }
     
     //rotates a array counter clockwise
     func rotateArrayCCW(orig: [[Int]]) -> [[Int]]
     {
         return rotateArrayCW(orig: rotateArrayCW(orig: rotateArrayCW(orig: orig)))
     }
     
    //get player row index
    func getRow(maze: [[Int]]) -> Int
     {
         var playerRow = 0;
         for row in 0 ..< HEIGHT
         {
              for col in 0 ..< WIDTH
              {
                  if (maze[row][col] == PLAYER)
                  {
                      playerRow = row;
                  }
              }
         }
         return playerRow;
     }
     
     //get player column index
     func getCol(maze: [[Int]]) -> Int
     {
         var playerCol = 0;
         for row in 0 ..< HEIGHT
         {
              for col in 0 ..< WIDTH
              {
                  if (maze[row][col] == PLAYER)
                  {
                      playerCol = col;
                  }
              }
         }
         return playerCol;
     }
    
    //returns a list of all the index locations of minions
    func getAllMinionLocations() -> [(Int, Int)]
    {
        //list containing all the minion locations
        var locations = [(Int, Int)]()

        //loops through maze, finds and adds all minions to the list
        for i in 0 ..< 15
        {
            for j in 0 ..< 15
            {
                if maze[i][j] == MINION
                {
                    locations.append((i,j))
                }
            }
        }
        return locations
    }

    //selects a random minion from a list and returns its index locations
    func selectRandomMinion(locations: [(Int, Int)]) -> (Int, Int)
    {
        return locations[Int.random(in: 0 ..< locations.count)]
    }
    
    
    //initialize array that will contain the correct path out of the maze
    var sol = [[Int]](repeating: [Int](repeating: 1, count: 15), count: 15)
    
    //bounds check to prevent index out of bounds error
    func isSafe(maze: [[Int]], x: Int, y: Int) -> Bool
    {
        if x >= 0 && x < 15 && y >= 0 && y < 15 && maze[x][y] == 0
        {
            return true
        }
        return false
    }
    
    //marks the correct maze path on the sol array
    func solveMaze(maze: [[Int]], start: (x: Int, y: Int), end: (x: Int, y: Int))
    {
        var direction = ""
        //find direction of origin to destination

        //west of origin
        if (start.x <= end.x)
        {
            if (start.y <= end.y)
            {
                //north of origin
                direction = "NW"
            }
            else
            {
                //south of origin
                direction = "SW"
            }
        }
        //east of origin
        else
        {
            if (start.y <= end.y)
            {
                //north of origin
                direction = "NE"
            }
            else
            {
                //south of origin
                direction = "SE"
            }
        }


        if (solveMazeUtil(maze: maze, start_x: start.x, start_y: start.y, end_x: end.x, end_y: end.y, direction: direction) == false)
        {
            print("ERROR!!! NO Solution")
        }

    }
    
    //solves the maze problem recursively
    func solveMazeUtil(maze: [[Int]], start_x: Int, start_y: Int, end_x: Int, end_y: Int, direction: String) -> Bool
    {
        //base case
        if (start_x == end_x && start_y == end_y)
        {
            sol[start_x][start_y] = 0
            return true
        }

        //check we are not going out of bounds
        if (isSafe(maze: maze, x: start_x, y: start_y) == true)
        {
            //mark x and y as part of the path
            sol[start_x][start_y] = 0

            if (direction == "SE")
            {
                //move forward in x direction
                if (solveMazeUtil(maze: maze, start_x: start_x - 1, start_y: start_y, end_x: end_x, end_y: end_y, direction: direction) == true)
                {
                    return true
                }
                //if x direction is incorrect we try y direction
                if (solveMazeUtil(maze: maze, start_x: start_x, start_y: start_y - 1, end_x: end_x, end_y: end_y, direction: direction) == true)
                {
                    return true
                }
            }
            else if (direction == "NW")
            {
                //move forward in x direction
                if (solveMazeUtil(maze: maze, start_x: start_x + 1, start_y: start_y, end_x: end_x, end_y: end_y, direction: direction) == true)
                {
                    return true
                }
                //if x direction is incorrect we try y direction
                if (solveMazeUtil(maze: maze, start_x: start_x, start_y: start_y + 1, end_x: end_x, end_y: end_y, direction: direction) == true)
                {
                    return true
                }
            }
            else if (direction == "SW")
            {
                //move forward in x direction
                if (solveMazeUtil(maze: maze, start_x: start_x + 1, start_y: start_y, end_x: end_x, end_y: end_y, direction: direction) == true)
                {
                    return true
                }
                //if x direction is incorrect we try y direction
                if (solveMazeUtil(maze: maze, start_x: start_x, start_y: start_y - 1, end_x: end_x, end_y: end_y, direction: direction) == true)
                {
                    return true
                }
            }
            else if (direction == "NE")
            {
                //move forward in x direction
                if (solveMazeUtil(maze: maze, start_x: start_x - 1, start_y: start_y, end_x: end_x, end_y: end_y, direction: direction) == true)
                {
                    return true
                }
                //if x direction is incorrect we try y direction
                if (solveMazeUtil(maze: maze, start_x: start_x, start_y: start_y + 1, end_x: end_x, end_y: end_y, direction: direction) == true)
                {
                    return true
                }
            }
            //if neither directions are correct, unmark x and y then backtrack
            sol[start_x][start_y] = 1
            return false
        }
        return false
    }
    
    //returns the optimal index location of the next move
    func calculateNextOptimalMove(currentLocation: (x: Int, y: Int)) -> (Int, Int)
    {
        //look for the 0 next to the current location

        //right
        if (currentLocation.x < 6)
        {
            if sol[currentLocation.x+1][currentLocation.y] == 0
            {
                print("Down")
                return (currentLocation.x+1, currentLocation.y)
            }
        }
        //up
        if (currentLocation.y < 6)
        {
            if sol[currentLocation.x][currentLocation.y+1] == 0
            {
                print("Right")
                return (currentLocation.x, currentLocation.y+1)
            }
        }
        //left
        if (currentLocation.x > 0)
        {
            if sol[currentLocation.x-1][currentLocation.y] == 0
            {
                print("Up")
                return (currentLocation.x-1, currentLocation.y)
            }
        }
        //down
        if (currentLocation.y > 0)
        {
            if sol[currentLocation.x][currentLocation.y-1] == 0
            {
                print("Left")
                return (currentLocation.x, currentLocation.y-1)
            }
        }
        //code should not reach here
        print("ERROR")
        return (0,0)
    }
    
    //moves a random minion to a new location
    func moveRandomMinion()
    {
        let origin = selectRandomMinion(locations: getAllMinionLocations())

        //remove minion from current location
        maze[origin.0][origin.1] = 0

        let destination = calculateNextOptimalMove(currentLocation: origin)
        //move minion to new location
        maze[destination.0][destination.1] = 4

    }
}
