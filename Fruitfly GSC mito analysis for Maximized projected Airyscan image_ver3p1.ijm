/* Mitochondria analaysis
 * Composed by PeggySCHsu
 * peggyschsu@ntu.edu.tw
 * 2022/11/18 ver1
 * 2022/11/20 ver2 add user interactive interface
 * 2022/11/30 ver3 Fix the skeleton LUT and save skeleton code
 * 2022/11/30 ver3.1 This is the version for single slice image and reduce the criteria from area 0.028 to 0.0103
 * 2025/4/10 rename "Fruitfly GSC mito analysis for Maximized projected Airyscan image_ver3p1"
 * 2025/4/10 original name "20221130_Skeleton analysis with cell boundary defining and invert LUT for 2D.ijm"
*/
// Preparation
	ts=getTime();
	tifName = getTitle();
	Name = replace(tifName, ".tif", "");
	getDimensions(width, height, channels, slices, frames);
	dir1 = getDir("image");
	rename("Raw");
	run("Subtract Background...", "rolling=50");
	//run("8-bit");
	run("Set Measurements...", "area mean redirect=None decimal=4");
	run("Duplicate...", "duplicate channels=1");
	selectWindow("Raw");
	run("Duplicate...", "title=LamC duplicate channels=2");
	selectWindow("Raw");
	close();
// Image Segmentaion
	selectWindow("Raw-1");
	run("Duplicate...", "title=Raw duplicate");
	selectWindow("Raw-1");
	run("Gaussian Blur...", "sigma=2 stack");
	imageCalculator("Subtract create stack", "Raw","Raw-1");
	selectWindow("Result of Raw");
	rename("BgSubtracted");
	for (i = 1; i < slices+1; i++) {
		selectWindow("BgSubtracted");
		setSlice(i);
		run("Enhance Local Contrast (CLAHE)", "blocksize=50 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
	}
	run("Merge Channels...", "c1=LamC c2=BgSubtracted create ignore");
	//User define parameters
		waitForUser("Define cell region with selection tools");
		setBackgroundColor(0, 0, 0);
		run("Clear Outside");
		Stack.setActiveChannels("01");
		run("Split Channels");
		selectWindow("C2-Composite");
		setThreshold(251, 65535);
		waitForUser("Adjust threshold");
		getThreshold(lower, upper);
		run("Convert to Mask", "method=Default background=Dark create");
		rename("Mask");
	//Clear
		selectWindow("Raw-1");
		close();
		selectWindow("C1-Composite");
		close();
// Measure mito area and intensity
	selectImage("Mask");
	setThreshold(125, 255, "raw");
	run("Analyze Particles...", "add stack");
	//filter with intensity and area
		c = roiManager("count");
		for (i = 0; i < c; i++) {
			selectWindow("Raw");
			roiManager("Select", i);
			getStatistics(area, mean, min, max, std, histogram);
			if (mean< 900 || area<0.0103) {//<<------adjustable, use "Skeleton result.tif" to optimize it  0.028
				selectWindow("Mask");
				roiManager("Select", i);
				run("Subtract...", "value=255 slice");
				roiManager("Select", i);
				roiManager("delete");
				c = c-1; 
				i = i-1;
			}
		}
	//Get measurement
		selectWindow("Raw");
		roiManager("Show All");
		roiManager("Measure");
	//Save
		path = dir1 + Name;
		roiManager("Save", path +"_RoiSet filtered with intensity.zip");
		saveAs("Results", path + "_MitoAreaInt.csv");		
		selectWindow("Mask");
		roiManager("Show None");
		run("Grays");
		saveAs("Tiff", path + "_Mask.tif");
	//Clear
		roiManager("Delete");
//Skeleton anslysis
	//Skeletonize the filtered mito
		selectWindow(Name + "_Mask.tif");
		run("Select None");
		run("Duplicate...", "title=Skeleton duplicate");
		setThreshold(129, 255, "raw");
		run("Convert to Mask", "method=Default background=Dark create");
		run("Skeletonize", "stack");
	//Generate skeleton checking image
		selectWindow("Raw");
		run("16-bit");
		selectWindow("Skeleton");
		run("16-bit");
		run("Merge Channels...", "c2=Raw c4=Skeleton create keep ignore");
		rename("Skeleton result");
	//Measure
		selectWindow("Skeleton");
		run("8-bit");
		run("Analyze Skeleton (2D/3D)", "prune=none calculate show display");
	//Save
		selectWindow("Skeleton result");
		saveAs("Tiff", path + "_Skeleton result.tif");
		selectWindow("Skeleton-labeled-skeletons");
		saveAs("Tiff", path + "_Skeleton code.tif");
		selectWindow("Tagged skeleton");
		saveAs("Tiff", path + "_Tagged skeleton.tif");
		selectWindow("Longest shortest paths");
		saveAs("Tiff", path + "_Longest shortest paths.tif");
		selectWindow("Results");
		saveAs("Results", path + "_Branch summary.csv");
		selectWindow("Branch information");
		saveAs("Results", path + "_Branch information.csv");
	//Clear
		run("Close All");
		run("Clear Results");
		selectWindow(Name + "_Branch information.csv");
		r = Table.size;
		if (r != 0) {
			Table.deleteRows(0, r);
		}
//Finish
	te = getTime();
	t = (te - ts)/1000;
	print(tifName + " work ended in " + t + " s");
