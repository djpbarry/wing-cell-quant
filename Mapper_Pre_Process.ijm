if(nImages < 1){
	exit("No images open - exiting");
}

original = getTitle();

getDimensions(width, height, channels, slices, frames);

channelList = newArray(channels);
for(c = 1; c <= channels; c++){
	channelList[c-1] = toString(c, 0);
}

threshList = getList("threshold.methods");
bgFiltRad = 50.0;
filtRad = 2.0;
minBranchLength = 50;
borderWidth = 5;

Dialog.create("Particle Mapper Pre-Processing");
Dialog.addChoice("Echinoid channel", channelList, channelList[channelList.length - 1]);
Dialog.addNumber("Filter radius for background subtraction", bgFiltRad);
Dialog.addNumber("Filter radius foreground", filtRad);
Dialog.addChoice("Threshold method", threshList, threshList[12]);
Dialog.addNumber("Min border length", minBranchLength);
Dialog.addNumber("Border width", borderWidth);
Dialog.show();

echChannel = parseInt(Dialog.getChoice());
bgFiltRad = Dialog.getNumber();
filtRad = Dialog.getNumber();
threshMethod = Dialog.getChoice();
minBranchLength = Dialog.getNumber();
borderWidth = Dialog.getNumber();

run("Set Measurements...", "standard");

Stack.setChannel(echChannel);

maxSD = 0;
maxIndex = -1;

// Find highest contrast slice

for (i = 1; i < slices; i++) {
	Stack.setSlice(i);
	getStatistics(area, mean, min, max, std, histogram);
	if(std > maxSD){
		maxSD = std;
		maxIndex = i;
	}
}

//Extract high contrast slice

run("Make Substack...", "channels=1-" + channels + " slices=" + maxIndex);

duplicate = getTitle();

run("Split Channels");

close(original);

echImage = "C" + echChannel + "-" + duplicate;

selectWindow(echImage);

run("Duplicate...", " ");

echDup = getTitle();

//Subtract background and suppress noise

run("Subtract Background...", "rolling=" + bgFiltRad + " sliding");
run("Gaussian Blur...", "sigma=" + filtRad);

//Create binary image

setAutoThreshold(threshMethod + " dark");
setOption("BlackBackground", false);
run("Convert to Mask");

//Skeletonise and prune

run("Skeletonize");
call("AnaMorf.SkeletonPruner.prune", minBranchLength);

prunedEchDup = getTitle();

close(echDup);

//Erode "seeds"

run("Invert");
run("Options...", "iterations=" + borderWidth + " count=1 do=Erode");

//Apply mask to Echinoid channel

imageCalculator("Multiply create 32-bit", echImage, prunedEchDup);
run("Divide...", "value=255");
resetMinAndMax();
rename(echImage + " - Masked");

close(echImage);
selectWindow(prunedEchDup);
run("Invert");
run("Invert LUT");
rename("Particle Mapper Seeds");