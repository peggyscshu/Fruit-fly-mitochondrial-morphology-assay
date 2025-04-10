/* Mitochondria analaysis
 * Composed by PeggySCHsu
 * peggyschsu@ntu.edu.tw
 * 2022/11/18 ver1
 * 2022/11/20 ver2 add user interactive interface
 * 2022/11/30 ver3 Fix the skeleton LUT and save skeleton code
 * 2022/11/30 ver3.1 This is the version for single slice image and reduce the criteria from area 0.028 to 0.0103
 * 2023/3/11 ver3.2 - 1. Change the channel order.
 *                  - 2. Use auto local threshold instead.  
 *                  - 3. Non-airyscan is composed by 8-bit depth. The criteria of intensity mean is adjusted accordingly. Now it is 5.6. 
 *                  - 5. Tophat was applied to get local signal.
*/
// Preparation
	gs=2;
	ts=getTime();
	tifName = getTitle();
	Name = replace(tifName, ".tif", "");
	getDimensions(width, height, channels, slices, frames);
	dir1 = getDir("image");
	rename("Raw");
	run("Subtract Background...", "rolling=10");
	//run("8-bit");
	run("Set Measurements...", "area mean redirect=None decimal=4");
	run("Duplicate...", "title=LamC duplicate channels=1");
	selectWindow("Raw");
	run("Duplicate...", "title=Mito duplicate channels=2");
	selectWindow("Raw");
	close();
// Image Segmentaion
	selectWindow("Mito");
	run("Top Hat...", "radius=4 stack");
    run("Gaussian Blur...", "sigma=1 stack");
	run("Duplicate...", "title=BG duplicate");
	selectWindow("BG");
	run("Gaussian Blur...", "sigma=gs stack");
	imageCalculator("Subtract create stack", "Mito","BG");
	selectWindow("Result of Mito");
	rename("BgSubtracted");
	run("Gaussian Blur...", "sigma=1 stack");
	/*for (i = 1; i < slices+1; i++) {
		selectWindow("BgSubtracted");
		setSlice(i);
		run("Enhance Local Contrast (CLAHE)", "blocksize=50 histogram=255 maximum=3 mask=*None* fast_(less_accurate)");
	}
	//run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT", "stack");*/
	run("Merge Channels...", "c1=LamC c2=BgSubtracted create ignore");	
//User define parameters
		waitForUser("Define cell region with selection tools");
		setBackgroundColor(0, 0, 0);
		run("Clear Outside");
		Stack.setActiveChannels("01");
		run("Split Channels");
		selectWindow("C2-Composite");
		/*run("Gaussian Blur...", "sigma=1 stack");
        run("Auto Local Threshold", "method=Phansalkar radius=1 parameter_1=0 parameter_2=0 white stack");
		setThreshold(235, 255, "raw");
		run("Convert to Mask", "background=Dark black create");*/
		run("Threshold...");
		setThreshold(2, 255, "raw");
	    waitForUser("Adjust threshold");
    	run("Convert to Mask", "background=Dark black create");
		rename("Mask");
		//Clear
		selectWindow("C2-Composite");
		close();
		selectWindow("C1-Composite");
		close();
		selectWindow("BG");
		close();
// Measure mito area and intensity
	selectImage("Mask");
	setThreshold(125, 255, "raw");
	run("Analyze Particles...", "add stack");

	//filter with intensity and area
		c = roiManager("count");
		for (i = 0; i < c; i++) {
			selectWindow("Mito");
			roiManager("Select", i);
			getStatistics(area, mean, min, max, std, histogram);
			if (mean<10|| area<0.0103) {//<<------adjustable, use "Skeleton result.tif" to optimize it  0.028
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
		selectWindow("Mito");
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
		run("Duplicate...", "title=Skeleton_mask duplicate");
		setThreshold(129, 255, "raw");
		run("Convert to Mask", "background=Dark create");
		run("Skeletonize", "stack");
	//Generate skeleton checking image
		selectWindow("Mito");
		run("16-bit");
		selectWindow("MASK_Skeleton_mask");
		rename("Skeleton");
		selectWindow("Skeleton");
		run("16-bit");
		//run("Merge Channels...", "c2=Mito c4=MASK_Skeleton create keep ignore");
		run("Merge Channels...", "c2=Mito c4=Skeleton create keep ignore");
		rename("Skeleton result");
	//Measure
		//selectWindow("MASK_Skeleton");
		selectWindow("Skeleton");
		run("8-bit");
		run("Analyze Skeleton (2D/3D)", "prune=none calculate show display");
	//Save
		selectWindow("Skeleton result");
		saveAs("Tiff", path + "_Skeleton result.tif");
		//selectWindow("MASK_Skeleton-labeled-skeletons");
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