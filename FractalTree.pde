private double fractionLength = .8; 
private int smallestBranch = 10; 
private double branchAngle = .2;  

ArrayList<Seed> seeds = new ArrayList<Seed>();
ArrayList<Tree> trees = new ArrayList<Tree>();
Rain rain;

public void setup() 
{   
	size(640,480);    
	trees.add(new Tree(320,480,75));
	trees.get(0).generateTree();
	rain = new Rain();
	background(0);
} 
ArrayList<Object> deleteList;
public void draw() 
{   
	deleteList = new ArrayList<Object>();
	fill(0, 0, 0, 25);
	stroke(0,0,0, 25);
	rect(0, 0, width, height);  
	for(Tree tree : trees)
		tree.draw();
	for(Seed s : seeds)
	{
		s.draw();
		if(s.delete)
			deleteList.add(s);
	}
	rain.draw();
	for(Object o : deleteList)
	{
		if(o instanceof Seed)
			seeds.remove(o);
	}
} 
public void mousePressed()
{
	background(0);
}
class Rain {
	ArrayList<RainDrop> raindrops = new ArrayList<RainDrop>();

	public Rain()
	{
		for(int i = 0; i < 200; i++)
		{
			raindrops.add(new RainDrop(Math.random() * width, Math.random() * height));
		}
	}

	public void draw()
	{
		ArrayList<RainDrop> resetList = new ArrayList<RainDrop>();
		for(RainDrop r : raindrops)
		{
			if(r.y > height)
				resetList.add(r);
			r.draw();
		}

		for(RainDrop r : resetList)
		{
			r.y = 0;
			r.x = Math.random() * width;
		}
	}
}
class RainDrop {
	public double x, y;
	public RainDrop(double x, double y)
	{
		this.x = x;
		this.y = y; // Yay for mixed styles
	}
	public void draw()
	{
		y++;
		x += Math.random() * 5 - 2.5;

		x = x > width ? width - x : x < 0 ? x + width : x;

		for(Tree tree : trees)
			for(Leaf l : tree.leaves)
				if(Math.pow(y - l.y, 2) + Math.pow(x - l.x, 2) < Math.pow(5 + 1, 2))
				{
					l.life += 0.5;
					y = 0;
					x = Math.random() * width;
				}

		stroke(0,0,200);
		fill(0,0,200);
		ellipse((float)x, (float)y, 1, 1);
	}
}
class Tree {
	public ArrayList<Branch> branches = new ArrayList<Branch>();
	public ArrayList<Leaf> leaves = new ArrayList<Leaf>();

	double startX, startY, branchLength;
	public Tree (double x, double y, double l)
	{
		startX = x;
		startY = y;
		branchLength = l;
	}

	public void generateTree()
	{
		branch(startX, startY, branchLength, 1.5 * Math.PI, null);
	}

	private void branch(double x,double y, double branchLength, double angle, Branch parent)
	{
		if(branchLength < smallestBranch)
		{
			Leaf l = new Leaf(x, y);
			leaves.add(l);
			if(parent != null)
				parent.addLeaf(l);
			return;
		}
		int endX1 = (int)(branchLength*Math.cos(angle) + x);
		int endY1 = (int)(branchLength*Math.sin(angle) + y);

		Branch b = new Branch(x, y, endX1, endY1);
		branches.add(b);
		if(parent != null)
			parent.addBranch(b);

		branch(endX1, endY1, branchLength * fractionLength, angle + branchAngle, b);
		branch(endX1, endY1, branchLength * fractionLength, angle - branchAngle, b);
	}

	public void draw()
	{
		ArrayList<Object> deleteList = new ArrayList<Object>();
		ArrayList<Leaf> newBranchList = new ArrayList<Leaf>();
		for(Branch b : branches)
		{
			if(!b.alive)
				deleteList.add(b);
			b.draw();
		}
		for(Leaf l : leaves)
		{
			if(!l.alive)
				deleteList.add(l);
			if(l.life >= 2.0 && Math.random() < 0.00005)
			{
				newBranchList.add(l);
			}
			l.draw();
		}
		for(Object o : deleteList)
		{
			if(o instanceof Branch)
				branches.remove(o);
			else if(o instanceof Leaf)
				leaves.remove(o);
		}
		for(Leaf l : newBranchList)
		{
			seeds.add(new Seed(l.x, l.y, branchLength * (Math.random() * 0.4 + 0.25)));
			l.life -= 2.5;
		}
	}
}
class Seed {
	private double treeX, treeY, treeLength;
	public boolean delete = false;
	public Seed(double x, double y, double l)
	{
		treeX = x;
		treeY = y;
		treeLength = l;
	}
	public void draw()
	{
		treeY++;
		treeX += Math.random() * 5 - 2.5;

		treeX = treeX > width ? width - treeX : treeX < 0 ? treeX + width : treeX;

		if(treeY >= height)
		{
			trees.add(new Tree(treeX, treeY, treeLength));
			trees.get(trees.size() - 1).generateTree();
			delete = true;
		}

		stroke(200,0,0);
		fill(200,0,0);
		ellipse((float)treeX, (float)treeY, 1, 1);
	}
}
class Branch {
	private double x1, x2, y1, y2;
	private ArrayList<Branch> subBranches = new ArrayList<Branch>();
	private ArrayList<Leaf> subLeaves = new ArrayList<Leaf>();

	public boolean alive = true;

	public Branch(double _x1, double _y1, double _x2, double _y2)
	{
		x1 = _x1;
		x2 = _x2;
		y1 = _y1;
		y2 = _y2;
	}

	public void draw()
	{
		alive = false;
		for(Leaf l : subLeaves)
			if(l.alive)
				alive = true;
		for(Branch b : subBranches)
			if(b.alive)
				alive = true;

		stroke(150,75,0);
		line((float)x1, (float)y1, (float)x2, (float)y2);
	}

	public void addLeaf(Leaf l)
	{
		subLeaves.add(l);
	}
	public void addBranch(Branch b)
	{
		subBranches.add(b);
	}
}

class Leaf {
	public double x, y;

	public double life = 1.0;
	public boolean alive = true;

	public Leaf(double _x, double _y)
	{
		x = _x;
		y = _y;
	}

	public void draw()
	{
		life -= 0.001;
		if(life <= 0)
			alive = false;

		stroke(0,(int)(life * 200),0);
		fill(0,(int)(life * 200),0);
		ellipse((float)x, (float)y, 5, 5);
	}
}
