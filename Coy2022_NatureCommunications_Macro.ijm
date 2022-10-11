//This Macro will import nd2 files, segment them into ROIs, and measure one channel of your choosing.
//It is not currently formatted to batch process measurements for multiple channels
//You can, however, manually measure secondary channels you wish to measure.

//batch processing file management
dir1 = getDirectory("Choose Source Directory ");
list = getFileList(dir1);
dir2 = dir1 + File.separator + "segmentation";
File.makeDirectory(dir2);
segoutput = dir1 + "/segmentation/";

dir3 = dir1 + File.separator + "measurements";
File.makeDirectory(dir3);
resultoutput = dir1 + "/measurements/";
setBatchMode(false);
for (i=0; i<list.length; i++) {
 showProgress(i+1, list.length);
 open(dir1+list[i]); 
 
//thresholding macro 
run("Z Project...", "projection=[Max Intensity]");
close("\\Others");
run("Slice Keeper", "first=3 last=3 increment=1");
close("\\Others");
run("Enhance Contrast...", "saturated=0.35 normalize equalize");
run("Subtract Background...", "rolling=50 sliding disable");
run("Subtract...", "value=10000");
run("Log");
setOption("ScaleConversions", true);
run("8-bit"); //sets to 255 maximum
run("Subtract...", "value=50");

//Manually separate touching cells by
//Setting color picker to foreground
//Drawing tool set to width of 2 pixels
//Now draw lines in to separate
//Note, diagonol touching pixels are still connected
waitForUser("Manually separate touching cells");

//setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(135, 255);
//setOption("BlackBackground", true);
run("Convert to Mask");

run("Analyze Particles...", "size=25-Infinity include add");

//saving ROI for each image
roiManager("deselect");
roiManager("Save", segoutput + list[i] + "-RoiSet.zip");

//use segmentation to take measurements
 close();
 open(dir1+list[i]);
 
 //v2 starts here
run("Z Project...", "projection=[Max Intensity]");
close("\\Others");
 
//we need to write in which channel you want to measure
roiManager("Show All");
waitForUser("Please select channel");
roiManager("deselect");
run("Set Measurements...", "area integrated redirect=None decimal=3");
roiManager("Measure");

//multichannel choice
//Dialog.create("Multi-channel Analysis");
//choiceset =	newArray("Yes", "No");
//	Dialog.addChoice("Measure more channels?", choiceset);	
//	Dialog.show();
	
 roiManager("reset");
 
//saving measurement results 
saveAs("Results", resultoutput + list[i] + "-results.csv");
selectWindow("Results"); 
run("Close");
close("*");
}


 //at the end, an error appears about there being  no image files in the folder, ignore it. This is a bug but it doesn't impact the analyses.
 //if you want to re-run the measurements, upload the saved ROI files and measure for the other channels. Need to refine the code.
