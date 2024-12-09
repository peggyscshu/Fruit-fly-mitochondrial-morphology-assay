/* Mitochondria analaysis
 * Composed by PeggySCHsu
 * peggyschsu@ntu.edu.tw
 * 2024/11/28
*/
// Preparation 
	ts=getTime();
	tifName = getTitle();
	Name = replace(tifName, ".tif", ""); 
	getDimensions(width, height, channels, slices, frames);
	dir1 = getDir("image"); 
	// Create a directory in temp
  		dir2 = dir1+File.separator+Name+File.separator; 
  		File.makeDirectory(dir2);
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
	run("Gaussian Blur...", "sigma=4 stack");
	imageCalculator("Subtract create stack", "Raw","Raw-1"); 
	selectWindow("Result of Raw");
	rename("BgSubtracted");
	for (i = 1; i < slices+1; i++) {
		selectWindow("BgSubtracted");
		setSlice(i);
		run("Enhance Local Contrast (CLAHE)", "blocksize=50 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
	}
	run("Merge Channels...", "c1=LamC c2=BgSubtracted create ignore");
	//Clear
		selectWindow("Raw-1");
		close();
	//User define parameters
		run("Synchronize Windows"); 
		waitForUser("Define cell region with selection tools on composite image, then press ok"); 
		setBackgroundColor(0, 0, 0); 
		run("Clear Outside");
		Stack.setActiveChannels("01"); 
		run("Split Channels");
			//Clear
				selectWindow("C1-Composite");
				close();
		selectWindow("C2-Composite");
		setAutoThreshold("Yen dark");
		run("Threshold...");
		waitForUser("Adjust threshold, then press ok");
		getThreshold(lower, upper); 
		run("Convert to Mask", "method=Default background=Dark create");
		rename("Mask");
	//Clear
		selectWindow("C2-Composite");
		close();
//Measure mito volume and intensity
	run("3D OC Options", "volume mean_gray_value dots_size=5 font_size=10 redirect_to=Raw");
	selectImage("Mask");
	run("3D Objects Counter", "threshold=128 slice=21 min.=0.028 max.=1833348 objects statistics");
	//Save
		path = dir2 + Name;
		saveAs("Results", path + "_MitoVolInt.csv");		
		selectWindow("Mask");
	    saveAs("Tiff", path + "_Mask.tif");
	    selectImage("Objects map of Mask redirect to Raw");
	    saveAs("Tiff", path + "_3D label.tif");
	//Clear
		selectWindow(Name + "_3D label.tif");
		close();
//Skeleton anslysis 
	//Skeletonize the filtered mito
		selectWindow(Name + "_Mask.tif");
		run("Select None"); 
		run("Duplicate...", "title=Skeleton duplicate");
		setThreshold(129, 255, "raw");
		run("Convert to Mask", "method=Default background=Dark calculate black");
		run("Invert", "stack"); 
		run("Skeletonize", "stack"); 
//Generate skeleton checking image
		selectWindow("Raw");
		run("16-bit"); // normalized?
		selectWindow("Skeleton");
		setOption("ScaleConversions", true); 
		run("16-bit");
		run("Merge Channels...", "c2=Raw c4=Skeleton create keep ignore");
		rename("Skeleton result");
	//Measure
		selectWindow("Skeleton");
		setOption("ScaleConversions", true); 
		run("8-bit");
		run("Analyze Skeleton (2D/3D)", "prune=none display");
	//Save
		selectWindow("Skeleton result");
		saveAs("Tiff", path + "_Skeleton result.tif");
		selectImage("Skeleton-labeled-skeletons");
		saveAs("Tiff", path + "_Skeleton label.tif");
		selectWindow("Results");
		saveAs("Results", path + "_Branch summary.csv");
	//Clear
		run("Close All");
		run("Clear Results");
//Finish 
	te = getTime();
	t = (te - ts)/1000;
	print(tifName + " work ended in " + t + " s");
