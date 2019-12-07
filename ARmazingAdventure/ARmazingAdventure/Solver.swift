class Solver
{
    //identifying value in array
    let FLOOR = 0
    let WALL = 1
    let PLAYER = 2
    let BOSS = 3
    let MINION = 4
    let FINISHPOINT = 9
    
    var maze = [[Int]]()
    
    
    init(maze: [[Int]])
    {
        self.maze = maze
    }
    
    //returns a list of all the index locations of minions
    func getAllMinionLocations() -> [(Int, Int)]
    {
        //list containing all the minion locations
        var locations = [(Int, Int)]()

        locations.append((0,0))
        
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
        if locations.count > 1
        {
         return locations[Int.random(in: 1 ..< locations.count)]
        }
        else
        {
            return locations[0]
        }
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
    func calculateNextOptimalMove(currentLocation: (x: Int, y: Int)) -> (Int, Int, String)
    {
        //look for the 0 next to the current location
        //right
        if (currentLocation.x < 14)
        {
            if sol[currentLocation.x+1][currentLocation.y] == 0
            {
                print("Down")
                return (currentLocation.x+1, currentLocation.y, "down")
            }
        }
        //up
        if (currentLocation.y < 14)
        {
            if sol[currentLocation.x][currentLocation.y+1] == 0
            {
                print("Right")
                return (currentLocation.x, currentLocation.y+1, "right")
            }
        }
        //left
        if (currentLocation.x > 0)
        {
            if sol[currentLocation.x-1][currentLocation.y] == 0
            {
                print("Up")
                return (currentLocation.x-1, currentLocation.y, "up")
            }
        }
        //down
        if (currentLocation.y > 0)
        {
            if sol[currentLocation.x][currentLocation.y-1] == 0
            {
                print("Left")
                return (currentLocation.x, currentLocation.y-1, "left")
            }
        }
        //code should not reach here
        print("ERROR")
        return (0,0,"0")
    }
    
    //moves a random minion to a new location
    func moveRandomMinion() -> ([[Int]], String, (Int, Int))
    {
        var moved = false
        var move = (0,0,"0")
        
        let origin = selectRandomMinion(locations: getAllMinionLocations())

        if origin != (0,0)
        {
            //modify maze format for input into solver
            var modMaze = maze
            modMaze[origin.0][origin.1] = 0
            modMaze[Maze().getRow(maze: maze)][Maze().getCol(maze: maze)] = 0
            solveMaze(maze: modMaze, start: (x: origin.0, y: origin.1), end: (x: Maze().getRow(maze: maze), y: Maze().getCol(maze: maze)))

            move = calculateNextOptimalMove(currentLocation: (x: origin.0, y: origin.1))
            
            let destination = (move.0, move.1)

            //if solution found
            if destination != (0,0) && maze[destination.0][destination.1] != 2 && maze[destination.0][destination.1] != 4
            {
                //remove minion from current location
                maze[origin.0][origin.1] = 0
                //move minion to new location
                maze[destination.0][destination.1] = 4
                moved = true
            }
            else
            {
                print("CAN'T MOVE!!!")
            }
        }
        return moved ? (maze, move.2, (origin.0, origin.1)) : (maze, move.2, (0,0))
    }
    
    func getsol() -> [[Int]]
    {
        return sol
    }
    
    func getMaze() -> [[Int]]
    {
        return maze
    }
}
