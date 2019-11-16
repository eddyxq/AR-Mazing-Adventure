class Maze 
{
    var maze: [[Int]] = []
	//identifying value in array
    let FLOOR = 1
    let WALL = 0
    let PLAYER = 2
	let BOSS = 3
    let FINISHPOINT = 9
	//size of the maze
    let HEIGHT = 15
    let WIDTH = 15
		
    //generates a random maze
    func generateRandomMaze()
    {
        for _ in 0 ..< HEIGHT 
        {
            maze.append([Int](repeating: FLOOR, count: WIDTH))
        }
        for i in 0 ..< WIDTH 
        {
            maze[0][i] = WALL
            maze[HEIGHT - 1][i] = WALL
        }
        for i in 0 ..< HEIGHT 
        {
            maze[i][0] = WALL
            maze[i][WIDTH - 1] = WALL
        }
        maze[2][2] = WALL
        self.carve(x: 2, y: 2)
        maze[1][2] = WALL
        maze[HEIGHT - 2][WIDTH - 3] = WALL
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
            if maze[y1][x1] == FLOOR && maze[y2][x2] == FLOOR 
            {
                maze[y1][x1] = WALL
                maze[y2][x2] = WALL
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
        setPlayer()
		setBoss()
        setFinishPoint()
        fillOuterWall()
        return maze
    }

    //set player spawn location
    func setPlayer()
    {
        maze[1][2] = PLAYER
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
        //maze[2][1] = FINISHPOINT
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
            maze[14][12] = 9
        }
    }
}
