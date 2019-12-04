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
        setTestMinion()
        return maze
    }

    //set player spawn location
    func setPlayer()
    {
        maze[1][2] = PLAYER
    }
    
    //set a minion near player for testing
    func setTestMinion()
    {
        maze[4][2] = MINION
        maze[2][4] = MINION

        maze[3][2] = FLOOR
        maze[2][2] = FLOOR
        maze[2][3] = FLOOR
        maze[3][3] = FLOOR
        maze[4][3] = FLOOR
        maze[4][4] = FLOOR
        
        maze[4][6] = MINION
        maze[3][4] = FLOOR
        maze[3][5] = FLOOR
        maze[4][5] = FLOOR
        maze[2][5] = FLOOR
        maze[3][6] = FLOOR
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
     
    //get player row index
    func getRow(maze: [[Int]]) -> Int
     {
         var playerRow = 0;
         for row in 0 ..< HEIGHT
         {
              for col in 0 ..< WIDTH
              {
                  if (maze[row][col] == 2)
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
                  if (maze[row][col] == 2)
                  {
                      playerCol = col;
                  }
              }
         }
         return playerCol;
     }
}
