//directory = "E:/OneDrive - The Francis Crick Institute/Working Data/Tapon/Dave_quantifications_rev/1_Ecad in F8 clones";

inputFile = File.openDialog("Choose input file");

run("Bio-Formats Importer", "open=[" + inputFile + "] autoscale color_mode=Composite rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=3 c_end=3 c_step=1");

input=getTitle();

run("FeatureJ Hessian", "smallest smoothing=10");

hessian = getTitle();

run("Find Maxima...", "prominence=10 strict output=[Single Points]");

maxima = getTitle();

selectWindow(input);

run("Gaussian Blur...", "sigma=1");

run("Marker-controlled Watershed", "input=[" + input + "] marker=[" + maxima + "] mask=None binary calculate use");

saveAs("Tiff", File.getParent(inputFile) + File.separator() + File.getNameWithoutExtension(inputFile) + "_watershed.tif");

//close("*");