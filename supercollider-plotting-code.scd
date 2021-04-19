/*
ALL
- for some reasons the triplets and stop levels (15,16) were not saved in the raw file;

b:

b1: https://youtu.be/uYlZSyJlb3Q
// nfth: 2uV
// first few levels too short, so the function below messes up the level numbers;

b2: https://youtu.be/w71j3-qlwIU
// nfth: 2uV
// for some reason last level (call back) in raw data is missing)

b3: https://youtu.be/SYupCovHMH4
// nfth: 1.5uV (adjusted later to this value)

0- index (193)
1- ch1 (FZ) (-5850.77)
2- ch2 (PZ) (-9333.84)
3- ch3 (FP1) (9255.57)
4- ch4 (FP2) (4818.68)
5- ch5 (F3) (8894.09)
6- ch6 (F4) (-3574.63)
7- ch7 (P3) (-4985.6)
8- ch8 (P4) (10076.21)
9- Accel1 (0.004)
10- Accel2 (0.014)
11- Accel3 (-0.998)
12- Theta Median on FZ (2.4)
13- Gamma Median on PZ (0.2) //difference
14- Level Number (nil)
15- timer 1 (1)
16- timer 2 (0)
17- timer 3 (0)
18- timer 4 (0)
19- timestamp1 (11:02:46.832)
20- timestamp2 (1569492166832)


m:

m1: https://youtu.be/TUECcPCY5ks
// nfth: 2.0uV until 234520, then 1.5uV

m2: https://youtu.be/6AxMHBbaT94
// nfth: 1.5uV

m3: https://youtu.be/yEMl57CKnDw
// nfth: 1.5uV

k:
k1: (to upload to youtube)
// nfth: 2.0
// something wrong with the end?

0- index (193)
1- ch1 (FZ) (-5850.77)
2- ch2 (PZ) (-9333.84)
3- ch3 (FP1) (9255.57)
4- ch4 (FP2) (4818.68)
5- ch5 (F3) (8894.09)
6- ch6 (F4) (-3574.63)
7- ch7 (P3) (-4985.6)
8- ch8 (P4) (10076.21)
9- Accel1 (0.004)
10- Accel2 (0.014)
11- Accel3 (-0.998)
12- Theta Median on FZ (2.4)
13- Theta Threshold (10)
14- Level Number (nil)
15- timer 1 (1)
16- timer 2 (0)
17- timer 3 (0)
18- timer 4 (0)
19- timestamp1 (11:02:46.832)
20- timestamp2 (1569492166832)

*/


(
var limiter= 5;
var nfth= 1.5;
var window = Window.new("Plotter Example", Rect(0,0,1680,435)).front;
// the plotters
var plotterA = Plotter("PlotterA",Rect(0,0,1680,335),window);
var plotterB = Plotter("PlotterB",Rect(0,336,1680,100),window);
var datasetA, datasetB;

x= CSVFileReader.read("/Users/khofstadter/Dropbox/PhD/y3/20190924 bmk_shamanic_soundscape_tests/m/m3/OpenBCI-RAW-2019-10-01_10-31-39_sc_brackets_removed-level-16-amended-nfth1.5.txt");

6.do{x.removeAt(0)};

p= 0 ! (x.size/256) ! 6;

a= 0;
b= 0;
c= 0;
d= 0 ! 20;
e= 0;
x.size.do{|i|
	if (x[i][0] == "0",
		{
			p[0][a]= x[i][12].asFloat.min(limiter); //FZ theta median
			p[1][a]= x[i][14].asInt; //level
			p[2][a]= x[i][15].asInt; //current time
			p[3][a]= x[i][16].asInt; //above nf-threshold
			if (p[1][a]!== p[1][a-1],
				{ if (p[1][a]!== 0,
					{
						("level: "++((p[1][a])-1)).postln;
						b= p[2][a-4];
						("level start: "++(a-b)).postln;
						("level length: "++b++"sec").postln;
						c= p[3][a-4];
						("total above ~threshold: "++c++"sec").postln;
						d= (c*100/b).asInt;
						("above threshold: "++d++"%").postln;
						//[a-4] looks at downsampled matrix 4 seconds in the past (2 might be enough, 4 is more secure);
						// the time between two levels depends on how far we were from the next bar, check forest.scd 't.playNextBar {'
						// this needs to be fixed in the reward.scd file;
						b.do{ |f| p[5].put((a-b)+f,d)};
					}

				);
				}
			);
			a= a+1;
		}
	);
}.value;



// make an array for the nf threshold
p[4]= nfth ! p[4].size;
//use 2 lines below in case nf threshold was changed manually
//p[4][0..(234520/256).asInt]= 2.0;
//p[4][(234520/256).asInt..p[4].size-1]= 1.5;

// the datasets to visualize
datasetA = [
	p[0],
	(p[1]/3).neg+4.25,
	((p[2]/50)+(p[1]/3)).neg+4.25,
	((p[3]/50)+(p[1]/3)).neg+4.25,
	p[4],
];

datasetB = [
	p[5]
];



// setup and customize plotterA
plotterA.value_(datasetA);       // load dataset
plotterA.plotMode = \linear;
plotterA.superpose_(true);   // allow channels overlay
plotterA.setProperties(          // customize appearence
	\plotColor, [
		Color.grey,
		Color.fromHexString("#5C73F2"),
		Color.fromHexString("#5C73F2"),
		Color.green,
		Color.red], // plot colors
	\backgroundColor, Color.white, // background color
	\gridColorX, Color.grey,  	   // gridX color
	//\gridColorY, Color.yellow,   // gridY color
	\gridOnX, true,              // no horizontal grid
	\gridOnY, false            // no vertical grid
);

// setup and customize plotterA
plotterB.value_(datasetB);       // load dataset
plotterB.plotMode = \steps;
plotterB.superpose_(true);   // allow channels overlay
plotterB.specs = [[0, 100, \lin, 1]];
plotterB.setProperties(          // customize appearence
	\plotColor, [
		Color.green], // plot colors
	\backgroundColor, Color.white, // background color
	\gridColorX, Color.grey,  	   // gridX color
	//\gridColorY, Color.yellow,   // gridY color
	\gridOnX, false,              // no horizontal grid
	\gridOnY, true            // no vertical grid
);
)

