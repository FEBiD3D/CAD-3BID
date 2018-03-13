function FEBiD_CAD_v9p2

clear; close all; clear mem; clc;

% (*) An exposure "element" is either a "pillar" or "segment" in the 3D
% object design.  At certain places in the program comments below the 
% term "segment" is used in place of "element".  For example, in the 
% auto segment detection algorithm all exposure elements are being 
% detected, not just segments

% (*) search "pause" to see where this function is used below

% General variables
global FigHue UIHue

% GUI_UserInput_...
global FleetingFileName  iSituation Request LeftButtonText RightButtonText

% GUI_VertexDefine_...
global xyAxis xyzAxis xMin xMax yMin yMax zMin zMax x_t str_x_t xCube yCube...
    zCube v_i nv vt y_t str_y_t Pxy Pxyz z_t str_z_t VOI...
    Pobj_xy_t Pobj_xyz_t aza ele sCube Tog3DCam...
    xyzMouse iMap VertexHue...
    Io1D dLam Seg1D Obj_Hist izAxis SegMax ImportFileName vNow iVOIAng...
    SwitchState xyBadObj

% GUI_VertexCopy_...
global vRange sdx DxShift_Trig DxShift_Sign...
    sdy DyShift_Trig DyShift_Sign sdz DzShift_Trig DzShift_Sign...
    yInversion

% GUI_SegmentManual_...
global Pobj_Segments ei ef nSeg lvl s_i s_f eIdx n_e...
    MaxExposureLevel MaxSegsPerLevel Pobj_Segments_idxs SegmentHue  lvlNow xPort

% GUI_DesignActions_...
global NewActions UndoRedo strNewActions LoadName SaveName...
    PartialName

% GUI_FolderManage_...
global DesignFolderName SaveDesignFolderName

% GUI_SegmentAutomatic_...
global Lxyz1D dLxyz1D n_Lxyz1D c_Lxyz1D MaxNumSegsPerNode Pairs2D Pairs Seg MaxNumSegsPerLevel...
    VperL VperL_Next OneCount2D xAxisMaxHistogram nIdx

% GUI_Operations_...
global theta alpha beta rWrap

% GUI_Expose_...
global vDz ds tdPillar ShowShots tD1D...
    Zeta1D BuildCADHue tdMax_FEI FileName CalibrationFileInfo PIA...
    BitDepth Mag MagHFW PatterningEngine tdMax_NVPE xBasis yBasis...
    sPerLevel xArtifact yArtifact pow2_Bits tdMax_NVPE_MinMax

% GUI_Calibration_...
global VGR pPD rPD rVGR dVGR rpPD dpPD rrPD drPD dSeg...
    xDwell zAngle tzAxesLimits ExpPoints zAngleFit Ptz PtzFit ExpPlot...
    FitPlotData CalibrateByExpData FitVGR FitpPD FitrPD...
    dSegMax xFit zFit Sig ZetaMin ZetaMax iPoP TauMaxFit dTau...
    ForbiddenTau TauMin ZetaLimit FWHM rN dAng SurfaceNodes FitrN...
    FittedCalibData GlobalFit Rule_1_Max Rule_1_Max_MinMax...
    rN_MinMax FWHM_MinMax

% GUI_Advanced_...
global AdvVar f_tDe f_tDe_MinMax AdvVarUnits PrxCi PrxCf ProxCorrOn...
    PrxCi_MinMax PrxCf_MinMax sPerLevel_MinMax



% Supporting files upload
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Folder names located in FEBiD 3D CAD (Supporting Files)
SupportingFilesFolderName = 'FEBiD 3D CAD (Supporting Files)';
GUIPushButtonFolder = 'GUI Pushbutton Images';
GUIScaleFolder = 'GUI Size and Scale';
% Default folder name for design
PartialName = 'FEBiD 3D CAD Design'; %[str]

cd(SupportingFilesFolderName)
% This file exists if a new calibration file has been submitted via the
% GUI, besides the three files included with the program.  If this file is
% deleted, the GUI returns to the initial state of having only the three
% calibration files included with the program.
RecipesAndMicroscopes = exist('HistoryOfExp.mat','file'); %[0/2]
% This variable appends to the design folder name, if the default design
% folder name is chosen, to give the folder a unique name.  This variable
% advances {i_xPort} everytime a new design is created.
load uID UniqueID i_xPort
% Check a new default folder for design
UniqueID = UniqueID + 1; %[1,2,3,...]
save uID UniqueID i_xPort

% Various images used in the GUI
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
cd(GUIPushButtonFolder)
fMap = imread('For.bmp');
bMap = imread('Back.bmp');
uMap = imread('Up.bmp');
dMap = imread('Down.bmp');
lMap = imread('Left (Seg).bmp');
rMap = imread('Right (Seg).bmp');
sOff = imread('SwitchOff.bmp');
sOn = imread('SwitchOn.bmp');
camMap = imread('Clic.bmp');
Press = imread('Transfer.bmp');
lMap_Small = imread('Left (Seg) (Small).bmp');
rMap_Small = imread('Right (Seg) (Small).bmp');
cd ../



% GUI Size and Scaling (read file)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
cd(GUIScaleFolder)
% Text file (read)
DuplicationFileName = 'FEBiD_CAD_GUI_Info.txt';
% Open array duplication file
GUIFileID = fopen(DuplicationFileName,'r');
% Extract parameter from the duplication file
GUIData = textscan(GUIFileID, ...
    '%*s %f %*s %f', ...
    'Delimiter', '\n', ...
    'CollectOutput',true);

% GUI size expansion/contraction factor
fGUI = GUIData{1}(1,1); %[]
if fGUI < 0.75
    fGUI = 0.75; %[]
elseif fGUI > 1.25
    fGUI = 1.25; %[]
end

% Font Size
FS = fGUI.*GUIData{1}(1,2); %[points]
if FS < 6
    FS = 6; %[]
elseif FS > 17
    FS = 17; %[]
end

% Close the array duplication file
fclose(GUIFileID);
cd ../
cd ../



% Calibration files
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% The User has not created new calibration files = 0, User has created
% calibration files = 2
if RecipesAndMicroscopes == 0
    
    % The calibration file that is loaded when the program is launched
    Recipe = 1; %[1,2,3,...]
    % List of names of calibration text files located in FEBiD 3D CAD
    % (Supporting Files)
    Recipes = {'Pt_FEINova600','Pt_ZeissNanoFab','Pt_FEINova200'};
    % The number of calibration files
    nRecipes = size(Recipes,2); %[1,2,3,...]
    % Calibration files are selected from a dropdown menu
    RecipesPopUp = sprintf('%s |',Recipes{1,1:size(Recipes,2)});
    RecipesPopUp = sprintf('%snew',RecipesPopUp);
    % Critical experimental conditions during FEBiD segment calibration
    % file creation
    CalibrationFileInfo = {'Energy = 30[keV], Current = 21[pA], Nozzle_X = 0[um], Nozzle_Y = 150[um], Nozzle_Z = 100[um], T = 45[C], Gas = Pt, GIS = 52[deg], Sub=5nmSiO2/Si',...
        'Energy = 25[keV], Current = 1[pA], Nozzle_X = {x}[um], Nozzle_Y = {x}[um], Nozzle_Z = {x}[um], T = {x}[C], Gas = Pt, GIS = {x}[deg] Ion = He[+], Sub={x}',...
        'Energy = 30[keV], Current = 21[pA], Nozzle_X = 30[um], Nozzle_Y = 170[um], Nozzle_Z = 470[um], T = 45[C], Gas = Pt, GIS = 38[deg], Sub=5nmSiO2/Si'};
elseif RecipesAndMicroscopes == 2
    cd(SupportingFilesFolderName)
    load HistoryOfExp Recipe Recipes nRecipes RecipesPopUp CalibrationFileInfo MagHFW
    cd ../
end



% Parameters
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% FEBiD CAD GUI Title
Intro = 'FEBiD 3D Direct-Write CAD'; %[s]
% FEBiD CAD GUI version for display
SubIntro = 'Version 9.2 (light)'; %[s]

% Patterning engine setting using to format the FEBID exposure file
PatterningEngine = 1; %[FEI == 1/NVPE = 2]
% Image frame pixel point pitch
iPoP = 1.0; %[nm]

% {x} axis display limits (2D and 3D plots)
xMin = -296;   xMax = 296; %[nm]
% {y} axis display limits (2D and 3D plots)
yMin = -296;   yMax = 296; %[nm]
% {z} axis display limits
zMin = 0;   zMax = 888; %[nm]
% Vertex text label displacement in the 2D and 3D plots scales with the
% length of the x-axis in order to avoid vertex and vertex text label
% overlap
dText = 10./500; %[points/nm]

% Pixel point pitch for FEBID exposure
ds = 1.0; %[nm]

% Minimum allowable dwell time as initialized.  This value is reset to the minimum dwell
% time used in a calibration file.  The value can also be changed by the
% User in the GUI
TauMin = 1.0; %[ms]

% Vertical growth rate (experimentally measured value)
vDz = 135; %[nm/s]

% Bin size for vertex spacing histogram
dLam = 25; %[nm]
% Anticipated, maximum segment length
SegMax = 2000; %[nm]

% The order of FEBID pixel exposure can be visualized during exposure file
% creation by selecting the "Shots ?" GUI element.  The default setting is for every
% shot to be displayed [=1].  This can be changed in the "Adv" dropdown menu
% on the GUI
AllShots = 1; %[0/1]
% If AllShots = 0, then FEBID pixel exposure will be shown every
% {sPerLevel} passes through the exposure level.  All segment exposures
% will be shown.
sPerLevel = 10; %[1,2,3,...]

% FEI artifact dwell dwell.  Applies only to FEI instrument with 12-bit
% patterning capability.  The pixel defined by these coordinates will be
% exposed for the minimum dwell time, specified by the variable {PIA}, at
% th very beginning and ending of an exposure file to avoid unwanted
% exposure artifacts on the main 3D object
xArtifact = 450; %[nm]
yArtifact = 450; %[nm]


% Proximity correction increment {PrxCi} applied at the beginning of segment
% growth*?
% (*) only applies for vertices with multiple diverging segments.
% Also, an increment of {~PoP} is automatically applied such that
% {PrxCi} is an additional displacement
PrxCi = 0; %[nm]
% Proximity correction increment {PrxCf} applied at the end of segment
% growth**?
% (**) only applies for vertices where multiple segments converge
PrxCf = 2; %[nm]

% Proximity correction on?
ProxCorrOn = false; %[0/1]
if PrxCi ~= 0 || PrxCf ~= 0
    ProxCorrOn = true; %[0/1]
end

% Calibration curve fitting variable.  This variable defines a pre-existing
% deposit nuclei, prior to FEBID, which emulates the time delay exhibiting
% in the calibration curve
rN = 0.5; %[nm]
% The value of {rN} that produces the best fit of the calibration curve.
FitrN = rN; %[nm]
% Calibration curve fitting is derived from a time-dependent model of FEBID
% where a surface evolves, starting from a semi-circular nuclei.  The
% semi-circular nuclei is defined also by surface nodes with a spacing of
% {dAng} radians.  As the surface evolves during FEBID, the surface is
% constantly rediscretized maintaining as close as possible the spacing
% {dAng}
dAng = 10.*pi./180; %[rad]

% Main GUI width
wFig = 1850; %[]
% Main GUI height
hFig = 1000; %[]

% The background color for the main GUI
FigHue = [0.8 0.8 0.9]; %[r g b]
% GUI text input box color
UIHue = [1 1 1]; %[r g b]
% Vertex color for 3D object CAD
VertexHue = [0 0.4 0]; %[r g b]
% Build CAD execution hue
BuildCADHue = [0.5 0 0.5]; %[r g b]
% Segment color for 3D object "pillar" and "segment" element definition
SegmentHue = [0 0 1]; %[r g b]
% Color for GUI features related to curve fitting
FitHue = [0.5 0 0.5]; %[r g b]

% Input/output requested User info {x} window size
wFigInfo = 550; %[]
% Input/output requested User info {x} window size
hFigInfo = 125; %[]
% Input/output requested User info {x} position
x0_FigInfo = (1920./2) - (wFigInfo./2); %[]
% Input/output requested User info {x} position
y0_FigInfo = (1080./2) - (hFigInfo./2); %[]
% Padding in input/output figure
Pad = 10; %[]
% Text box position in input/output figure
yReq = 80; %[]
% Edit box {y} position in input/output figure
yType = 40; %[]
% Pushbutton width in the input/output figure
PressWidth = 80; %[]

% GUI: Initial azimuthal value for 3D plot
aza = 30; %[deg]
% GUI: Initial elevation value for 3D plot
ele = 30; %[deg]

% Anticipated # of 3D object vertices
NumVertices_Limit = 1000; %[1,2,3,...]
% Anticipated # of exposure levels
NumExpLevels_Limit = 500; %[1,2,3,...]
% Anticipated # of segments per level
NumSegsPerLevel_Limit = 100; %[1,2,3,...]
% Maximum anticipated # of pixel exposures
NumShots_Limit = 100000; %[]

% Automatic segment detection variables
% ooooooooooooooooooooooooooooooooooooooooooooooo
% Anticipated number of segment lengths that can be submitted during
% automatic segment detection
MaxNumBins = 20; %[]
% Anticipated, maximum number of segment connections per vertex during
% automatic segment detection
MaxNumSegsPerNode = 10; %[1,2,3,...]
% Anticipated, maximum number of segments per level (automatic segment
% detection)
MaxNumSegsPerLevel = 100; %[1,2,3,...]
% Anticipated, maximum number of vertex spacing per bin in the vertex
% spacing histogram
xAxisMaxHistogram = 10; %[1,2,3,...]

% Anticipated, maximum number of remeshing operations
NumReMeshOps = 20; %[1,2,3,...]


% Maximum dwell time (FEI instrument related)
% (*) Dwell times that exceed this value will be divided into multiple,
% shorter exposures that will equal the required dwell time
tdMax_FEI = 4.6; %[ms]
% Dwell time applied for "'pillar" element growth
% (*) should be less than {tdMax_FEI}
tdPillar = 0.1.*floor(tdMax_FEI./0.1); %[ms]
% Constant dwell time (NVPE)
tdMax_NVPE = 0.5; %[ms]
% Minimum dwell time per pixel.  The setting was chosen based on the PIA
% range of the 12-bit FEI system but should be compatible with all
% patterning engines
PIA = 0.0016; %[ms]
% Bit-depth/spatial coordinates (FEI instrument related)
BitDepth = 12; %[12/16]
% Image size*Magnification factor (Instrument specific)
MagHFW = 128000; %[1,2,3,...]
% Patterning aspect ratio (SEM image size ratio)
pAspRatio = 884./1024; %[]
% Maximum allowable dwell time (when using fitted data)
TauMaxFit = 100; %[ms]
% Dwell time increment (when using fitted data)
dTau = 1.0; %[ms]
% Maximum allowable number of surface nodes for an evolving surface in the
% fitting algorithm
SurfaceNodes = 200; %[1,2,3,...]
% Axis limits in segment angle plot 
tzAxesLimits = [0 80 0 80]; %[ms,ms,degrees,degrees]
% Axis tick mark positions for segment axis
tzAxesYTick = [0 20 40 60 80]; %[ms]
% Initial value of minimization parameter for data fitting.
GlobalFit = 1E9; %[]
% Allowable difference between the experimental segment angle and fitted
% segment angle
dSeg = 2; %[degrees]
% Allowable difference between the experimental segment angle and fitted
% segment angle (maximum allowable value)
dSegMax = 10; %[degrees]
% Maximum number of calibration curve data points that are allowed to
% deviate outside the User specified differnce between fitted segment angle
% and experimental segments. If the number of data points that violates
% this rule are greater than {Rule_1_Max} then the fit is thrown out as a
% possible candidate
Rule_1_Max = 1; %[1,2,3,...]

% Range bounds for advanced parameters
% Dwell time multiplication factor for all segments (see {f_tDe})
f_tDe_MinMax = [0; 2]; %[]
% Diverging segments proximity correction (see {PrxCi})
PrxCi_MinMax = [0; 10]; %[nm]
% Converging segments proximity correction (see {PrxCf})
PrxCf_MinMax = [0; 10]; %[nm]
% Sample exposure level segment exposure order every {sPerLevel} loops
% through the level
sPerLevel_MinMax = [1; 50]; %[1,2,3,...]
% Fitting parameter for calibration curve simulation.  Imparts observed
% delay in segment take-off for calibration curve (see {rN})
rN_MinMax = [0.1; 2]; %[nm]
% Primary electron beam size (see {FWHM})
FWHM_MinMax = [1; 50]; %[nm]
% NVPE dwell time (see {tdMax_NVPE})
tdMax_NVPE_MinMax = [0; 1]; %[ms]
% Fitting constraint relieved for {Rule_1_Max} data points
Rule_1_Max_MinMax = [0; 10]; %[1,2,3,...]
% ooooooooooooooooooooooooooooooooooooooooooooooo



% GUI element positions (absolute)
% ooooooooooooooooooooooooooooooooooooooooooooooo
% ooooooooooooooooooooooooooooooooooooooooooooooo

% GUI: User input level (reference position for UI controls)
zPivGUI = 150; %[]
% GUI: User input level (reference spacing for UI controls)
dzGUI = 35; %[]
% GUI: Visual output level (reference position for plot objects)
zPivPlot = 250; %[]

% GUI: Red arrow spacing with respect to the input box
dxLeft = 42; %[pix]
% GUI: Green arrow spacing with respect to the input box
dxRight = 56; %[pix]
% GUI: Centers edit box vertically with red and green selection arrows
dyUp = 5; %[pix]


% GUI Cluster #0
% Vertex, segment upload and export features
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_0 = 25;   y0_0 = 970; %[pix]
% Spacings between GUI elements
dy_0 = 25; %[pix]
% GUI element sizes
ddx_0 = 500;   ddx_0b = 600;%[pix]
ddy_0 =  25;   ddy_0b = 45; %[pix]

% GUI Cluster #1
% Vertex, segment upload and export features
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_1 = 1125;   y0_1 = zPivGUI + 2.*dzGUI; %[pix]
% Spacings between GUI elements
dx_1 = 165;   dy_1 = dzGUI; %[pix]
% GUI element sizes
ddx_1 = 100;   ddy_1 =  25; %[pix]

% GUI Cluster #2
% Vertex transformations
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_2 = 1600;   y0_2 = zPivGUI - 4.*dzGUI; %[pix]
% Spacings between GUI elements
dx_2 = 60;   dy_2 = dzGUI; %[pix]
% GUI element sizes
ddx_2 = 50;   ddy_2 =  25; %[pix]

% GUI Cluster #3
% Calibration curve fitting
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_3 = 900;   y0_3 = zPivGUI + 19.*dzGUI; %[pix]
% Spacings between GUI elements
dx_3a = 100;   dx_3b = 65; %[pix]
dy_3 = dzGUI; %[pix]
% GUI element sizes
ddx_3a = 100;   ddx_3b = 60; %[pix]
ddy_3 =  25; %[pix]

% GUI Cluster #4
% Calibration curve selection and curve limits
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_4 = 700;   y0_4 = zPivGUI + 19.*dzGUI; %[pix]
% Spacings between GUI elements
dx_4 = 100; dy_4 = dzGUI; %[pix]
% GUI element sizes
ddx_4a = 100;   ddx_4b = 60;   ddx_4c = 175; %[pix]
ddy_4 =  25; %[pix]

% GUI Cluster #5
% Vertex translations and duplications
% oooooooooooooooooooooooooooooooooooooooooooooo
% Center position of top GUI element for (x), left-edge (y)
x0_5 = 1300;   y0_5 = 765; %[pix]
% Spacings between GUI elements
dx_5 = 60;   dx_5b = 60; %[pix]
dy_5 = dzGUI; %[pix]
% GUI element sizes
ddx_5a = 150;   ddx_5b = 50;   ddx_5c = 100; %[pix]
ddy_5 =  25; %[pix]

% GUI Cluster #6
% Checkboxes for shots, arrays, -y and Nuclei
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_6 = 1125;   y0_6 = 765 - 11.75.*dzGUI; %[pix]
% Spacings between GUI elements
dy_6 = 0.75.*dzGUI; %[pix]
% GUI element sizes
ddx_6 = 75;   ddy_6 =  25; %[pix]

% GUI Cluster #7
% Vertex definition
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_7 = 25;   y0_7 = zPivGUI - dzGUI; %[pix]
% Spacings between GUI elements
dx_7 = 75;   dx_7b = 25; %[pix]
dy_7 = dzGUI; %[pix]
% GUI element sizes
ddx_7 = 75;   ddy_7 = 25; %[pix]

% GUI Cluster #8
% Exposure execution variables
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_8 = 25;   y0_8 = zPivGUI - 4.*dzGUI; %[pix]
% Spacings between GUI elements
dx_8 = 75;   dx_8b = 25;   dx_8c = 100; %[pix]
dy_8 = dzGUI; %[pix]
% GUI element sizes
ddx_8 = 75;  ddx_8b = 50; ddx_8c = 100; %[pix]
ddy_8 = 25; %[pix]

% GUI Cluster #9
% Segment definition
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of upper-left GUI element
x0_9 = 675;   y0_9 = zPivGUI; %[pix]
% Spacings between GUI elements
dx_9 = 25;   dx_9b = 75; %[pix]
dy_9 = dzGUI; %[pix]
% GUI element sizes
ddx_9 = 25;   ddx_9b = 50; %[pix]
ddy_9 = 25; %[pix]

% GUI Cluster #10
% Design folder reload
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of upper-left GUI element
x0_10 = 675;   y0_10 = zPivGUI - 3.*dzGUI; %[pix]
% Spacings between GUI elements
dy_10 = dzGUI; %[pix]
% GUI element sizes
ddx_10 = 275;   ddy_10 = 25; %[pix]

% GUI Cluster #11
% Segment reorganization and deletion
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of upper-left GUI element
x0_11 = 1435;   y0_11 = 765; %[pix]
% Spacings between GUI elements
dx_11 = 50;   dy_11 = 25; %[pix]
% GUI element sizes
ddx_11 = 50;   ddx_11b = 40; %[pix]
ddy_11 = 25; %[pix]

% GUI Cluster #12
% Axes limits
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of upper GUI element
x0_12 = 1125;   y0_12 = 765; %[pix]
% Spacings between GUI elements
dy_12 = dzGUI; %[pix]
% GUI element sizes
ddx_12 = 60;   ddy_12 = 25; %[pix]

% GUI Cluster #13
% Exposure execution variables
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of upper GUI element
x0_13 = 425;   y0_13 = 765 + 3.*dzGUI; %[pix]
% Spacings between GUI elements
dx_13 = 100;   dy_13 = dzGUI; %[pix]
% GUI element sizes
ddx_13 = 45;   ddx_13b = 100; %[pix]
ddy_13 = 25; %[pix]

% GUI Cluster #14
% Vertex selection histogram
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of upper-left GUI element
x0_14 = 1175;   y0_14 = zPivGUI; %[pix]
% Spacings between GUI elements
dx_14 = 100;   dy_14 = dzGUI; %[pix]
% GUI element sizes
ddx_14 = 100;   ddx_14b = 75; %[pix]
ddy_14 = 25; %[pix]

% GUI Cluster #15
% Past actions and history
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of upper-left GUI element
x0_15 = 1000;   y0_15 = zPivGUI - 3.*dzGUI; %[pix]
% Spacings between GUI elements
dx_15 = 100;   dx_15b = 50; %[pix]
dy_15 = dzGUI; %[pix]
% GUI element sizes
ddx_15 = 100;   ddx_15b = 50; %[pix]
ddy_15 = 25; %[pix]

% GUI Cluster #16
% z-accumulation variables
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of upper-left GUI element
x0_16 = -25; %[pix]
y0_16 = 0; %[pix]

% GUI Cluster #17
% Vertex, segment upload and export features
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_17 = 700;   y0_17 = 765; %[pix]
% Spacings between GUI elements
dx_17 = 100; %[pix]
% GUI element sizes
ddx_17 = 100;   ddx_17b = 50; %[pix]
ddy_17 =  25; %[pix]

% GUI Cluster #18
% Switch buttons for fit, 3D, 2^16 and Mag
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of upper-left GUI element
x0_18 = 25;   y0_18 = 800; %[pix]
% Spacings between GUI elements
dx_18 = 50; %[pix]
dy_18a = 65;   dy_18b = -20; %[pix]
% GUI element sizes
ddx_18 = 34;  ddy_18 =  15; %[pix]

% GUI Cluster #19
% Advanced setting options
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_19 = 325;   y0_19 = 950; %[pix]
% Spacings between GUI elements
dx_19 = 40;   dy_19 = 5; %[pix]
% GUI element sizes
ddx_19 = 50;  ddx_19b = 210; %[pix]
ddy_19 =  25; %[pix]

% GUI Cluster #20
% Microscope list box
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_20 = 25;   y0_20 = 765+dzGUI; %[pix]
% GUI element sizes
ddx_20 = 175;  ddy_20 = 65; %[pix]


% GUI Cluster #22
% New design pushbutton
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of lower-left GUI element
x0_22 = 1725;   y0_22 = 765; %[pix]
% GUI element sizes
ddx_22 = 100;  ddy_22 = 25; %[pix]

% GUI Cluster #23
% Screen capture functions
% oooooooooooooooooooooooooooooooooooooooooooooo
% Position of center GUI element
x0_23 = 1480;   y0_23 = zPivGUI-4.*dzGUI; %[pix]
% Spacings between GUI elements
dx_23a = -25;   dx_23b = 50; %[pix]
% GUI element sizes
ddx_23 = 25;     ddx_23b = 50; %[idx]
ddy_23 = 25; %[pix]


% Plot marker sizes
% oooooooooooooooooooooooooooooooooooooooooooooo
% Plot 2D {x,y} marker size
MS_Pxy = 6; %[]
% Plot 2D {x,y} artifact marker size
MS_Artifact = 10; %[]
% Plot 3D {x,y,z} marker size
MS_Pxyz = 6; %[]
% Plot 3D {x,y,z} marker size for 12bit exposure artifact
MS_Render = 9; %[]
% Segment calibration marker size
MS_Ptz = 6; %[]
% Segment interpolation value for 3D object exposure
MS_Interp = 9; %[]

% Font sizes with User defined scaling factor applied; see EBiD 3D
% (CAD)\FEBiD 3D CAD (Supporting Files)\GUI Size and
% Scale\FEBiD_CAD_GUI_Info.txt
MS_Pxy = fGUI.*MS_Pxy;   MS_Artifact = fGUI.*MS_Artifact;
MS_Pxyz = fGUI.*MS_Pxyz;   MS_Render = fGUI.*MS_Render;
MS_Ptz = fGUI.*MS_Ptz;   MS_Interp = fGUI.*MS_Interp;


% CAD related scalars, vectors, matrices and arrays
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% 3D object vertices
xCube = zeros(1,NumVertices_Limit); %[nm]
yCube = xCube;   zCube = xCube; %[nm]
% Substrate contact vertex?
sCube = xCube; %[0/1]
% Vertices used in segments
v_i = zeros(1,NumVertices_Limit,'logical'); %[idx]
% Selected vertex coordinates
xyzMouse = zeros(2,3); %[nm]

% Number of vertices
vt = zeros(1,1); %[idx]
% Next vertex (vt+1)
nv = ones(1,1); %[1,2,3,...]
% Vertex-of-interest
VOI = vt; %[idx]

% Number of segments in 3D object
nSeg = zeros(1,1); %[idx]

% Maximum # of levels
% (current maximum, not the maximum)
MaxExposureLevel = 0; %[1,2,3,...]
% Maximum number of segments per level
% (current maximum, not the maximum)
MaxSegsPerLevel = 0; %[1,2,3,...]

% Plot object (xy) (vertices)
Pxy = zeros(1,1); %[obj]
% Plot object (xyz) (vertices)
Pxyz = zeros(1,1); %[obj]
% Plot objects (vertices)
Pobj_xy_t = zeros(1,NumVertices_Limit); %[obj]
% Plot objects (vertices)
Pobj_xyz_t = zeros(1,NumVertices_Limit); %[obj]

% Plot objects (segments)
Pobj_Segments = zeros(1,NumVertices_Limit); %[obj]
% Indices that constitute the plot object segment
Pobj_Segments_idxs = zeros(2,NumVertices_Limit); %[idx]

% Initial position of segments
% Exposure level = row, Segment number = column)
s_i = zeros(NumExpLevels_Limit,NumSegsPerLevel_Limit); %[idx]
% Final position of segments
% Exposure level = row, Segment number = column)
s_f = zeros(NumExpLevels_Limit,NumSegsPerLevel_Limit); %[idx]
% Unique segment index
eIdx = zeros(NumExpLevels_Limit,NumSegsPerLevel_Limit); %[idx]
% Number of segmets per exposure level
n_e = zeros(1,NumExpLevels_Limit);
% Real exposure pixel point pitch
s_PoP = ds.*ones(NumExpLevels_Limit,NumSegsPerLevel_Limit); %[nm]
% Facilitates the process of exported in the current segment list to a text
% file
xPort = zeros(round(2.*NumExpLevels_Limit),NumSegsPerLevel_Limit); %[idx]

% Initial position of segments (temporary storage)
s_i_Tmp = zeros(1,NumSegsPerLevel_Limit); %[idx]
% Final position of segments (temporary storage)
s_f_Tmp = zeros(1,NumSegsPerLevel_Limit); %[idx]
% Unique segment number (temporary storage)
eIdx_Tmp = zeros(1,NumSegsPerLevel_Limit); %[idx]

% Number of 3D object CAD actions performed (current design is saved when
% {NewActions} is advanced
NewActions = 0; %[1,2,3,...]
% Index of CAD action (spans from {1:NewActions})
UndoRedo = 0; %[1,2,3,...]

% Rotation angle in {xy-plane} counter clockwise
theta = 0; %[deg]
% Tilt angle in {xz-plane} counter clockwise 
alpha = 0; %[deg] 
% Tilt angle in {yz-plane} counter clockwise
beta = 0; %[deg] 
% Default wrap in {x-coordinate}: radius
% All vertices are (1) converted from (x,y,z) to (x,0,z) and then (2) 
% wrapped onto the surface of a cylinder which points along the z-axis
% and is centered at (x=0,y=0).  The text input box is the radius (rCyl) 
% of the cylinder in nanometers.  
rWrap = 100; %[nm]

% Visualize shots distribution in 3D upon CAD submission?
ShowShots = false; %[0/1]

% Element "pillar/segment" length for automatic segment detection
Lxyz1D = zeros(1,MaxNumBins); %[nm]
% Default element spacing #1
Lxyz1D(1) = 50; %[nm]
% Element "pillar/segment" bin half-width for automatic segment detection
dLxyz1D = zeros(1,MaxNumBins); %[nm]
% Default element spacing deviation #1
dLxyz1D(1) = 5; %[nm]
% Number of elements specified for automatic segment detection
n_Lxyz1D = 0; %[idx]
% Current element spacing bin selected
c_Lxyz1D = n_Lxyz1D + 1; %[idx]

% Vertices that serve as the initial positions of segments during the auto
% segment detection routine
VperL = zeros(1,MaxNumSegsPerLevel); %[idx]
% Duplicate of {VperL} (temporary)
VperL_Next = VperL; %[idx]

% Segment bin position for segment spacing histogram
Seg1D = dLam:dLam:SegMax; %[nm]
% Number of segments per element spacing
Io1D = zeros(1,length(Seg1D)); %[1,2,3,...]

% Permutations of possible segments
MaxSegPerm = round( (NumVertices_Limit.^2 - NumVertices_Limit)./2 ); %[1,2,3...]
% Unique vertex spacings
Lxyz = zeros(MaxSegPerm,3); %[i,f,nm]

% Electron beam dwell time vector used during the calibration curve fitting
xFit = 0:dTau:TauMaxFit; %[ms]
dTau = dTau.*0.001; %[s]



% Set-up design folder
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Input/output figure window
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
InfoFig = figure('Name','i/o Window','NumberTitle','off','MenuBar','none');
set(InfoFig,'Color',FigHue,'Renderer','opengl',...
    'Position',fGUI.*[x0_FigInfo y0_FigInfo wFigInfo hFigInfo])
set(gca,'FontSize',FS,'units','pixels'); axis off
figure(InfoFig)

% [=1] name design folder, [=2] new recipe, [=3] new design confirmation
iSituation = 1; %[1,2,3]
% Requested information: text box
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
Request = 'The FEBiD CAD design folder name - would you like to name the folder or would you prefer to use the Default name?';
GUI_UserInput_Question = uicontrol('Style','text','String',Request...
    ,'Position',fGUI.*[Pad yReq (wFigInfo-2.*Pad) (hFigInfo-yReq-Pad)],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0 0],'FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','left');

% File/folder name: edit box
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Default design folder name
FileFolderName = 'FEBiD_3D_CAD...'; %[s]
GUI_UserInput_TypeName = uicontrol('Style','edit','String',FileFolderName,...
    'Position',fGUI.*[Pad yType (wFigInfo-2.*Pad) (yReq-yType-Pad)],...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 1],'FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center','Visible','On',...
    'Callback',@FileOrFolderName);

% Push button (left)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Push button text for custom design folder name
LeftButtonText = 'Custom'; %[s]
GUI_UserInput_LeftButton = uicontrol('Style','pushbutton','String',LeftButtonText,...
    'Position',fGUI.*[Pad Pad PressWidth (yType-2.*Pad)],...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 1],'FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center','Visible','On',...
    'Callback',{@PressLeftButton});

% Push button (right)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Push button text for default design folder name
RightButtonText = 'Default'; %[s]
GUI_UserInput_RightButton = uicontrol('Style','pushbutton','String',RightButtonText,...
    'Position',fGUI.*[Pad+PressWidth+Pad Pad PressWidth (yType-2.*Pad)],...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 1],'FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center','Visible','On',...
    'Callback',{@PressRightButton});

% User input required
uiwait



% Main figure window
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
MainFig = figure('Name','3D FEBiD Direct Write CAD','NumberTitle','off','MenuBar','none',...
    'InvertHardCopy','off','PaperPositionMode','auto');
set(MainFig,'Color',FigHue,'Position',fGUI.*[25 25 wFig hFig],'Renderer','painters')
set(gca,'FontSize',FS,'Box','on'); axis off


% Alternating colormap for exposure element visualization in 3D CAD
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Colormap for segment rendering 
ColorMapSamples = 4; %[1,2,3,...]
% Base colormap
iMap0 = colormap(jet(ColorMapSamples)); %[0-1]
% Colormap for 3D edge rendering
iMap = zeros(NumExpLevels_Limit,3);
% Colormap sampling variable
m0 = 0; %[1,2,3,...]
% ...number of possible levels
for n0=1:NumExpLevels_Limit
    % Advance base colormap sampling
    m0 = m0 + 1; %[1,2,3,...]
    % Fill the colormap
    iMap(n0,:) = iMap0(m0,:); %[0-1]
    % Reset base colormap sampling variable
    if m0 == ColorMapSamples
        m0 = 0; %[1,2,3,...]
    end
end


% Axes (for plotting) initialize
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% No vertices present in 2D CAD plot
NoPoint_xy = true; %[0/1]
% No vertices present in the 3D CAD plot
NoPoint_xyz = true; %[0/1]

% {x,y} graph axes definition for 2D in-plane vertex display
xyAxis = axes('Units','pixels','Position',fGUI.*[75 zPivPlot 500 500],'FontSize',FS,...
    'ButtonDownFcn',@NewVertex,'NextPlot','ReplaceChildren');
axis equal;   axis([xMin xMax yMin yMax]);
xlabel('x (nm)');   ylabel('y (nm)');   box on;
% Initial and final pixel dwell position to avoid artifact exposure on 3D
% objects for 12-bit FEI system
xyBadObj = plot(xyAxis,xArtifact,yArtifact,'^',...
    'MarkerSize',MS_Artifact,'MarkerEdgeColor','r','MarkerFaceColor','y',...
    'Visible','off');

% {x,y,z} graph axes definition for 3D vertex display
xyzAxis = axes('Units','pixels','Position',fGUI.*[625 zPivPlot 500 500],'FontSize',FS,...
    'NextPlot','ReplaceChildren','Projection','perspective'); 
axis equal;   axis([xMin xMax yMin yMax zMin zMax]);
xlabel('x (nm)');   ylabel('y (nm)');  zlabel('z (nm)');  box on;

% Object for 3D camera view rotation
InActObj = rotate3d;
% Current vertex text label x-displacement in 2D & 3D plot
ShiftText = dText.*(xMax - xMin); %[points]

% Vertex spacing histogram axes
izAxis = axes('Units','pixels','Position',fGUI.*[1675 zPivPlot-100 150 600],'FontSize',FS);
box on;
axis([0 xAxisMaxHistogram zMin zMax])
ylabel('vertex spacing (nm)','FontSize',(FS+3),'Color',VertexHue);

% Calibration curve {dwell time,segment angle} axes definition
tzAxis = axes('Units','pixels','Position',fGUI.*[1325 zPivPlot+625 500 100],'FontSize',FS,...
    'XColor',FitHue,'YColor',FitHue,'YTick',tzAxesYTick); box on;
axis(tzAxesLimits)
xlabel('\tau_d (ms)','FontSize',(FS+3),'FontWeight','bold','Color',FitHue);
ylabel('\zeta','FontSize',(FS+7),'FontWeight','bold','Color',FitHue);

% A switch used to indicate whether changes need to made to the
% experimentally defined calibration curve plot {ExpPlot=1} or to the
% fitted curve {ExpPlot=0}
ExpPlot = true; %[0/1]
% Check for the existance of fitted calibration curve
FitPlotData = false; %[0/1]

% Fitted calibration curve data exists?
FittedCalibData = false; %[0/1]


% Main GUI Title and Description
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String',Intro,'Position',fGUI.*[x0_0 y0_0 ddx_0 ddy_0],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0 1],'FontSize',(FS+3),...
    'FontWeight','normal','HorizontalAlignment','left');
uicontrol('Style','text','String',SubIntro,'Position',fGUI.*[x0_0 y0_0-dy_0 ddx_0 ddy_0],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0 1],'FontSize',(FS-3),...
    'FontWeight','normal','HorizontalAlignment','left');



% GUI_VertexDefine_...{User Interface}
% User definition of (x,y) coordiates and display of vertices
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Type {x} coordinate of vertex
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
x_t = 0; %[nm]
str_x_t = num2str(x_t); %[s]
% {x} value selected (title)
uicontrol('Style','text','String','x (nm)','Position',fGUI.*[x0_7 y0_7+dy_7 ddx_7 ddy_7],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Edit {x} position of vertex {VOI}');
% {x} value selected (value)
GUI_VertexDefine_TypeX = uicontrol('Style','edit','String',str_x_t,...
    'Position',fGUI.*[x0_7+1.*dx_7 y0_7+dy_7 ddx_7 ddy_7],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_TypeX,'callback',{@TypeX});

% Type {y} coordinate of vertex
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
y_t = 0; %[nm]
str_y_t = num2str(y_t); %[s]
% {x} value selected (title)
uicontrol('Style','text','String','y (nm)',...
    'Position',fGUI.*[x0_7+2.*dx_7+1.*dx_7b y0_7+dy_7 ddx_7 ddy_7],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Edit {y} position of vertex {VOI}');
% {x} value selected (value)
GUI_VertexDefine_TypeY = uicontrol('Style','edit','String',str_y_t,...
    'Position',fGUI.*[x0_7+3.*dx_7+1.*dx_7b y0_7+dy_7 ddx_7 ddy_7],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_TypeY,'callback',{@TypeY});

% Type {z} coordinate of vertex/{zeta} angle of segment
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
z_t = 0; %[nm]
str_z_t = num2str(z_t); %[nm]
% {z} value selected (title)
GUI_VertexDefine_TypeZLabel = uicontrol('Style','text','String','z (nm)',...
    'Position',fGUI.*[x0_7+4.*dx_7+2.*dx_7b y0_7+dy_7 ddx_7 ddy_7],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Edit {z} position of vertex {VOI}');
% {z} value selected (value)
GUI_VertexDefine_TypeZ = uicontrol('Style','edit','String',str_z_t,...
    'Position',fGUI.*[x0_7+5.*dx_7+2.*dx_7b y0_7+dy_7 ddx_7 ddy_7],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_TypeZ,'callback',{@TypeZ});

% Toggle {z/zeta} for input
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Define either absolute {z} coordinate [=0] or define segment angle [=1]
SwitchState = false; %[0/1]
GUI_VertexDefine_ZorZeta = uicontrol('style', 'togglebutton','string','+',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_7+6.*dx_7+3.*dx_7b y0_7+dy_7 ddy_7 ddy_7],'FontSize',(FS+2),...
    'ForeGroundColor',[1 1 0],'BackgroundColor',VertexHue,'TooltipString',...
    '{+}: enter {z} value [nm] or, {/}: enter segment angle [degrees]');
set(GUI_VertexDefine_ZorZeta,'callback',{@ZorZeta});

% Toggle for visible vertex
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% All vertices are visible [=0] or only those that define a segment are
% shown [=1]
HideVerts = false; %[0/1]
GUI_VertexDefine_VisVerts = uicontrol('style', 'togglebutton','string','o',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_7+6.*dx_7+3.*dx_7b y0_7 ddy_7 ddy_7],'FontSize',(FS+2),...
    'ForeGroundColor','w','BackgroundColor',VertexHue,'TooltipString',...
    'Reveal/hide vertices not currently used in segments');
set(GUI_VertexDefine_VisVerts,'callback',{@VisVerts});

% Initial vertex used to compute the angle
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% If {z} coordinate defined by a segment angle, e.g., {SwitchState = 1}
% then the angle specifed is with respect a vector with initial position
% {iVOIAng} that lies in the substrate plane in the direction spanning
% {iVOIAng} to {VOI}
iVOIAng = 1; %[idx]
GUI_VertexDefine_iVOI = uicontrol('Style','edit','String',num2str(iVOIAng),...
    'Position',fGUI.*[x0_7+6.*dx_7+3.*dx_7b y0_7+2.*dy_7 ddy_7 ddy_7],...
    'BackgroundColor',UIHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','Visible','Off',...
    'TooltipString',...
    'Enter initial vertex index {i} as reference point for segment angle');
set(GUI_VertexDefine_iVOI,'callback',{@iVOI});

% Change active vertex-of-interest
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','VOI','Position',fGUI.*[x0_7 y0_7 ddx_7 ddy_7],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Active vertex for editing');
% Active {VOI} can be changed
GUI_VertexDefine_TypeVOI = uicontrol('Style','edit','String',num2str(0),...
    'Position',fGUI.*[x0_7+dx_7 y0_7 ddx_7 ddy_7],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_TypeVOI,'callback',{@TypeVOI});

% Total number of vertices in the design
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','vertices',...
    'Position',fGUI.*[x0_7+2.*dx_7+1.*dx_7b y0_7 ddx_7 ddy_7],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Total number of defined vertices');
GUI_VertexDefine_VertexNumber = uicontrol('Style','text','String',num2str(0),...
    'Position',fGUI.*[x0_7+3.*dx_7+1.*dx_7b y0_7 ddx_7 ddy_7],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');

% Vertex with substrate contact
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','s [0/1]',...
    'Position',fGUI.*[x0_7+4.*dx_7+2.*dx_7b y0_7 ddx_7 ddy_7],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Vertex in contact with substrate?  Used only in automatic segment search.');
% Substrate contact [=1], no substrate contact [=0].  This feature is used
% during auto segment detection
GUI_VertexDefine_SubstrateContact = uicontrol('Style','edit','String',num2str(0),...
    'Position',fGUI.*[x0_7+5.*dx_7+2.*dx_7b y0_7 ddx_7 ddy_7],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_SubstrateContact,'callback',{@SubstrateContact});


% Automatic {z} displacement
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Automatic {z} displacement increment applied each time that a new vertex
% is defined
AutoDz = 50; %[nm]
% Activated automatic {z} coordinate creation when a vertex is defined
AutoCalculateZ = false; %[0/1]
% {Dz} value selected (title)
uicontrol('Style','text','String','+dz',...
    'Position',fGUI.*[537+x0_16 zPivGUI-2.3.*dzGUI+y0_16 75 25],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'ToolTipString',...
    'Add {+dz} to {z} integrator for next new vertex');
% {Dz} value selected (value)
GUI_VertexDefine_AutomaticDz = uicontrol('Style','pushbutton','String',num2str(AutoDz),...
    'Position',fGUI.*[525+x0_16 zPivGUI-3.*dzGUI+y0_16 50 25],...
    'BackgroundColor',[1 0 0],'ForegroundColor',UIHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString',...
    'Activate/deactivate {z} integrator');
set(GUI_VertexDefine_AutomaticDz,'callback',{@AutomaticDz});
% {Dz} value selected (units)
uicontrol('Style','text','String','nm',...
    'Position',fGUI.*[537+x0_16 zPivGUI-3.8.*dzGUI+y0_16 75 25],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left');

% "Actions" Forward by the Fine increment
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Increase the {z} increment by the fine amount
GUI_VertexDefine_UpDzFine = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[582+x0_16 zPivGUI-3.1.*dzGUI+y0_16 size(fMap,2) size(fMap,1)],...
    'FontSize',FS,...
    'CData',fMap,...
    'ToolTipString',...
    'Increase {+dz} by fine value');
set(GUI_VertexDefine_UpDzFine,'callback',{@UpDzFine});

% "Actions" Forward by the Course increment
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Increase the {z} increment by the course amount
GUI_VertexDefine_UpDzCourse = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[622+x0_16 zPivGUI-3.1.*dzGUI+y0_16 size(fMap,2) size(fMap,1)],...
    'FontSize',FS,...
    'CData',fMap,...
    'ToolTipString',...
    'Increase {+dz} by course value');
set(GUI_VertexDefine_UpDzCourse,'callback',{@UpDzCourse});

% "Actions" Backward by the Fine increment
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Decrease the {z} increment by the fine amount
GUI_VertexDefine_DownDzFine = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[482+x0_16 zPivGUI-3.1.*dzGUI+y0_16 size(bMap,2) size(bMap,1)],...
    'FontSize',FS,...
    'CData',bMap,...
    'ToolTipString',...
    'Decrease {+dz} by fine value');
set(GUI_VertexDefine_DownDzFine,'callback',{@DownDzFine});

% "Actions" Forward by the Course increment
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Decrease the {z} increment by the course amount
GUI_VertexDefine_DownDzCourse = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[442+x0_16 zPivGUI-3.1.*dzGUI+y0_16 size(bMap,2) size(bMap,1)],...
    'FontSize',FS,...
    'CData',bMap,...
    'ToolTipString',...
    'Decrease {+dz} by course value');
set(GUI_VertexDefine_DownDzCourse,'callback',{@DownDzCourse});

% Fine displacement increment value
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Add/subtract the fine displacement from the {z} increment
PlusDz = 1; %[nm]
GUI_VertexDefine_DzChangeFine = uicontrol('Style','edit','String',num2str(PlusDz),...
    'Position',fGUI.*[587+x0_16 zPivGUI-4.*dzGUI+y0_16 25 25],...
    'BackgroundColor',VertexHue,'ForegroundColor',UIHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString',...
    'Fine {+dz} increment',...
    'Callback',{@DzFineChange}); %#ok<*NASGU>

% Course displacment increment value
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Add/subtract the course displacement from the {z} increment
PlusPlusDz = 10; %[nm]
GUI_VertexDefine_DzChangeCourse = uicontrol('Style','edit','String',num2str(PlusPlusDz),...
    'Position',fGUI.*[627+x0_16 zPivGUI-4.*dzGUI+y0_16 25 25],...
    'BackgroundColor',VertexHue,'ForegroundColor',UIHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString',...
    'Course {+dz} increment',...
    'callback',{@DzCourseChange});

% Accumulated increment value
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Integrated value of {z} that will be applied to the next added vertex
zAccu = 0; %[nm]
GUI_VertexDefine_zAccumulator = uicontrol('Style','edit','String',num2str(zAccu),...
    'Position',fGUI.*[450+x0_16 zPivGUI-4.*dzGUI+y0_16 50 25],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString',...
    'Current integrated {z} value',...
    'Callback',{@zAccumulator});

% 3D plot view (azimuthal)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','azimuthal','Position',fGUI.*[x0_17 y0_17 ddx_17 ddy_17],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left');
GUI_VertexDefine_Azimuthal = uicontrol('Style','edit','String',num2str(aza),...
    'Position',fGUI.*[x0_17+dx_17 y0_17 ddx_17b ddy_17],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_Azimuthal,'callback',{@View3D});

% 3D view (elevation)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','elevation','Position',fGUI.*[x0_17+2.*dx_17 y0_17 ddx_17 ddy_17],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left');
GUI_VertexDefine_Elevation = uicontrol('Style','edit','String',num2str(ele),...
    'Position',fGUI.*[x0_17+3.*dx_17 y0_17 ddx_17b ddy_17],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_Elevation,'callback',{@View3D});

% Execute 3D mouse rotation for changing the camera view
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Toggle switch for 3D rotation activation
GUI_VertexDefine_Go3D = uicontrol('style','toggle',...
    'HorizontalAlignment','center','Position',fGUI.*[x0_18+dx_18 y0_18 size(sOff,2) size(sOff,1)],'FontSize',FS,...
    'CData',sOff,...
    'ToolTipString',...
    'Activate/deactivate mouse based 3D rotation in {x,y,z} plot?');
set(GUI_VertexDefine_Go3D,'callback',{@Go3D});

% 3D mouse rotation (activated, User can change view)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_VertexDefine_Go3D_TextWhenOn = uicontrol('style','text','String','3D',...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0.5 0],...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18+dx_18 y0_18+dy_18a ddx_18 ddy_18],'FontSize',(FS-2),...
    'FontAngle','italic');

% 3D mouse rotation (deactivated, User cannot change view)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_VertexDefine_Go3D_TextWhenOff = uicontrol('style','text','String','2D',...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0 0],...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18+dx_18 y0_18+dy_18b ddx_18 ddy_18],'FontSize',(FS-2),...
    'FontAngle','italic');

% 3D plot zoom (button on = Mag)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_VertexDefine_Plot3D_TextWhenOn = uicontrol('style','text','String','Mag',...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0.5 0],...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18+3.*dx_18 y0_18+dy_18a ddx_18 ddy_18],'FontSize',(FS-2),...
    'FontAngle','italic');

% 3D plot zoom (button off = DeMag)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_VertexDefine_Plot3D_TextWhenOff = uicontrol('style','text','String','[ ]',...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0 0],...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18+3.*dx_18 y0_18+dy_18b ddx_18 ddy_18],'FontSize',(FS-2),...
    'FontAngle','italic');

% Magnify plot (toggle button)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% No zoom by (=0) or (=1) for 3D plot zoom
GUI_VertexDefine_Plot3D = uicontrol('style','toggle',...
    'HorizontalAlignment','center','Position',fGUI.*[x0_18+3.*dx_18 y0_18 size(sOff,2) size(sOff,1)],'FontSize',FS,...
    'CData',sOff,...
    'ToolTipString',...
    'Magnify/demagnify the {x,y,z} plot?');
set(GUI_VertexDefine_Plot3D,'callback',{@Zoom3Dplot});

% {x} axes minimum display limit
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% {x} value selected (title)
uicontrol('Style','text','String','x (nm)','Position',fGUI.*[x0_12 y0_12 ddx_12 ddy_12],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
% {x} minimum (value)
GUI_VertexDefine_xMin= uicontrol('Style','edit','String',num2str(xMin),...
    'Position',fGUI.*[x0_12 y0_12-dy_12 ddx_12 ddy_12],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_xMin,'callback',{@AxesLimits});
% {x} maximum (value)
GUI_VertexDefine_xMax= uicontrol('Style','edit','String',num2str(xMax),...
    'Position',fGUI.*[x0_12 y0_12-2.*dy_12 ddx_12 ddy_12],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_xMax,'callback',{@AxesLimits});

% {y} axes minimum display limit
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% {y} value selected (title)
uicontrol('Style','text','String','y (nm)','Position',fGUI.*[x0_12 y0_12-3.*dy_12 ddx_12 ddy_12],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
% {y} minimum (value)
GUI_VertexDefine_yMin= uicontrol('Style','edit','String',num2str(yMin),...
    'Position',fGUI.*[x0_12 y0_12-4.*dy_12 ddx_12 ddy_12],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_yMin,'callback',{@AxesLimits});
% {y} maximum (value)
GUI_VertexDefine_yMax= uicontrol('Style','edit','String',num2str(yMax),...
    'Position',fGUI.*[x0_12 y0_12-5.*dy_12 ddx_12 ddy_12],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_yMax,'callback',{@AxesLimits});

% {z} axes minimum display limit
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% {z} value selected (title)
uicontrol('Style','text','String','z (nm)','Position',fGUI.*[x0_12 y0_12-6.*dy_12 ddx_12 ddy_12],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
% {z} minimum (value)
GUI_VertexDefine_zMin= uicontrol('Style','edit','String',num2str(zMin),...
    'Position',fGUI.*[x0_12 y0_12-7.*dy_12 ddx_12 ddy_12],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_zMin,'callback',{@AxesLimits});
% {z} maximum (value)
GUI_VertexDefine_zMax= uicontrol('Style','edit','String',num2str(zMax),...
    'Position',fGUI.*[x0_12 y0_12-8.*dy_12 ddx_12 ddy_12],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0.4 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexDefine_zMax,'callback',{@AxesLimits});

% Import vertex data (file name)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
ImportFileName = 'Upload'; %[s]
% File name identifier
uicontrol('Style','text','String','file name for import {x,y,z} or {i,f}',...
    'Position',fGUI.*[x0_1 y0_1+3.*dy_1 dx_1+ddx_1 ddy_1],...
    'BackgroundColor',FigHue,'ForegroundColor',[0.4 0.4 0.4],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','Used for vertex, segment, and \n beam sweeping text file upload');
% Change file name
GUI_VertexDefine_VertexDataFileName = uicontrol('Style','edit',...
    'String',ImportFileName,'Position',fGUI.*[x0_1 y0_1+2.*dy_1 dx_1+ddx_1 ddy_1],...
    'BackgroundColor',UIHue,'ForegroundColor',[0.4 0.4 0.4],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
set(GUI_VertexDefine_VertexDataFileName,'callback',{@VertexDataFileName});

% Execute vertex data list upload
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_VertexDefine_LoadVertexCoordinates = uicontrol('style', 'pushbutton','string','Load {x,y,z}',...
    'HorizontalAlignment','center','Position',fGUI.*[x0_1 y0_1+1.*dy_1 ddx_1 ddy_1],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',VertexHue,...
    'TooltipString','Load vertices from text file');
set(GUI_VertexDefine_LoadVertexCoordinates,'callback',{@LoadVertexCoordinates});


% Execute vertex and segment save data list
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_VertexDefine_SaveCAD = uicontrol('style', 'pushbutton','string','Save',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[(x0_1+ddx_1+round( ((dx_1-ddx_1)-(ddx_1./2))./2 )) y0_1+1.*dzGUI ddx_1./2 ddy_1],...
    'FontSize',(FS-1),'ForeGroundColor','white','BackgroundColor',[0 0 0],...
    'TooltipString',...
    sprintf('Export current 3D Obj vertices and segments \nin a format compatible with \n"Load {x,y,z}" and "Load {i,f}".'));
set(GUI_VertexDefine_SaveCAD,'callback',{@ExportVertsExportSegs});


% Vertex spacing histogram patch objects
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Histogram bars for vertex spacing plot
axes(izAxis)
% Histogram bar individual patches
Obj_Hist = zeros(1,length(Seg1D)); %[obj]
% ...per histogram patch
for m0=1:length(Seg1D)
    % Vertex spacing intensity
    Obj_Hist(m0) = patch([0 Io1D(m0) Io1D(m0) 0],...
        [0 0 dLam dLam]+(dLam./2) + (m0-1).*dLam,[0 0.5 0],'EdgeColor',[0 0.3 0]);
end
set(izAxis,'XTick',[],'YColor',VertexHue)
axes(xyAxis)



% GUI_VertexCopy_...{User Interface}
% Duplicate,shift and mirror selected vertice ranges
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Vertex indices used for vertex translations, transformations and
% duplications
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% User specified vertex list (default)
vRange = '1, 3-4'; %[s]
% initial vertex for duplication (title)
uicontrol('Style','text','String','vertex list',...
    'Position',fGUI.*[x0_5-round(ddx_5a./2) y0_5 ddx_5a ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'ToolTipString','{-}, {,} and { } are all acceptable input');
% initial vertex for duplication (value)
GUI_VertexCopy_VertexRange = uicontrol('Style','edit','String',vRange,...
    'Position',fGUI.*[x0_5-round(ddx_5a./2) y0_5-1.*dy_5 ddx_5a ddy_5],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexCopy_VertexRange,'callback',{@VertexRange});
% User specified vertex list (default) in number form
vRange = [1 3 4]; %[idx]

% Label & execute segment bending compensation
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% initial vertex for segment compensation (title)
GUI_SegmentCompensation_GoSegComp = uicontrol('Style','pushbutton',...
    'String','Segment compensation',...
    'Position',fGUI.*[x0_5-round(ddx_5a./2) y0_5-2.*dy_5 ddx_5a ddy_5],...
    'FontSize',(FS-1),'ForeGroundColor','white','BackgroundColor',SegmentHue,...
    'TooltipString','Execute segment compensation');
set(GUI_SegmentCompensation_GoSegComp,'callback',{@GoSegComp});

% Segment compensation (reference vertex)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Vertex index defining the initial position of the linear span over which
% segment bending compensation should be applied
vComp = 1; %[idx]
% initial vertex for duplication (value)
GUI_SegmentCompensation_VertexRefForComp = uicontrol('Style','edit','String',num2str(vComp),...
    'Position',fGUI.*[x0_5-round(ddx_5b./2)-dx_5 y0_5-3.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',UIHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString','Initial vertex of linear portion to apply compensation');
set(GUI_SegmentCompensation_VertexRefForComp,'callback',{@VertexRefForComp});

% Segment compensation (dZeta/ds)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Change in segment angle as a function of displacment along the segment
% projection, in the substrate plane
dZeta_ds = 2./200; %[deg/nm]
% initial vertex for duplication (value)
GUI_SegmentCompensation_SegComp = uicontrol('Style','edit','String',num2str(dZeta_ds),...
    'Position',fGUI.*[x0_5-round(ddx_5b./2) y0_5-3.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',UIHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString','d(Zeta)/d(L)');
set(GUI_SegmentCompensation_SegComp,'callback',{@SegComp});

% Segment compensation (reference vertex)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Vertex index defining the final position of the linear span over which
% segment bending compensation should be applied
vComp_f = 2; %[idx]
% initial vertex for duplication (value)
GUI_SegmentCompensation_VertexRefForComp_f = uicontrol('Style','edit','String',num2str(vComp_f),...
    'Position',fGUI.*[x0_5-round(ddx_5b./2)+dx_5 y0_5-3.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',UIHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString','Final vertex of linear portion to apply compensation');
set(GUI_SegmentCompensation_VertexRefForComp_f,'callback',{@VertexRefForComp_f});

% Automatic vertex list generation for the segment compensation
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Automatic detection of verties lying along a segment spanning {vComp} to
% {vComp_f}
GUI_SegmentCompensation_TransferVertices = uicontrol('Style','pushbutton',...
    'Position',fGUI.*[x0_5+dx_5+30 y0_5-3.*dy_5 25 3.8.*ddy_5],...
    'FontSize',(FS-1),'ForeGroundColor','white','BackgroundColor',SegmentHue,...
    'TooltipString','Execute segment compensation','CData',Press);
set(GUI_SegmentCompensation_TransferVertices,'callback',{@TransferVertices});


% {x}-shift magnitude during vertex duplication
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
sdx = 0; %[nm]
% {x}-shift (title)
uicontrol('Style','text','String','dx(nm)',...
    'Position',fGUI.*[x0_5-round(ddx_5b./2) y0_5-4.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','Select then use with "Shift" and/or "Duplicate".');
% d{x}-shift (value)
GUI_VertexCopy_DxShift = uicontrol('Style','text','String',num2str(sdx),...
    'Position',fGUI.*[x0_5-round(ddx_5b./2) y0_5-5.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexCopy_DxShift,'callback',{@DxShift});

% Checkbox indicating {x}-shift
DxShift_Trig = 0; %[0/1]
uicontrol('Style','text','String','select',...
    'Position',fGUI.*[x0_5-round(ddx_5b./2)-dx_5 y0_5-4.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',(FS-2),...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','Activate for use with "Shift" and/or "Duplicate".')
GUI_VertexCopy_SwitchForDxShift = uicontrol('Style','checkbox',...
    'Position',fGUI.*[x0_5-round(ddx_5b./6)-dx_5 y0_5-5.*dy_5 ddy_5 ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0.5 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
set(GUI_VertexCopy_SwitchForDxShift,'callback',{@SwitchForDxShift});

% Mirror duplication of point for {x,y and z}-axes
uicontrol('Style','text','String','mirror',...
    'Position',fGUI.*[x0_5-round(ddx_5b./2)+dx_5 y0_5-4.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',(FS-2),...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','Activate for use with "Duplicate".')
% Duplicate specified vertices and change {x} sign
DxShift_Sign = 0; %[0/1]
GUI_VertexCopy_SignForDxShift = uicontrol('Style','checkbox',...
    'Position',fGUI.*[x0_5-round(ddx_5b./6)+dx_5 y0_5-5.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0.5 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
set(GUI_VertexCopy_SignForDxShift,'callback',{@SignForDxShift});


% {y}-shift during duplication
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
sdy = 0; %[nm]
% {y}-shift (title)
uicontrol('Style','text','String','dy(nm)',...
    'Position',fGUI.*[x0_5-round(ddx_5b./2) y0_5-6.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','Select then use with "Shift" and/or "Duplicate".');
% d{y}-shift (value)
GUI_VertexCopy_DyShift = uicontrol('Style','text','String',num2str(sdy),...
    'Position',fGUI.*[x0_5-round(ddx_5b./2) y0_5-7.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexCopy_DyShift,'callback',{@DyShift});

% Checkbox indicating {y}-shift
DyShift_Trig = 0; %[0/1]
GUI_VertexCopy_SwitchForDyShift = uicontrol('Style','checkbox',...
    'Position',fGUI.*[x0_5-round(ddx_5b./6)-dx_5 y0_5-7.*dy_5 ddy_5 ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0.5 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
set(GUI_VertexCopy_SwitchForDyShift,'callback',{@SwitchForDyShift});
% Duplicate specified vertices and change {y} sign
DyShift_Sign = 0; %[0/1]
GUI_VertexCopy_SignForDyShift = uicontrol('Style','checkbox',...
    'Position',fGUI.*[x0_5-round(ddx_5b./6)+dx_5 y0_5-7.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0.5 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
set(GUI_VertexCopy_SignForDyShift,'callback',{@SignForDyShift});


% {z}-shift during duplication
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
sdz = 0; %[nm]
% {z}-shift (title)
uicontrol('Style','text','String','dz(nm)',...
    'Position',fGUI.*[x0_5-round(ddx_5b./2) y0_5-8.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','Select then use with "Shift" and/or "Duplicate".');
% d{z}-shift (value)
GUI_VertexCopy_DzShift = uicontrol('Style','text','String',num2str(sdz),...
    'Position',fGUI.*[x0_5-round(ddx_5b./2) y0_5-9.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_VertexCopy_DzShift,'callback',{@DzShift});
% Checkbox indicating {z}-shift
DzShift_Trig = 0; %[0/1]
GUI_VertexCopy_SwitchForDzShift = uicontrol('Style','checkbox',...
    'Position',fGUI.*[x0_5-round(ddx_5b./6)-dx_5 y0_5-9.*dy_5 ddy_5 ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0.5 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
set(GUI_VertexCopy_SwitchForDzShift,'callback',{@SwitchForDzShift});
% Duplicate specified vertices and change {z} sign
DzShift_Sign = 0; %[0/1]
GUI_VertexCopy_SignForDzShift = uicontrol('Style','checkbox',...
    'Position',fGUI.*[x0_5-round(ddx_5b./6)+dx_5 y0_5-9.*dy_5 ddx_5b ddy_5],...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0.5 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
set(GUI_VertexCopy_SignForDzShift,'callback',{@SignForDzShift});

% Execute vertex shift
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Shift = uicontrol('style', 'pushbutton','string','Shift',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_5-round(ddx_5c./2) y0_5-10.*dy_5 ddx_5c ddy_5],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',VertexHue,...
     'ToolTipString',sprintf('Executes "dx", "dy" and "dz" shifts. \nUse "vertex list" above'));
set(GUI_Shift,'callback',{@Shift});

% Execute vertex duplication
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Duplicate = uicontrol('style', 'pushbutton','string','Duplicate',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_5-round(ddx_5c./2) y0_5-11.*dy_5 ddx_5c ddy_5],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',VertexHue,...
     'ToolTipString',sprintf('Executes "dx", "dy" and "dz" shifts and duplication. \nUse "vertex list" above'));
set(GUI_Duplicate,'callback',{@Duplicate});

% Sub-divide all segments into equal halves
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Remesh operation for all defined segments -> new vertex introduced at the
% midpoint
GUI_ReMesh = uicontrol('Style','pushbutton','String','Remesh',...
    'Position',fGUI.*[x0_9+5.*dx_9+3.*dx_9b y0_9-1.*dy_9 round(2.*ddx_9b) ddy_9],...
    'BackgroundColor','blue','ForegroundColor',[1 1 1],'FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'TooltipString',...
    'Replace all segments with two new segments of equal length. Requires "vertex list" input!');
set(GUI_ReMesh,'callback',{@ReMesh});

% UndoRedo to a previous, less refined remesh state (in terms of text
% labelling of vertices in the 3D plot only)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_ReMesh_Older = uicontrol('Style','pushbutton',...
    'Position',fGUI.*[x0_9+5.*dx_9+3.*dx_9b y0_9-2.*dy_9 round(ddx_9b./2) ddy_9],...
    'CData',lMap_Small,...
    'TooltipString','Older Remesh node(s)',...
    'Callback',{@ReMesh_Older});


% Current selected remesh state (in terms of text labelling of vertices in
% the 3D plot only)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Remesh index (idx_Re = 0; all vertices labelled, idx_Re = 1; vertices
% labelled prior first remesh, idx_Re = 2; vertices labelled prior to
% second remesh, etc.)
idx_Re = 0; %[idx]
idx_ReMax = idx_Re; %[idx]
% Largest vertex index prior to the ReMesh operation
v_i_2D = zeros(1,NumReMeshOps,'logical'); %[idx]
GUI_ReMesh_Current = uicontrol('Style','text','String',num2str(idx_Re),...
    'Position',fGUI.*[x0_9+5.*dx_9+3.5.*dx_9b y0_9-2.*dy_9 round(ddx_9b./2) ddy_9],...
    'BackgroundColor',FigHue,'FontSize',FS,...
    'TooltipString','Current ReMesh node');

% Advance one step toward a more refined remesh state (in terms of text
% labelling of vertices in the 3D plot only)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_ReMesh_Newer = uicontrol('Style','pushbutton',...
    'Position',fGUI.*[x0_9+5.*dx_9+4.*dx_9b y0_9-2.*dy_9 round(ddx_9b./2) ddy_9],...
    'CData',rMap_Small,...
    'TooltipString','Newer ReMesh node(s)',...
    'Callback',{@ReMesh_Newer});


% GUI_SegmentManual_...{User Interface}
% User definition of segment connection based on vertex indices
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Segment initial position
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Vertex index for initial position of eleement "pillar/segment".  User to
% submit new elements.
ei = 1; %[idx]
uicontrol('Style','text','String','i','Position',fGUI.*[x0_9 y0_9 ddx_9 ddy_9],...
    'BackgroundColor',FigHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Initial vertex index for new segment (lower relative {z} value)');
GUI_SegmentManual_i = uicontrol('Style','edit','String',num2str(ei),...
    'Position',fGUI.*[x0_9+dx_9 y0_9 ddx_9b ddy_9],...
    'BackgroundColor',UIHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_SegmentManual_i,'callback',{@InitialVertexForSegment});
% Increment {ei} by +1
GUI_SegmentManual_iUp = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_9+dx_9 y0_9-dy_9 size(uMap,2) size(uMap,1)],'FontSize',FS,...
    'CData',uMap);
set(GUI_SegmentManual_iUp,'callback',{@iUp});
% Increment {ei} by -1
GUI_SegmentManual_iDown = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_9+dx_9 y0_9-2.*dy_9 size(dMap,2) size(dMap,1)],'FontSize',FS,...
    'CData',dMap);
set(GUI_SegmentManual_iDown,'callback',{@iDown});

% Segment final position
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Vertex index for final position of eleement "pillar/segment".  User to
% submit new elements.
ef = 2; %[idx]
uicontrol('Style','text','String','f','Position',fGUI.*[x0_9+dx_9+dx_9b y0_9 ddx_9 ddy_9],...
    'BackgroundColor',FigHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Final vertex index for new segment (higher relative {z} value)');
GUI_SegmentManual_f = uicontrol('Style','edit','String',num2str(ef),...
    'Position',fGUI.*[x0_9+2.*dx_9+dx_9b y0_9 ddx_9b ddy_9],...
    'BackgroundColor',UIHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_SegmentManual_f,'callback',{@FinalVertexForSegment});
% Increment {ei} by +1
GUI_SegmentManual_fUp = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_9+2.*dx_9+dx_9b y0_9-1.*dy_9 size(uMap,2) size(uMap,1)],...
    'FontSize',FS,...
    'CData',uMap);
set(GUI_SegmentManual_fUp,'callback',{@fUp});
% Increment {ef} by -1
GUI_SegmentManual_fDown= uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_9+2.*dx_9+dx_9b y0_9-2.*dy_9 size(dMap,2) size(dMap,1)],...
    'FontSize',FS,...
    'CData',dMap);
set(GUI_SegmentManual_fDown,'callback',{@fDown});

% Level of exposure for submitted edge
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Total number of exposure levels
MaxExposureLevel = 0; %[1,2,3,...]
% Current exposure level number 
lvl = 1; %[1,2,3,...]
uicontrol('Style','text','String','level',...
    'Position',fGUI.*[x0_9+3.*dx_9+2.*dx_9b y0_9 ddx_9b ddy_9],...
    'BackgroundColor',FigHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Exposure level for segment')
% {z} value selected (value)
GUI_SegmentManual_lvl = uicontrol('Style','edit','String',num2str(lvl),...
    'Position',fGUI.*[x0_9+5.*dx_9+2.*dx_9b y0_9 ddx_9b ddy_9],...
    'BackgroundColor',UIHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_SegmentManual_lvl,'callback',{@LevelForSegment});
% Increment {lvl} by +1
GUI_SegmentManual_lvlUp = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_9+5.*dx_9+2.*dx_9b y0_9-1.*dy_9 size(uMap,2) size(uMap,1)],...
    'FontSize',FS,...
    'CData',uMap);
set(GUI_SegmentManual_lvlUp,'callback',{@lvlUp});
% Increment {lvl} by -1
GUI_SegmentManual_lvlDown = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_9+5.*dx_9+2.*dx_9b y0_9-2.*dy_9 size(dMap,2) size(dMap,1)],...
    'FontSize',FS,...
    'CData',dMap);
set(GUI_SegmentManual_lvlDown,'callback',{@lvlDown});

% Subment exposure element into the 3D object design
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_SegmentManual_Segment = uicontrol('style', 'pushbutton','string','Submit',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_9+5.*dx_9+3.*dx_9b y0_9 round(2.*ddx_9b) ddy_9],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor','blue',...
    'TooltipString',...
    'Submit new segment to 3D object');
set(GUI_SegmentManual_Segment,'callback',{@Segment});

% Execute file upload of segment distribution
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_SegmentManual_LoadSegments = uicontrol('style', 'pushbutton','string','Load {i,f}',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_1+1.*dx_1 y0_1+1.*dy_1 ddx_1 ddy_1],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',SegmentHue,...
    'TooltipString','Load segment instructions from text file.');
set(GUI_SegmentManual_LoadSegments,'callback',{@LoadSegments});

% Advanced level editor
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% initial vertex for duplication (title)
uicontrol('Style','text','String','i','Position',fGUI.*[x0_11 y0_11 ddx_11 ddy_11],...
    'BackgroundColor',FigHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
% initial vertex for duplication (title)
uicontrol('Style','text','String','f','Position',fGUI.*[x0_11+dx_11 y0_11 ddx_11 ddy_11],...
    'BackgroundColor',FigHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');


% Maximum number of segment vertex pairs displayed in the GUI for manual
% editing of segment properties
DispSegs = 25; %[25]
% Two indices per segment requires that a maximum of {2*DispSegs} GUI
% elements need to be displayed at a time in order to fully edit the
% segment geometry
MaxUIs = round(2.*DispSegs); %[1,2,3,...]
% Total number of GUI input boxes required equals the number of segments
% allowed per level...but only {2*DispSegs} will be displayed at a time.
% The "bundle" of segments can be changed range selection which is
% introduced below
Obj_xy = zeros(1,round(2.*NumSegsPerLevel_Limit));
% One input box per segment which serves two purposes; (1) shot reordering
% and (2) deleting.  These functions can now be performed simultaneously.
iObj_xy = zeros(1,DispSegs);
% Integer number of overlapped GUI elements, termed "bundles"
DupliView = round(NumSegsPerLevel_Limit./DispSegs); %[1,2,3,...]

% Variable for selecting vertices defining segments
ij = 0; %[1,2,3,...]
% Variable for selecting the shot order/deletion of a segment
jk = 0; %[1,2,3,...]
% ...per segment bundle per level
for p0=1:DupliView
    % ...per segment
    for m0=1:DispSegs
        % ...[=1] initial vertex and [=2] final vertex
        for n0=1:2
            
            ij = ij + 1; %[1,2,3,...]
            % Initialize GUI element for vertex display
            Obj_xy(ij) = uicontrol('Style','edit',...
                'String',num2str(0),...
                'Position',fGUI.*[x0_11+(n0-1).*dx_11 (y0_11-10)-(m0).*dy_11 ddx_11 ddy_11],...
                'BackgroundColor',UIHue,'ForegroundColor',SegmentHue,'FontSize',FS,...
                'FontWeight','normal','HorizontalAlignment','center',...
                'UserData',[n0 m0],'Visible','on');
            % Initialize with first bundle of segments per level shown.
            if ij > MaxUIs
                set(Obj_xy(ij),'Visible','off');
            end
        end
        
        jk = jk + 1; %[1,2,3,...]
        % Initialize GUI elememt
        iObj_xy(jk) = uicontrol('Style','edit',...
            'String',num2str(0),...
            'Position',fGUI.*[x0_11+2.*dx_11 (y0_11-10)-(m0).*dy_11 ddx_11b ddy_11],...
            'BackgroundColor',SegmentHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
            'FontWeight','normal','HorizontalAlignment','center',...
            'UserData',[n0 m0],'Visible','on');
        % Initialize with first bundle of segments per level shown.
        if jk > DispSegs
            set(iObj_xy(jk),'Visible','off');
        end
    end
end


% Current segment bundle of segments
Bundle = 1; %[1,2,3...]
% Segment range definition (initial segment index; 1, 26, 51, etc.)
% Example based on {DispSegs = 25}
GUI_SegmentManual_iDisplayRange = uicontrol('Style','text','String','1',...
    'Position',fGUI.*[x0_11+dx_11 (y0_11-10)-(DispSegs+1).*dy_11 ddx_11 ddy_11],...
    'BackgroundColor',FigHue,...
    'ForegroundColor',SegmentHue,'FontSize',FS,'FontWeight','normal',...
    'HorizontalAlignment','center','FontAngle','italic');
% Segment range (final segment index: 25, 50, 75, etc.)
% Example based on {DispSegs = 25}
uicontrol('Style','text','String','to',...
    'Position',fGUI.*[x0_11+dx_11 (y0_11-10)-(DispSegs+2).*dy_11 ddx_11 ddy_11],...
    'BackgroundColor',FigHue,...
    'ForegroundColor',SegmentHue,'FontSize',FS,'FontWeight','normal',...
    'HorizontalAlignment','center','FontAngle','italic');
% Segment range definition (initial segment index; 1, 26, 51, etc.)
% Example based on {DispSegs = 25}
GUI_SegmentManual_fDisplayRange = uicontrol('Style','text','String','25',...
    'Position',fGUI.*[x0_11+dx_11 (y0_11-10)-(DispSegs+3).*dy_11 ddx_11 ddy_11],...
    'BackgroundColor',FigHue,...
    'ForegroundColor',SegmentHue,'FontSize',FS,'FontWeight','normal',...
    'HorizontalAlignment','center','FontAngle','italic');
% Toggle though segment characteristics in the case of multiple pages of
% segments
GUI_SegmentManual_iLeft = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_11+round((ddx_11-25)./2) (y0_11-10)-(DispSegs+2).*dy_11-round((50-ddy_11)./2) size(lMap,2) size(lMap,1)],'FontSize',FS,...
    'CData',lMap,'callback',{@iLeft});
GUI_SegmentManual_iRight = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_11+2.*dx_11+round((ddx_11-25)./2) (y0_11-10)-(DispSegs+2).*dy_11-round((50-ddy_11)./2) size(rMap,2) size(rMap,1)],'FontSize',FS,...
    'CData',rMap,'callback',{@iRight});

% Segment changes in text edit boxes for initial position of segment, final
% position of segment, segment exposure order and segment delete.  
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_SegmentManual_SegmentEdit = uicontrol('style', 'pushbutton','string','!',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_11+2.*dx_11+round( (ddx_11b - ddy_11)./2 ) y0_11 ddy_11 ddy_11],'FontSize',(FS+2),...
    'ForeGroundColor',[1 1 0],'BackgroundColor',SegmentHue,'TooltipString',...
    sprintf('Segment Exposure Order per Level \n(1) Enter 0 to remove a segment and/or \n(2) swap integers to swap exposure sequence.'));
set(GUI_SegmentManual_SegmentEdit,'callback',{@SegmentEdit});


% GUI_FolderManage_{User Interface}
% Load past design folders and rename file folders
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% File name for design folder
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% File name identifier
uicontrol('Style','text','String','design folder','Position',fGUI.*[x0_10 y0_10 ddx_10 ddy_10],...
    'BackgroundColor',FigHue,'ForegroundColor',[0.4 0.4 0.4],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left','FontAngle','italic');
% Change file name
GUI_FolderManage_LoadDesignFolder = uicontrol('Style','edit',...
    'String',DesignFolderName,'Position',fGUI.*[x0_10 y0_10-1.*dy_10 ddx_10 ddy_10],...
    'BackgroundColor',UIHue,'ForegroundColor',[0.4 0.4 0.4],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
set(GUI_FolderManage_LoadDesignFolder,'callback',{@LoadDesignFolder});

% Create a new design folder
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_FolderManage_NewDesign = uicontrol('style', 'pushbutton','string','New Design',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_22 y0_22 ddx_22 ddy_22],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',[0 0 0]);
set(GUI_FolderManage_NewDesign,'callback',{@NewDesign});

% Toggle for Manual/Automatic screen frame capture
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Manual screen capture on [=0] or automatic screen capture on [=1]
uiRecordActions = false; %[0/1]
GUI_Document_ScreenCaptureOn = uicontrol('style', 'togglebutton','string','M',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_23+dx_23a y0_23 ddx_23 ddy_23],'FontSize',(FS+2),...
    'ForeGroundColor',[1 1 1],'BackgroundColor',[1 0 0],'TooltipString',...
    'Enter 0 to remove a segment. Then, renumber with contiguous integer values');
set(GUI_Document_ScreenCaptureOn,'callback',{@ScreenCaptureOn});

% Screen capture of GUI
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Document_ScreenCapture = uicontrol('style', 'pushbutton','ForegroundColor',[1 1 1],...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_23 y0_23 size(camMap,2) size(camMap,1)],...
    'FontSize',(FS-1),'CData',camMap);
set(GUI_Document_ScreenCapture,'callback',{@ScreenCapture});

% Screen capture frame counter
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Counter for UI frame capture
New_UI_Image = 0; %[1,2,3,...]
% File name identifier
GUI_Document_ScreenCaptureFrame = uicontrol('Style','text',...
    'String',num2str(New_UI_Image),'Position',fGUI.*[x0_23+dx_23b y0_23 ddx_23 ddy_23],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0 0],'FontSize',FS,...
    'FontWeight','bold','HorizontalAlignment','center');



% GUI_DesignAction_{User Interface}
% Each design step is saved to memory and can be recalled for Redo/Undo purposes
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% "Actions" text label
uicontrol('Style','text','String','# User actions',...
    'Position',fGUI.*[x0_15 y0_15 ddx_15 ddy_15],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString','Total # of User actions used to define 3Dobj');
% UndoRedo by selecting a past action number
GUI_DesignAction_InputActionNumber = uicontrol('Style','edit',...
    'String',num2str(UndoRedo),...
    'Position',fGUI.*[x0_15+dxLeft y0_15-1.*dzGUI+dyUp ddx_15b ddy_15],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_DesignAction_InputActionNumber,'callback',{@InputActionNumber});
% Maximum "Actions" number displayed.  This is the maximum design step
% number that has been saved
strNewActions = num2str(NewActions);
GUI_DesignAction_MaxActionNumber = uicontrol('Style','text','String',strNewActions,...
    'Position',fGUI.*[x0_15+dx_15 y0_15 ddx_15b ddy_15],...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','Callback',{@MaxActionNumber});
% "Actions" backward by 1 design step
GUI_DesignAction_ActionForward = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_15+dxRight+dxLeft y0_15-1.*dzGUI size(fMap,2) size(fMap,1)],...
    'FontSize',FS,'CData',fMap);
set(GUI_DesignAction_ActionForward,'callback',{@ActionForward});
% "Actions" forward by 1 design step
GUI_DesignAction_ActionBackward = uicontrol('style','pushbutton',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_15 y0_15-1.*dzGUI size(bMap,2) size(bMap,1)],...
    'FontSize',FS,'CData',bMap);
set(GUI_DesignAction_ActionBackward,'callback',{@ActionBackward});



% GUI_Expose_...{User Interface}
% Pixel point pitch, initial asperity height, visualize shot distribution,
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Render shot distribution in 3D
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Checkbox for displaying the 3D shots render
GUI_Expose_VisualizeExposure = uicontrol('Style','checkbox','String','Shots?',...
    'Position',fGUI.*[x0_6 y0_6+3.*dy_6 ddx_6 ddy_6],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',(FS-2),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'TooltipString',...
    sprintf('Displays 3D exposure pattern in {x,y,z} \nplot when "BuildCAD" is pressed'));
set(GUI_Expose_VisualizeExposure,'callback',{@VisualizeExposure});

% Array exposure required
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Array exposure indicated [=1] or exposure only 1 instance of defined 3D
% object [=0]
TrigArrayExp = false; %[0/1]
% Checkbox for array exposure
GUI_Expose_Arrays = uicontrol('Style','checkbox','String','Arrays?',...
    'Position',fGUI.*[x0_6 y0_6+2.*dy_6 ddx_6 ddy_6],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',(FS-2),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'TooltipString',sprintf('Generates an array of the 3D object during \nexposure file creation as specified in "ArrayRequest.txt".'));
set(GUI_Expose_Arrays,'callback',{@ArrayExposure});

% Array exposure required
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Flip the sign of all {y} coordinates in the final exposure file.
yInversion = true; %[0/1]
% Checkbox for array exposure
GUI_Expose_Flip_y = uicontrol('Style','checkbox','String','-y?',...
    'Position',fGUI.*[x0_6 y0_6+1.*dy_6 ddx_6 ddy_6],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',(FS-2),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'TooltipString',...
    sprintf('Inverts the y-coordinate during exposure file creation.  \nThis makes the pattern view as shown in the {x,y} plot \n match the view on the FEI console window.'));
set(GUI_Expose_Flip_y,'callback',{@Flip_y});


% File name for 3D FEBiD Exposure File
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
FileName = 'Exposure_File_Name'; %[s]
% File name identifier
uicontrol('Style','text','String','file name','Position',fGUI.*[x0_8 y0_8+1.*dy_8 ddx_8 ddy_8],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left','FontAngle','italic');
% Change file name
GUI_Expose_ExposureFileName = uicontrol('Style','edit',...
    'String',FileName,...
    'Position',fGUI.*[x0_8+dx_8 y0_8+1.*dy_8 round(3.*ddx_8+1.*dx_8b) ddy_8],...
    'BackgroundColor',UIHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic');
set(GUI_Expose_ExposureFileName,'callback',{@ExposureFileName});

% Pixel point pitch
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Pixel point pitch (title)
uicontrol('Style','text','String','PoP (nm)',...
    'Position',fGUI.*[x0_8+2.*dx_8+1.*dx_8b y0_8+2.*dy_8 ddx_8c ddy_8],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    sprintf('Pixel point pitch for all segments, \nprojected into the focal plane (xy).'));
% Pixel point pitch (value)
GUI_Expose_PixelPointPitch = uicontrol('Style','edit','String',num2str(ds),...
    'Position',fGUI.*[x0_8+3.*dx_8+1.*ddx_8b y0_8+2.*dy_8 ddx_8b ddy_8],...
    'BackgroundColor',UIHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Expose_PixelPointPitch,'callback',{@PixelPointPitch});

% Magnification
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
pow2_Bits = 2.^BitDepth; %[1,2,4,...]
% Magnification required for exposure
Mag = MagHFW./(iPoP.*pow2_Bits.*0.001); %[um/um]
s_Mag = sprintf('%gx',Mag); %[s]
% Magnification (title)
uicontrol('Style','text','String','Mag',...
    'Position',fGUI.*[x0_13 y0_13-3.*dy_13 ddx_13b ddy_13],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',sprintf('Required exposure magnification \n for experiments'));
GUI_Expose_Mag = uicontrol('Style','text','String',s_Mag,...
    'Position',fGUI.*[x0_13+dx_13 y0_13-3.*dy_13 ddx_13b ddy_13],...
    'BackgroundColor',[0.8 0.85 0.25],'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');

% Mag*HFW
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Magnification (title)
uicontrol('Style','text','String','Mag*HFW',...
    'Position',fGUI.*[x0_13 y0_13-2.*dy_13 ddx_13b ddy_13],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',sprintf('Magnification x horizontal field width [nm]. \nSpecified in {}_Parameters.txt file'));
GUI_Expose_MagHFW = uicontrol('Style','text','String',num2str(MagHFW),...
    'Position',fGUI.*[x0_13+dx_13 y0_13-2.*dy_13 ddx_13b ddy_13],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');

% Image pixel point pitch
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Image pixel point pitch (iPoP)
uicontrol('Style','text','String','iPoP (nm)',...
    'Position',fGUI.*[x0_13 y0_13-dy_13 ddx_13b ddy_13],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',... 
    'TooltipString',sprintf('Pixel point pitch for exposure file.  \n{PoP} >= {iPoP}.'))
GUI_Expose_iPoP = uicontrol('Style','edit','String',num2str(iPoP),...
    'Position',fGUI.*[x0_13+dx_13 y0_13-dy_13 ddx_13b ddy_13],...
    'BackgroundColor',UIHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','Callback',{@MagnificationSetting});

% Artifact pixel exposure position which is used to avoid unwanted
% exposures on the 3D object of interest
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','{x,y}  (nm)','Position',fGUI.*[x0_13 y0_13 ddx_13b ddy_13],...
    'BackgroundColor',FigHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    sprintf('Artifact dwell position for 12-bit patterning.  \nInitial and final dwell in exposure file.'));
GUI_Expose_xBad = uicontrol('Style','edit','String',num2str(xArtifact),...
    'Position',fGUI.*[x0_13+dx_13 y0_13 ddx_13 ddy_13],...
    'BackgroundColor',UIHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','Callback',{@ArtifactDwell});
GUI_Expose_yBad = uicontrol('Style','edit','String',num2str(yArtifact),...
    'Position',fGUI.*[x0_13+dx_13+ddx_13+round(ddx_13b-2.*ddx_13) y0_13 ddx_13 ddy_13],...
    'BackgroundColor',UIHue,'ForegroundColor',BuildCADHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','Callback',{@ArtifactDwell});


% Text display of the critical experimental conditions used to generate the
% calibration file
% ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Expose_CalibrationFileDetails = uicontrol('Style','text',...
    'String',CalibrationFileInfo{1},'Position',fGUI.*[x0_0 y0_0-2.75.*dy_0 ddx_0b ddy_0b],...
    'BackgroundColor','w','ForegroundColor',BuildCADHue,'FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','left');

% FEI PIA type (button on = 16 bit)
% Controls the # of pixels available for patterning
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Expose_sOff_TextWhenOn = uicontrol('style','text','String','^16',...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0.5 0],...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18+2.*dx_18 y0_18+dy_18a ddx_18 ddy_18],'FontSize',(FS-2),...
    'FontAngle','italic');

% FEI PIA type (button off = 12 bit)
% Controls the # of pixels available for patterning
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Expose_sOff_TextWhenOff = uicontrol('style','text','String','^12',...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0 0],...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18+2.*dx_18 y0_18+dy_18b ddx_18 ddy_18],'FontSize',(FS-2),...
    'FontAngle','italic');

% FEI PIA type (toggle button)
% Controls the # of pixels available for patterning
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Expose_sOff = uicontrol('style','toggle',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18+2.*dx_18 y0_18 size(sOff,2) size(sOff,1)],'FontSize',FS,...
    'CData',sOff,...
    'ToolTipString',...
    '12 or 16 bit patterning image?  Currently, switch is fixed.  Required info comes from {}_Parameters.txt file.');
set(GUI_Expose_sOff,'callback',{@SwitchForBitDepth});


% Execute exposure file creation
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Expose_CAD = uicontrol('style', 'pushbutton','string','Build CAD',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_8 y0_8 2.*ddx_8 ddy_8],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',BuildCADHue,...
    'TooltipString',...
    'Create FEBID exposure file');
set(GUI_Expose_CAD,'callback',{@CADbuild});



% GUI_Operations_{User Interface}
% Mathematical operations applied to vertices
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Center in {xy-plane}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% The average position of all vertices is calculated in order to center the
% object about {x,y}
GUI_Operations_Cxy = uicontrol('Style','pushbutton','String','+',...
    'Position',fGUI.*[x0_2 y0_2+2.*dy_2 ddx_2 ddy_2],...
    'BackgroundColor',VertexHue,'ForegroundColor',[1 1 1],'FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'TooltipString','Center 3Dobj in {xy-plane}');
set(GUI_Operations_Cxy,'callback',{@Cxy});

% Substrate contact {z}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Lowest point {z} in vertex list is found and a displacement is applied
% such that z=0 for this point.  The shift is applied to all vertices.
GUI_Operations_zAttach = uicontrol('Style','pushbutton','String','@z',...
    'Position',fGUI.*[x0_2+dx_2 y0_2+2.*dy_2 ddx_2 ddy_2],...
    'BackgroundColor',VertexHue,'ForegroundColor',[1 1 1],'FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'TooltipString','Place 3Dobj on substrate {z=0}');
set(GUI_Operations_zAttach,'callback',{@zAttach});


% Rotate in the {xy-plane}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Rotation pushbutton execution (value)
GUI_Operations_Rxy = uicontrol('Style','pushbutton','String','Rxy',...
    'Position',fGUI.*[x0_2 y0_2+1.*dy_2 ddx_2 ddy_2],...
    'BackgroundColor',VertexHue,'ForegroundColor','w','FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString',sprintf('Rotation of vertices about the +{z} vector. \n in degrees. \nUse "vertex list" above to specify vertices'));
set(GUI_Operations_Rxy,'callback',{@Rxy});
% Rotation value (value)
GUI_Operations_RxyValue = uicontrol('Style','edit','String',num2str(theta),...
    'Position',fGUI.*[x0_2 y0_2 ddx_2 ddy_2],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Operations_RxyValue,'callback',{@RxyValue});

% Tilt in the {xz-plane}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Tilt in {xz-plane) pushbutton
GUI_Operations_Txz = uicontrol('Style','pushbutton','String','Txz',...
    'Position',fGUI.*[x0_2+dx_2 y0_2+1.*dy_2 ddx_2 ddy_2],...
    'BackgroundColor',VertexHue,'ForegroundColor','w','FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center',...
     'ToolTipString',sprintf('Rotation of vertices about the +{y} vector. \n in degrees. \nUse "vertex list" above to specify vertices'));
set(GUI_Operations_Txz,'callback',{@Txz});
% rotation value
GUI_Operations_TxzValue = uicontrol('Style','edit','String',num2str(alpha),...
    'Position',fGUI.*[x0_2+dx_2 y0_2 ddx_2 ddy_2],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Operations_TxzValue,'callback',{@TxzValue});

% Tilt in the {yz-plane}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Tilt in {yz-plane) pushbutton
GUI_Operations_Tyz = uicontrol('Style','pushbutton','String','Tyz',...
    'Position',fGUI.*[x0_2+2.*dx_2 y0_2+1.*dy_2 ddx_2 ddy_2],...
    'BackgroundColor',VertexHue,'ForegroundColor','w','FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString',sprintf('Rotation of vertices about the +{x} vector. \n in degrees. \nUse "vertex list" above to specify vertices'));
set(GUI_Operations_Tyz,'callback',{@Tyz});
% rotation value
GUI_Operations_TyzValue = uicontrol('Style','edit','String',num2str(beta),...
    'Position',fGUI.*[x0_2+2.*dx_2 y0_2 ddx_2 ddy_2],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Operations_TyzValue,'callback',{@TyzValue});

% Wrap in {x-coordinate}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% All vertices are (1) converted from (x,y,z) to (x,0,z) and then (2) 
% wrapped onto the surface of a cylinder which points along the z-axis
% and is centered at (x=0,y=0).  The text input box is the radius (rCyl) 
% of the cylinder in nanometers.  
GUI_Operations_Wxy = uicontrol('Style','pushbutton','String','Wz',...
    'Position',fGUI.*[x0_2+3.*dx_2 y0_2+1.*dy_2 ddx_2 ddy_2],...
    'BackgroundColor',VertexHue,'ForegroundColor','w','FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString',sprintf('Wraps vertices around the +{z} axis based on {x} coordinate as path length \n around a circle and characterized by a wrap radius specified (below) \nin units of [nm]. Use "vertex list" above to specify vertices'));
set(GUI_Operations_Wxy,'callback',{@Wxy});
% rotation value
GUI_Operations_WxyValue = uicontrol('Style','edit','String',num2str(rWrap),...
    'Position',fGUI.*[x0_2+3.*dx_2 y0_2 ddx_2 ddy_2],...
    'BackgroundColor',UIHue,'ForegroundColor',[0 0 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Operations_WxyValue,'callback',{@WxyValue});



% GUI_SegmentAutomatic_{User Interface}
% Automatic segment identification and level identification
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Enter element length for segment detection
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','L (nm)','Position',fGUI.*[x0_14 y0_14 ddx_14 ddy_14],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',sprintf('Segment length for submission to \nthe vertex spacing histogram'));
GUI_SegmentAutomatic_CriticalRadii= uicontrol('Style','edit','String',num2str(Lxyz1D(1)),...
    'Position',fGUI.*[x0_14+dx_14 y0_14 ddx_14b ddy_14],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');


% Enter element length half-width for segment detection
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','dL (nm)','Position',fGUI.*[x0_14 y0_14-dy_14 ddx_14 ddy_14],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString','Segment length bin half-width');
GUI_SegmentAutomatic_CriticalRadiiDev= uicontrol('Style','edit','String',num2str(dLxyz1D(1)),...
    'Position',fGUI.*[x0_14+dx_14 y0_14-dy_14 ddx_14b ddy_14],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');

% Current element length selected of those that have been submitted
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Total number of characteristic element lengths selected
LxyzCritIndex = sprintf('Bin #(%g)',n_Lxyz1D); %[idx]
GUI_SegmentAutomatic_IndexLabel = uicontrol('Style','text','String',LxyzCritIndex,...
    'Position',fGUI.*[x0_14 y0_14-2.*dy_14 ddx_14 ddy_14],...
    'BackgroundColor',FigHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString','# of submitted bins');
GUI_SegmentAutomatic_ElementIndex= uicontrol('Style','edit','String',num2str(c_Lxyz1D),...
    'Position',fGUI.*[x0_14+dx_14 y0_14-2.*dy_14 ddx_14b ddy_14],...
    'BackgroundColor',UIHue,'ForegroundColor',VertexHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'TooltipString','Bin index number for submission to histogram',...
    'callback',{@ChangeElementCharacteristics});

% Submit new (1) element length and (2) element length bin half-width
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_SegmentAutomatic_NewElements = uicontrol('style', 'pushbutton','string','1 Set Bin',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_14 y0_14-3.*dy_14 ddx_14b ddy_14],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',VertexHue,'TooltipString',...
    'Step #1; submit segment length bin to histogram');
set(GUI_SegmentAutomatic_NewElements,'callback',{@NewElements});
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Range objects for visual representation of element length ranges
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Histogram bars for vertex spacing plot
axes(izAxis)
% Histogram bar individual patches
Rng_Hist = zeros(1,MaxNumBins); %[obj]
% ...per histogram patch
for m0=1:MaxNumBins
    % Vertex spacing intensity
    Rng_Hist(m0) = patch([0 xAxisMaxHistogram xAxisMaxHistogram 0],...
        [0 0 dLam dLam]+(dLam./2) + (m0-1).*dLam,'y','EdgeColor',[0 0 1],...
        'FaceColor',[1 1 0],'FaceAlpha',0.4);
    set(Rng_Hist(m0),'Visible','Off')
end

% Reset the list of element lengths submitted
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_SegmentAutomatic_ElementsReset = uicontrol('style', 'pushbutton','string','!',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_14+dx_14+1.5.*ddx_14b-ddy_14 y0_14-2.*dy_14 ddy_14 ddy_14],'FontSize',(FS+2),...
    'ForeGroundColor',[1 1 0],'BackgroundColor',VertexHue,...
    'TooltipString',sprintf('Reset the bin distribution currently \non the histogram'));
set(GUI_SegmentAutomatic_ElementsReset,'callback',{@ElementsReset});

% Execute search for all segments that span the submitted element ranges
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_SegmentAutomatic_AutoSegmentID = uicontrol('style', 'pushbutton','string','2 Seg ID',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_14+dx_14 y0_14-3.*dy_14 ddx_14b ddy_14],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',SegmentHue,'TooltipString',...
    'Step #2 Connect; segments in specified range');
set(GUI_SegmentAutomatic_AutoSegmentID,'callback',{@AutoSegmentID});
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Vertices in contact with the substrate (for use with auto-segment search)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Vertices bound to substrate; variable {sCube}
GUI_Operations_zBond = uicontrol('Style','pushbutton','String','3 Sub Cnt',...
    'Position',fGUI.*[x0_14 y0_14-4.*dy_14 ddx_14b ddy_14],...
    'BackgroundColor',VertexHue,'ForegroundColor',[1 1 1],'FontSize',(FS-1),...
    'FontWeight','normal','HorizontalAlignment','center',...
    'TooltipString','Vertices in contact with the substrate');
set(GUI_Operations_zBond,'callback',{@zBond});

% Auto-exposure order detection for elements
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_SegmentAutomatic_AutoExposureOrder = uicontrol('style', 'pushbutton','string','4 Exp Seq',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_14+dx_14 y0_14-4.*dy_14 ddx_14b ddy_14],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',SegmentHue,'TooltipString',...
    'Step #4 Levels; assign to each segment');
set(GUI_SegmentAutomatic_AutoExposureOrder,'callback',{@AutoExposureOrder});
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo



% GUI_Calibration_...{User Interface}
% Fitting of calibration curve
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Type {VGR}, experimental value
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','VGR (nm/s)','Position',fGUI.*[x0_8 y0_8+2.*dy_8 ddx_8c ddy_8],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'ToolTipString','Experimental vertical growth rate (VGR) or "sent" value from fitting');
GUI_Calibration_TypevDz = uicontrol('Style','edit','String',num2str(vDz),...
    'Position',fGUI.*[x0_8+dx_8c y0_8+2.*dy_8 ddx_8b ddy_8],...
    'BackgroundColor',[1 1 1],'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString','Experimental vertical growth rate (VGR) or "sent" value from fitting');
set(GUI_Calibration_TypevDz,'callback',{@TypevDz});

% "guess" column heading
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','guess',...
    'Position',fGUI.*[x0_3+dx_3a y0_3+4.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','Guess value centered at...');

% "+/- range" column heading
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','+/-',...
    'Position',fGUI.*[x0_3+dx_3a+dx_3b y0_3+4.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','..with a range of {+/-} about the center...');

% "increment" column heading
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','step',...
    'Position',fGUI.*[x0_3+dx_3a+2.*dx_3b y0_3+4.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','...and an increment of {step}...');

% "fit" column heading
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','fit',...
    'Position',fGUI.*[x0_3+dx_3a+3.*dx_3b y0_3+4.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString','Fitted value with lowest minimization parameter');

% Type {VGR} vertical growth rate
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Vertical growth rate (guess)
VGR = 130; %[nm/s]
% {VGR} value selected (title)
uicontrol('Style','text','String','VGR (nm/s)','Position',fGUI.*[x0_3 y0_3+3.*dzGUI ddx_3a ddy_3],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'ToolTipString','Vertical/normal Growth Rate (VGR)');
% {VGR} value selected (value)
GUI_Calibration_TypeVGR = uicontrol('Style','edit','String',num2str(VGR),...
    'Position',fGUI.*[x0_3+dx_3a y0_3+3.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString','Vertical/normal Growth Rate (VGR)');
set(GUI_Calibration_TypeVGR,'callback',{@TypeVGR});

% Type {VGR} vertical growth rate range
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Vertical growth rate (+/- range about {VGR} for fitting)
rVGR = 10; %[nm/s]
% {VGR} value selected (range)
GUI_Calibration_TypeVGR_Range = uicontrol('Style','edit','String',num2str(rVGR),...
    'Position',fGUI.*[x0_3+dx_3a+dx_3b y0_3+3.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Calibration_TypeVGR_Range,'callback',{@TypeVGR_Range});

% Type {VGR} vertical growth rate increment
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Vertical growth rate (increment for fitting)
dVGR = 5; %[nm/s]
% {VGR} value selected (range)
GUI_Calibration_TypeVGR_Increment = uicontrol('Style','edit','String',num2str(dVGR),...
    'Position',fGUI.*[x0_3+dx_3a+2.*dx_3b zPivGUI+22.*dzGUI 60 25],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Calibration_TypeVGR_Increment,'callback',{@TypeVGR_Increment});

% Best fit {VGR} value
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Vertical growth rate (fitted)
FitVGR = 0; %[nm/s]
% {VGR} best fit value
GUI_Calibration_VGR_Fit = uicontrol('Style','text','String','',...
    'Position',fGUI.*[x0_3+dx_3a+3.*dx_3b zPivGUI+22.*dzGUI 60 25],...
    'BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');

% Type {pPD} percent precursor depletion
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Percent precursor depletion (guess)
pPD = 0.6; %[0-1]
uicontrol('Style','text','String','pPD (0-1)','Position',fGUI.*[x0_3 y0_3+2.*dzGUI ddx_3a ddy_3],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'ToolTipString','percent Precursor Depletion (pPD)');
GUI_Calibration_TypepPD = uicontrol('Style','edit','String',num2str(pPD),...
    'Position',fGUI.*[x0_3+dx_3a y0_3+2.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString','percent Precursor Depletion (pPD)');
set(GUI_Calibration_TypepPD,'callback',{@TypepPD});

% Type {pPD} percent precursor depletion range
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Percent precursor depletion (+/- range about {pPD} for fitting)
rpPD = 0.1; %[nm]
% {rpPD} value selected (range)
GUI_Calibration_TypepPD_Range = uicontrol('Style','edit','String',num2str(rpPD),...
    'Position',fGUI.*[x0_3+dx_3a+dx_3b y0_3+2.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Calibration_TypepPD_Range,'callback',{@TypepPD_Range});

% Type {pPD} beam size/deposit width (ELR) increment
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Percent precursor depletion (increment for fitting)
dpPD = 0.05; %nm]
GUI_Calibration_TypepPD_Increment = uicontrol('Style','edit','String',num2str(dpPD),...
    'Position',fGUI.*[x0_3+dx_3a+2.*dx_3b y0_3+2.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Calibration_TypepPD_Increment,'callback',{@TypepPD_Increment});

% Best fit {pPD} percent precursor depletion range
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Percent precursor depletion  (fitted)
FitpPD = 0; %[nm/s]
% {VGR} best fit value
GUI_Calibration_pPD_Fit = uicontrol('Style','text','String','',...
    'Position',fGUI.*[x0_3+dx_3a+3.*dx_3b y0_3+2.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');

% Type {rPD} rate of precursor depletion
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Rate of precursor depletion (guess)
rPD = 8; %[ms]
uicontrol('Style','text','String','rPD (ms)','Position',fGUI.*[x0_3 y0_3+1.*dzGUI ddx_3a ddy_3],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'ToolTipString','rate of Precursor Depletion (rPD)');
GUI_Calibration_TyperPD = uicontrol('Style','edit','String',num2str(rPD),...
    'Position',fGUI.*[x0_3+dx_3a y0_3+1.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'ToolTipString','rate of Precursor Depletion (rPD)');
set(GUI_Calibration_TyperPD,'callback',{@TyperPD});

% Type {rPD} rate of precursor depletion
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Rate of precursor depletion (+/- range about {rPD} for fitting)
rrPD = 1; %[ms]
GUI_Calibration_TyperPD_Range = uicontrol('Style','edit','String',num2str(rrPD),...
    'Position',fGUI.*[x0_3+dx_3a+dx_3b y0_3+1.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Calibration_TyperPD_Range,'callback',{@TyperPD_Range});

% Type {rPD} Rate of precursor depletion
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Rate of precursor depletion (increment for fitting)
drPD = 0.5; %[ms]
GUI_Calibration_TyperPD_Increment = uicontrol('Style','edit','String',num2str(drPD),...
    'Position',fGUI.*[x0_3+dx_3a+2.*dx_3b y0_3+1.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Calibration_TyperPD_Increment,'callback',{@TyperPD_Increment});

% Best fit {rPD} value
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Rate of precursor depletion (fitted)
FitrPD = 0; %[nm/s]
GUI_Calibration_rPD_Fit = uicontrol('Style','text','String','',...
    'Position',fGUI.*[x0_3+dx_3a+3.*dx_3b y0_3+1.*dzGUI ddx_3b ddy_3],...
    'BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');

% Allowable deviation in the segment angle {dSeg}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','Q (deg)','Position',fGUI.*[x0_3 y0_3 ddx_3a ddy_3],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Maximum allowable deviation, in degress, for any data point in fit');
GUI_Calibration_FitQuality = uicontrol('Style','edit','String',num2str(dSeg),...
    'Position',fGUI.*[x0_3+dx_3a y0_3 ddx_3b ddy_3],...
    'BackgroundColor',FitHue,'ForegroundColor',[1 1 1],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');
set(GUI_Calibration_FitQuality,'callback',{@FitQuality});

% Dwell time (minimum) for exposure file
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','Dwell (ms)',...
    'Position',fGUI.*[x0_4 y0_4+2.*dy_4 ddx_4a ddy_4],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Minimum allowable dwell time in exposure file');
GUI_Calibration_TauMin = uicontrol('Style','text','String',num2str(TauMin),...
    'Position',fGUI.*[x0_4+dx_4 y0_4+2.*dy_4 ddx_4b ddy_4],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','Callback',{@TauMinSet});

% Segment angle (minimum)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Minimum segment angle possible in CAD design
ZetaMin = 0; %[deg]
uicontrol('Style','text','String','Zeta (min)',...
    'Position',fGUI.*[x0_4 y0_4+1.*dy_4 ddx_4a ddy_4],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Minimum allowable segment angle in exposure file')
GUI_Calibration_ZetaMin = uicontrol('Style','text','String',num2str(ZetaMin),...
    'Position',fGUI.*[x0_4+dx_4 y0_4+1.*dy_4 ddx_4b ddy_4],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');

% Segment angle (maximum)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Maximum segment angle possible in CAD design
ZetaMax = 0; %[deg]
uicontrol('Style','text','String','Zeta (max)','Position',fGUI.*[x0_4 y0_4 ddx_4a ddy_4],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left',...
    'TooltipString',...
    'Maximum allowable segment angle in exposure file')
GUI_Calibration_ZetaMax = uicontrol('Style','text','String',num2str(ZetaMax),...
    'Position',fGUI.*[x0_4+dx_4 y0_4 ddx_4b ddy_4],...
    'BackgroundColor',FigHue,'ForegroundColor',FitHue,'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center');

% Calibration file name
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% File name identifier
uicontrol('Style','text','String','Calibration file',...
    'Position',fGUI.*[x0_4 y0_4+4.*dy_4 ddx_4a ddy_4],...
    'BackgroundColor',FigHue,'ForegroundColor',[0.4 0.4 0.4],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left','FontAngle','italic');
% Change file name
GUI_Calibration_FileName = uicontrol('Style','popupmenu',...
    'String',RecipesPopUp,'Position',fGUI.*[x0_4 y0_4+3.*dy_4 ddx_4c ddy_4],...
    'BackgroundColor',UIHue,'ForegroundColor',[0.4 0.4 0.4],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'callback',{@LoadCalibrationFile});

% Executed the fitting process for calibration curve data
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Calibration_Fit = uicontrol('style', 'pushbutton','string','Fit',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_3+dx_3a+dx_3b y0_3 round(dx_3b-ddx_3b)+2.*ddx_3b ddy_3],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',[1 0 0],'callback',{@SegmentDataFit});

% Update the experimental vertical growth rate with the fitted one
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% The fitted value of the {VGR} is submitted as the vertical growth rate
% that will be used for exposure file creation and applies to elements of
% the "pillar" type.
GUI_Calibration_Send = uicontrol('style', 'pushbutton','string','Send',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_3+dx_3a+3.*dx_3b y0_3 ddx_3b ddy_3],'FontSize',(FS-1),...
    'ForeGroundColor','white','BackgroundColor',FitHue,...
    'TooltipString',...
    'Send fitted {VGR} to the exposure setting (lower-left of GUI)','callback',{@SendFitVGR});

% Segment angle calibration data select (button on = fitting data)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Calibration_sOff_TextWhenOn = uicontrol('style','text','String','fit',...
    'BackgroundColor',FigHue,'ForegroundColor',[0 0.5 0],...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18 y0_18+dy_18a ddx_18 ddy_18],'FontSize',(FS-2),...
    'FontAngle','italic');

% Segment angle calibration data select (button off = experimental data)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
GUI_Calibration_sOff_TextWhenOff = uicontrol('style','text','String','exp',...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0 0],...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18 y0_18+dy_18b ddx_18 ddy_18],'FontSize',(FS-2),...
    'FontAngle','italic');

% Segment angle calibration data select (toggle button)
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Segment angle interpolation using (=0) fitted data or (=1) raw exp data
CalibrateByExpData = 1; %[0/1]
GUI_Calibration_sOff = uicontrol('style','toggle',...
    'HorizontalAlignment','center',...
    'Position',fGUI.*[x0_18 y0_18 size(sOff,2) size(sOff,1)],'FontSize',FS,...
    'CData',sOff,...
    'ToolTipString',...
    'Apply experimental or fitted calibration curve to exposure file?');
set(GUI_Calibration_sOff,'callback',{@SwitchForExpData});



% GUI_Advanced_...{User Interface}
% Additional variables used in the design
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Advaned variables drop down menu
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
uicontrol('Style','text','String','Adv','Position',fGUI.*[x0_19 y0_19 ddx_19 ddy_19],...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','left','FontAngle','italic');
% Select advanced variable
AdvVarPopUp =...
    {'Dwell time x { }',...
    's_i + {ds}',...
    's_f - {ds}',...
    'NPVE dwell',...
    'Shots? (all shots?)',...
    'Segment acq every',...
    'Nuclei radius (fit)',...
    'Ignore {#} points in fit',...
    'FWHM'};
% Units of advanced variables
AdvVarUnits =...
    {'[ ]',...
    '[nm]',...
    '[nm]',...
    '[ms]',...
    '[0/1]',...
    'loop',...
    '[nm]',...
    '[int]',...
    '[nm]'};
GUI_Advanced_Variables = uicontrol('Style','popupmenu',...
    'String',AdvVarPopUp,'Position',fGUI.*[x0_19+dx_19 y0_19+dy_19 ddx_19b ddy_19],...
    'BackgroundColor',UIHue,'ForegroundColor',[0.4 0.4 0.4],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center','FontAngle','italic',...
    'TooltipString',...
    sprintf('Multliplcation factor applied to all dwell times \nduring exposure file creation.'),...
    'callback',{@AdvancedVariablesEdit});

% Dwell time multiplication factor applied only to segments
% pooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
f_tDe = 1.0; %[]
GUI_Advanced_Variables_Input = uicontrol('Style','edit','String',num2str(f_tDe),...
    'Position',fGUI.*[x0_19+6.28.*dx_19 y0_19+dy_19 ddx_19 ddy_19],...
    'BackgroundColor',[1 1 1],'ForegroundColor',[1 0 0],'FontSize',FS,...
    'FontWeight','normal','HorizontalAlignment','center',...
    'callback',{@AdvancedVariablesInput});
% Units
GUI_Advanced_Variables_Units = uicontrol('style','text','String',AdvVarUnits(1),...
    'BackgroundColor',FigHue,'ForegroundColor',[1 0 0],...
    'HorizontalAlignment','left',...
    'Position',fGUI.*[x0_19+7.75.*dx_19 y0_19+dy_19 ddx_19 ddy_19],'FontSize',FS);

% Reset the current 'adv' dropdown selection to the first item in the
% dropdown menu
AdvVar = 1; %[1,2,3,...]


% UIpanel to host 3D plot zoom ...should be the last defined GUI element
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Position of UI panel
GUI_ZoomPanelPos = [625-200 zPivPlot-240 900 975];
% Axis size for 3D object when linked with the panel GUI object
xyzAxisPos = [50 50 900-100 975-100];
GUI_ZoomPanel = uipanel('Units','pixels','Position',fGUI.*GUI_ZoomPanelPos,...
    'BackgroundColor',FigHue,'Visible','off');


% Read dwell time and segment angle experimental data from file
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
LoadCalibrationFile



% Functions
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo


% GUI_UserInput_...{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
    function FileOrFolderName(~,event_data)
        % Folder name as input
        if iSituation == 1
            DesignFolderName = get(GUI_UserInput_TypeName,'String');
            SaveDesignFolderName = DesignFolderName;
            mkdir(DesignFolderName);
            set(InfoFig,'Visible','Off')
            uiresume
            % File name as input
        elseif iSituation == 2
            FleetingFileName = get(GUI_UserInput_TypeName,'String');
            set(InfoFig,'Visible','Off')
            uiresume
        end
    end

    function PressLeftButton(~,event_data)
        % Name design folder
        if iSituation == 1
            set(GUI_UserInput_LeftButton,'Visible','Off');
            set(GUI_UserInput_RightButton,'Visible','Off');
            set(GUI_UserInput_TypeName,'Visible','On');
        elseif iSituation == 3
            uiresume
            % Confirmation of CAD restart
            ReStartFEBiD_CAD
        end
    end

    function PressRightButton(~,event_data)
        % Name design folder
        if iSituation == 1
            % FEBiD CAD design folder name
            DesignFolderName = sprintf('%s_%g',PartialName,UniqueID);
            SaveDesignFolderName = DesignFolderName;
            mkdir(DesignFolderName);
            set(InfoFig,'Visible','Off')
            uiresume
        elseif iSituation == 3
            set(InfoFig,'Visible','Off')
            % Confirmation of CAD restart
            uiresume
        end
    end


% GUI_VertexDefine_...{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Edit {x} position, per VOI, in UI control
    function TypeX(GUI_VertexDefine_TypeX,event_data)
        
        % Retrieve the User-based {x} selection
        x_t = str2double(get(GUI_VertexDefine_TypeX,'string')); %[nm]
        xCube(VOI) = x_t; %[nm]
        
        % Update {x} position in {x,y} plot
        Plot_xy_Vertices(xyAxis,event_data)
        % Update {x} position in {x,y,z} plot
        Plot_xyz_Vertices(xyzAxis,event_data)
        % Update text ID in 2D & 3D plots
        TextUpdate
        % Update segment in {x,y,z}
        SegmentRevisited
        % Register new design step and save design
        UponNewAction
        % Histogram for vertex spacings
        SpacingHistogram
        % Visual and transparent patch objects for element length range
        DisplayElementForSegmentSearch
    end

% Edit {y} position, per VOI, in UI control
    function TypeY(GUI_VertexDefine_TypeY,event_data)
        
        % Retrieve the User-based {y} selection
        y_t = str2double(get(GUI_VertexDefine_TypeY,'string')); %[nm]
        yCube(VOI) = y_t; %[nm]
        
        % Update {y} position in {x,y} plot
        Plot_xy_Vertices(xyAxis,event_data)
        % Update {y} position in {x,y,z} plot
        Plot_xyz_Vertices(xyzAxis,event_data)
        % Update text ID in 2D & 3D plots
        TextUpdate
        % Update segment in {x,y,z}
        SegmentRevisited
        % Register new design step and save design
        UponNewAction
        % Histogram for vertex spacings
        SpacingHistogram
        % Visual and transparent patch objects for element length range
        DisplayElementForSegmentSearch
    end

% Edit {z} position, per VOI, in UI control
    function TypeZ(GUI_VertexDefine_TypeZ,event_data)
        
        % Retrieve the User-based {z} selection
        z_t = str2double(get(GUI_VertexDefine_TypeZ,'string')); %[nm]
        
        % Enter absolute value of {z}
        if SwitchState == false
            zCube(VOI) = z_t; %[nm]
            % Calculate {z} position based on segment angle specified
        elseif SwitchState == true
            % {x} in-focal plane displacment
            dxSeg2 = ( xCube(VOI) - xCube(iVOIAng) ).^2; %[nm]
            % {y} in-focal plane displacment
            dySeg2 = ( yCube(VOI) - yCube(iVOIAng) ).^2; %[nm]
            % {z} value converted from segment angle and the position of
            % the initial vertex for the segment
            zCube(VOI) = zCube(iVOIAng) + sqrt( (dxSeg2 +...
                dySeg2)./(cos(z_t.*pi./180).^2) - dxSeg2 - dySeg2 );% [nm]
        end
        
        % Update {z} position in {x,y} plot
        Plot_xy_Vertices(xyAxis,event_data)
        % Update {z} position in {x,y,z} plot
        Plot_xyz_Vertices(xyzAxis,event_data)
        % Update text ID in 2D & 3D plots
        TextUpdate
        % Update segment in {x,y,z}
        SegmentRevisited
        % Register new design step and save design
        UponNewAction
        % Histogram for vertex spacings
        SpacingHistogram
        % Visual and transparent patch objects for element length range
        DisplayElementForSegmentSearch
    end

% Toggle between {z} and {zeta} input for vertex height
    function ZorZeta(GUI_VertexDefine_ZorZeta,event_data)
        
        % ...only if a vertex has been defined
        if vt > 0
            
            SwitchState = logical(get(GUI_VertexDefine_ZorZeta,'Value'));
            % Segment angle specification
            if SwitchState == true
                set(GUI_VertexDefine_TypeZLabel,'String','/ [deg]',...
                    'ForegroundColor',SegmentHue);
                set(GUI_VertexDefine_TypeZ,...
                    'ForegroundColor',SegmentHue);
                set(GUI_VertexDefine_ZorZeta,'String','/',...
                    'BackgroundColor',SegmentHue);
                set(GUI_VertexDefine_iVOI,'Visible','On')
                % {z} absolute value specification
            elseif SwitchState == false
                set(GUI_VertexDefine_TypeZLabel,'String','z [nm]',...
                    'ForegroundColor',VertexHue);
                set(GUI_VertexDefine_TypeZ,...
                    'ForegroundColor',VertexHue);
                set(GUI_VertexDefine_ZorZeta,'String','+',...
                    'BackgroundColor',VertexHue);
                set(GUI_VertexDefine_iVOI,'Visible','Off')
                set(GUI_VertexDefine_TypeZ,'String',num2str(zCube(VOI))); %[nm]
            end
            
        end
        
    end

% Initial vertex used to compute the {z} value when a segment angle is
% specified in place of {z} for a vertex-of-interest
    function iVOI(GUI_VertexDefine_iVOI,event_data)
        % Initial vertex for segment calculation
        iVOIAng = str2double(get(GUI_VertexDefine_iVOI,'String'));
        if iVOIAng > vt
            iVOIAng = vt; %[idx]
            set(GUI_VertexDefine_iVOI,'String',num2str(iVOIAng));
        elseif iVOIAng < 1
            iVOIAng = 1; %[idx]
            set(GUI_VertexDefine_iVOI,'String',num2str(iVOIAng));
        end
    end

% Increase the {z} displacement increment by the fine increment
    function UpDzFine(GUI_VertexDefine_UpDzFine,event_data)
        % Automatic {z} displacement increment
        AutoDz = AutoDz + PlusDz; %[nm]
        set(GUI_VertexDefine_AutomaticDz,'String',num2str(AutoDz));
    end
% Decrease the {z} displacement increment by the fine increment
    function DownDzFine(GUI_VertexDefine_DownDzFine,event_data)
        % Automatic {z} displacement increment
        AutoDz = AutoDz - PlusDz; %[nm]
        set(GUI_VertexDefine_AutomaticDz,'String',num2str(AutoDz));
    end
% Increase the {z} displacement increment by the course increment
    function UpDzCourse(GUI_VertexDefine_UpDzCourse,event_data)
        % Automatic {z} displacement increment
        AutoDz = AutoDz + PlusPlusDz; %[nm]
        set(GUI_VertexDefine_AutomaticDz,'String',num2str(AutoDz));
    end
% Decrease the {z} displacement increment by the course increment
    function DownDzCourse(GUI_VertexDefine_DownDzCourse,event_data)
        % Automatic {z} displacement increment
        AutoDz = AutoDz - PlusPlusDz; %[nm]
        set(GUI_VertexDefine_AutomaticDz,'String',num2str(AutoDz));
    end
% Fine {z} displacement increment
    function DzFineChange(GUI_VertexDefine_DzFineChange,event_data)
        PlusDz = str2double(get(GUI_VertexDefine_DzFineChange,'String')); 
    end
% Course {z} displacement increment
    function DzCourseChange(GUI_VertexDefine_DzCourseChange,event_data)
        PlusPlusDz = str2double(get(GUI_VertexDefine_DzCourseChange,'String')); 
    end
% Activation/deactivation of the automatic {z} displacment increment
    function AutomaticDz(GUI_VertexDefine_AutomaticDz,event_data)
        % Activate automatic mode
        if AutoCalculateZ == false
            AutoCalculateZ = true; %[0/1]
            set(GUI_VertexDefine_AutomaticDz,'BackgroundColor',[0 1 0])
            % Deactivate automatic mode
        elseif AutoCalculateZ == true
            AutoCalculateZ = false; %[0/1]
            set(GUI_VertexDefine_AutomaticDz,'BackgroundColor',[1 0 0])
        end
    end
% Update the accumlated {z} value.  The next {z} value for a new vertex
% will be accumuated {zAccu} + the current increment
    function zAccumulator(GUI_VertexDefine_zAccumulator,event_data)
        zAccu = str2double(get(GUI_VertexDefine_zAccumulator,'String')); %[nm]
    end

% Identify substrate contact for vertex
    function SubstrateContact(GUI_VertexDefine_SubstrateContact,event_data)
        sCube(VOI) =...
            str2double(get(GUI_VertexDefine_SubstrateContact,'string')); %[nm]
        % Register new design step and save design
        UponNewAction
    end

% Vertices {x,y} data plot
    function Plot_xy_Vertices(~,event_data)
        % No vertex has been submitted, initialize plot
        if NoPoint_xy == true
            % Surface contact vertex (red), otherwise (green)
            Pxy = plot(xyAxis,xCube(1:vt),yCube(1:vt),'o','MarkerFaceColor',...
                [0 0.8 0],'MarkerEdgeColor',[0 0.6 0],'MarkerSize',MS_Pxy);
            NoPoint_xy = false; %[0/1]
            set(xyAxis,'NextPlot','add')
            xyBadObj = plot(xyAxis,xArtifact,yArtifact,'^',...
                'MarkerSize',MS_Artifact,'MarkerEdgeColor','r','MarkerFaceColor','y');
            % Update current plot object
        elseif NoPoint_xy == false  
            set(Pxy,'XData',xCube(1:vt),'YData',yCube(1:vt));
        end
    end

% Vertices {x,y,z} data plot
    function Plot_xyz_Vertices(~,event_data)
       % No vertex has been submitted, initialize plot
        if NoPoint_xyz == true
            % All vertices are displayed
            if HideVerts == false
                Pxyz = plot3(xyzAxis,xCube(1:vt),yCube(1:vt),zCube(1:vt),...
                    'o','MarkerFaceColor',...
                    [0 0.8 0],'MarkerEdgeColor',[0 0.6 0],'MarkerSize',MS_Pxyz);
                NoPoint_xyz = false; %[0/1]
                % Vertices not connected to a segment are hidden from view
            elseif HideVerts == true
                Pxyz = plot3(xyzAxis,xCube(v_i(1:vt)),yCube(v_i(1:vt)),zCube(v_i(1:vt)),...
                'o','MarkerFaceColor',...
                [0 0.8 0],'MarkerEdgeColor',[0 0.6 0],'MarkerSize',MS_Pxyz);
            end
            set(xyzAxis,'NextPlot','add')
            % Update current plot object
        elseif NoPoint_xyz == false
           % All vertices are displayed
            if HideVerts == false
                set(Pxyz,'XData',xCube(1:vt),'YData',yCube(1:vt),'ZData',zCube(1:vt));
                % Vertices not connected to a segment are hidden from view
            elseif HideVerts == true
                set(Pxyz,'XData',xCube(v_i(1:vt)),'YData',yCube(v_i(1:vt)),'ZData',zCube(v_i(1:vt)));
            end
            
        end
    end

% User can select vertex-of-interest to edit
    function TypeVOI(GUI_VertexDefine_TypeVOI,event_data)
        
        % Prevents attempt to access a VOI that does not exist
        VOI = str2double(get(GUI_VertexDefine_TypeVOI,'string')); %[nm]
        if VOI > vt
            VOI = vt;
            set(GUI_VertexDefine_TypeVOI,'string',num2str(VOI));
        elseif VOI < 1
            VOI = 1;
            set(GUI_VertexDefine_TypeVOI,'string',num2str(VOI));
        end
        
        % Update {x} coordinate in UI display
        str_x_t = num2str(xCube(VOI));
        % Update {y} coordinate in UI display
        str_y_t = num2str(yCube(VOI));
        % Update {z} coordinate in UI display
        str_z_t = num2str(zCube(VOI));
        
        % Update {x,y,z} coordinates in the GUI display
        UpdateXYZinGUI
        
        % Update surface digital ID in UI display
        set(GUI_VertexDefine_SubstrateContact,'String',num2str(sCube(VOI))); %[0/1]
    end

% Called when a new vertex is placed using the mouse in the (x,y) axes
    function NewVertex(~,event_data)
        
        % {i}: User defines a vertex
        xyzMouse = get(xyAxis,'CurrentPoint'); %[nm]
        % Vertex defined
        xCube(nv) = xyzMouse(1,1);   yCube(nv) = xyzMouse(1,2); %[nm]
        
        % {z} coordinate
        if AutoCalculateZ == true
            % Accumulating {z} value
            zAccu = zAccu + AutoDz; %[nm]
            zCube(nv) = zAccu; %[nm]
            
            set(GUI_VertexDefine_zAccumulator,'String',num2str(zAccu));
        end
        
        % Next vertex
        nv = nv + 1; %[1,2,3,...]
        % Number of vertices
        vt = vt + 1; %[idx]
        % Voxel-of-interest
        VOI = vt; %[idx]
        
        % Display new vertex
        set(GUI_VertexDefine_VertexNumber,'String',num2str(vt));
        
        % {x} position display
        str_x_t = num2str(xyzMouse(1,1)); %[s]
        % {y} position display
        str_y_t = num2str(xyzMouse(1,2)); %[s]
        % {z}; default is 0 displayed
        str_z_t = num2str(zCube(VOI)); %[s]
        
        % Update {x,y,z} coordinates in the GUI display
        UpdateXYZinGUI
        
        % Substrate contact; default no contact
        set(GUI_VertexDefine_SubstrateContact,'String',num2str(0)) %[0/1]
        
        % {x,y} plot
        Plot_xy_Vertices(xyAxis,event_data) %[@]
        % {x.y.z} plot
        Plot_xyz_Vertices(xyzAxis,event_data) %[@]
        % Vertex-of-Interest display updated
        set(GUI_VertexDefine_TypeVOI,'String',num2str(VOI))
        
        axes(xyAxis)
        % Visual index label for {x,y} point
        Pobj_xy_t(VOI) = text(xCube(VOI)+ShiftText,yCube(VOI),num2str(VOI)); %[str]
        
        axes(xyzAxis)
        % Visual index label for {x,y,z} point
        Pobj_xyz_t(VOI) = text(xCube(VOI)+ShiftText,yCube(VOI),zCube(VOI),num2str(VOI)); %[str]

        % Register new design step and save design
        UponNewAction
        % Histogram for vertex spacings
        SpacingHistogram
        % Visual and transparent patch objects for element length range
        DisplayElementForSegmentSearch
    end

% Change camera position in the 3D view
    function View3D(~,event_data)
        % Sample azimuthal input
        aza = str2double(get(GUI_VertexDefine_Azimuthal,'string')); %[nm]
        % Sample elevation input
        ele = str2double(get(GUI_VertexDefine_Elevation,'string')); %[nm]
        % Current axes = 3D plot
        axes(xyzAxis)
        % Update the view of the 3D plot
        view(aza,ele)
    end

% Activate/deactivate the mouse enabled 3D camera
    function Go3D(GUI_VertexDefine_Go3D,event_data)
        
        % Current state of the toggle switch
        Tog3DCam = logical(get(GUI_VertexDefine_Go3D,'Value'));
        
        % ...Camera motion active
        if Tog3DCam == true
            set(InActObj,'Enable','On');
            set(GUI_VertexDefine_Go3D,'CData',sOn);
            % Camera motion deactivated
        elseif Tog3DCam == false
            set(InActObj,'Enable','Off');
            set(GUI_VertexDefine_Go3D,'CData',sOff);
        end
        
        [aza,ele] = view;
        % Update azimuthal text box
        set(GUI_VertexDefine_Azimuthal,'String',num2str(aza))
        % Update elevation text box
        set(GUI_VertexDefine_Elevation','String',num2str(ele))
        
    end

% Change axes limits in both 2D & 3D plots
    function AxesLimits(~,event_data)
        
        % Reset all 2D & 3D plotting limits
        xMin = str2double(get(GUI_VertexDefine_xMin,'string')); %[nm]
        xMax = str2double(get(GUI_VertexDefine_xMax,'string')); %[nm]
        yMin = str2double(get(GUI_VertexDefine_yMin,'string')); %[nm]
        yMax = str2double(get(GUI_VertexDefine_yMax,'string')); %[nm]
        zMin = str2double(get(GUI_VertexDefine_zMin,'string')); %[nm]
        zMax = str2double(get(GUI_VertexDefine_zMax,'string')); %[nm]
        
        % Text labels for 2D and 3D plots are shifted along the {x} axis
        % and scaled with respect to the extent of the x-axis in order than
        % no overlap will exist between the vertex and its text label
        ShiftText = dText.*(xMax - xMin); %[points]
        
        axes(xyAxis)
        axis([xMin xMax yMin yMax]);
        axes(xyzAxis)
        axis([xMin xMax yMin yMax zMin zMax]);
    end

% Auto-calculate the correct axes limits.  The auto-detection scheme is
% based on an increment of {AutoAxisIncrment}
    function AxesFind(~,event_data)
        
        % Increment of axis auto scaling
        AutoAxisIncrement = 100; %[nm]
        
        % Center 3D object in  {xy-plane}
        Cxy
        
        % Auto-detect (x/y) maximum
        xyAxMax = AutoAxisIncrement .*...
            ceil( max([abs(xCube(1:vt)) abs(yCube(1:vt))])./AutoAxisIncrement  ) +...
            AutoAxisIncrement ; %[n*{AutoAxisIncrement} nm]
        % Auto-detect (z) maximum
        zAxMax = AutoAxisIncrement .*...
            ceil( max(abs(zCube(1:vt)))./AutoAxisIncrement  ) +...
            AutoAxisIncrement ; %[n*{AutoAxisIncrement} nm]
        
        % Reset the axes
        xMin = -xyAxMax;   xMax = xyAxMax; %[nm]
        yMin = xMin;   yMax = xMax; %[nm]
        zMin = 0;   zMax = zAxMax; %[nm]
        
        % Change axes limits in both 2D & 3D plots
        % Reset all 2D & 3D plotting limits
        set(GUI_VertexDefine_xMin,'String',num2str(xMin)); %[nm]
        set(GUI_VertexDefine_xMax,'String',num2str(xMax)); %[nm]
        set(GUI_VertexDefine_yMin,'String',num2str(yMin)); %[nm]
        set(GUI_VertexDefine_yMax,'String',num2str(yMax)); %[nm]
        set(GUI_VertexDefine_zMin,'String',num2str(zMin)); %[nm]
        set(GUI_VertexDefine_zMax,'String',num2str(zMax)); %[nm]
        
        axes(xyAxis)
        axis([xMin xMax yMin yMax]);
        axes(xyzAxis)
        axis([xMin xMax yMin yMax zMin zMax]);
        
    end

% Refresh the vertices and segments in 2D and 3D.  Axes are cleared and
% vertices and segments replotted.  Inefficient, will be changed later.
    function ReRender(~,event_data)
        
        % Clear current {xy} and {xyz} axes
        cla(xyAxis);  cla(xyzAxis);
        
        % Render past {x,y} vertices
        axes(xyAxis);
        set(xyAxis,'NextPlot','add');
        Pxy = plot(xyAxis,xCube(1:vt),yCube(1:vt),'o','MarkerFaceColor',...
            [0 0.8 0],'MarkerEdgeColor',[0 0.6 0],'MarkerSize',MS_Pxy);
        
        % Render artifact dwell points {x,y}
        xyBadObj = plot(xyAxis,xArtifact,yArtifact,'^',...
            'MarkerSize',MS_Artifact,'MarkerEdgeColor','r','MarkerFaceColor','y');
        
        % Render past {x,y,z} vertices
        axes(xyzAxis);
        set(xyzAxis,'NextPlot','add');
        % All vertices are plotted
        if HideVerts == false
            Pxyz = plot3(xyzAxis,xCube(1:vt),yCube(1:vt),zCube(1:vt),...
                'o','MarkerFaceColor',...
                [0 0.8 0],'MarkerEdgeColor',[0 0.6 0],'MarkerSize',MS_Pxy);
            % Vertices that segment components are plotted, unused vertices
            % are hidden
        elseif HideVerts == true
            Pxyz = plot3(xyzAxis,xCube(v_i(1:vt)),yCube(v_i(1:vt)),zCube(v_i(1:vt)),...
            'o','MarkerFaceColor',...
            [0 0.8 0],'MarkerEdgeColor',[0 0.6 0],'MarkerSize',MS_Pxyz);
        end
        
        % Render past {x,y} text labels
        axes(xyAxis)
        % ...current vertices
        for n=1:vt
            % Visual index label for {x,y} point
            Pobj_xy_t(n) =...
                text(xCube(n)+ShiftText,yCube(n),num2str(n),'Clipping','on'); %[str]
        end
        
        % Render past {x,y,z} text labels
        axes(xyzAxis)
        % ...current vertices
        for n=1:vt
            % ...all vertices is selected OR a vertex is part of a segment
            if HideVerts == false || v_i(n) == 1
                % ..remeshing hasn't yet taken place OR vertex index falls
                % within currently selected remesh history
                if idx_Re == 0 ||  n <= v_i_2D(idx_Re)
                    % Visual index label for {x,y,z} point
                    Pobj_xyz_t(n) =...
                        text(xCube(n)+ShiftText,yCube(n),zCube(n),num2str(n),'Clipping','on'); %[str]
                end
            end
        end
        
        % Render past 3D object segments
        nSeg_t = 0; %[1,2,3,...]
        for n=1:MaxExposureLevel
            for m=1:n_e(n)
                % Unique object index for segment
                nSeg_t = nSeg_t + 1; %[1,2,3,...]
                % Plot segment
                Pobj_Segments(nSeg_t) = plot3(xyzAxis,...
                    [xCube(s_i(n,m)) xCube(s_f(n,m))],...
                    [yCube(s_i(n,m)) yCube(s_f(n,m))],...
                    [zCube(s_i(n,m)) zCube(s_f(n,m))],'-','Color',...
                    iMap(n,:),'LineWidth',2);
                % Segment indices record
                Pobj_Segments_idxs(1,nSeg_t) = s_i(n,m); %[idx]
                Pobj_Segments_idxs(2,nSeg_t) = s_f(n,m); %[idx]
            end
        end
        
    end

% Which vertices should be currently displayed in both the 2D and 3D plots?
    function VisVerts(GUI_VertexDefine_VisVerts,event_data)
        % {HideVerts = 0} shows all vertices or {HideVerts = 1} shown only
        % those included in defined elements
        HideVerts = logical(get(GUI_VertexDefine_VisVerts,'Value')); %[0/1]
        if HideVerts == false
            set(GUI_VertexDefine_VisVerts,...
                'ForeGroundColor','w','BackgroundColor',VertexHue);
        elseif HideVerts == true
            set(GUI_VertexDefine_VisVerts,...
                'ForeGroundColor',[0.3 0.3 0.3],'BackgroundColor','k');
        end
        % Visible vertices
        VisibleVertices
        % Refresh the vertices and segments in 2D and 3D
        ReRender
    end

% Detection of vertices that are connected by exposure elements
% "pillars/segments"
    function VisibleVertices(~,event_data)
        
        % Vertices present in segments
        temp = unique( nonzeros( [unique(s_i)' unique(s_f)'] )); %[idx]
        % Reset reveal/hide vertex vector
        v_i(1:vt) = false; %[idx]
        % Reassign reveal/hide vertex vector
        v_i(temp) = true; %[idx]
        
    end

% Update text ID in both plots
    function TextUpdate(~,event_data)
        set(Pobj_xy_t(VOI),'Position',fGUI.*[xCube(VOI)+ShiftText yCube(VOI)])
        set(Pobj_xyz_t(VOI),...
            'Position',fGUI.*[xCube(VOI)+ShiftText yCube(VOI) zCube(VOI)])
    end

% Histogram for vertex spacings
    function SpacingHistogram(~,event_data)
        
        % At least two vertices should exist
        if vt > 1
            
            % Histogram (reset)
            Io1D(:) = 0; %[1,2,3,...]
            % Spacing number
            nIdx = 0; %[1,2,3,...]
            % ...per (x,y,z)
            for a=1:(vt-1)
                % ...per (x,y,z)
                for b=(a+1):vt
                    
                    % All unique vertex spacings registered for automatic
                    % segment detection
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    % Current vertex spacing identifier
                    nIdx = nIdx + 1; %[1,2,3,...]
                    % Segment spacing
                    Lxyz(nIdx,3) = sqrt( (xCube(a) - xCube(b)).^2 +...
                        (yCube(a) - yCube(b)).^2 +...
                        (zCube(a) - zCube(b)).^2 ); %[nm]
                    % Sort initial and final segment vertex based on the
                    % such that the coordinate with in the minimum {z} is
                    % the initial segment index
                    Lxyz(nIdx,1) = a; %[idx]
                    Lxyz(nIdx,2) = b; %[idx]
                    if zCube(a) > zCube(b)
                        Lxyz(nIdx,1) = b; %[idx]
                        Lxyz(nIdx,2) = a; %[idx]
                    end
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    
                    % Segment spacing (index)
                    idxS = round( (Lxyz(nIdx,3) - dLam)./dLam ) + 1; %[1,2,3,...]
                    % Segment spacing minimum & maximum check
                    if idxS > 0 && idxS < length(Io1D)
                        % Histogram update
                        Io1D(idxS) = Io1D(idxS) + 1; %[1,2,3,...]
                    end
                end
            end
            
            % Histogram plot (update)
            axes(izAxis)
            % Axis control for {izAxis} before histogram exists
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            if max(Io1D) == 0
                axis([0 1 0 zMax]);
            else
                set(izAxis,'XTick',[]);
                axis([0 max(Io1D) 0 zMax]);
            end
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % Histogram bar intensity update
            for a=1:length(Seg1D)
                set(Obj_Hist(a),'XData',[0 Io1D(a) Io1D(a) 0])
            end
            
        end
        
    end

% File name UI control for vertex and segment data upload
    function VertexDataFileName(GUI_VertexDefine_VertexDataFileName,event_data) %#ok<*INUSD>
        ImportFileName = get(GUI_VertexDefine_VertexDataFileName,'string'); %[str]
    end

% Load coordinate list from a text file and add these coordinates to the
% current CAD pattern
    function LoadVertexCoordinates(GUI_VertexDefine_LoadVertexCoordinates,event_data)
        
        ActionFileName = sprintf('%s.txt',ImportFileName);
        % Data import from text file
        New_xyz = dlmread(ActionFileName); %[nm]
        
        % Number of new vertices
        NewPoints = size(New_xyz,1); %[1,2,3,...]
        
        if NewPoints > 0
            
            for v=1:NewPoints
                % New vertex
                vt  = vt + 1; %[1,2,3,...]
                % New {x} coordinate
                xCube(vt) = New_xyz(v,1); %[nm]
                % New {y} coordinate
                yCube(vt) = New_xyz(v,2); %[nm]
                % New {z} coordinate
                zCube(vt) = New_xyz(v,3); %[nm]
            end
            
            set(GUI_VertexDefine_TypeVOI,'String',num2str(vt));
            set(GUI_VertexDefine_VertexNumber,'String',num2str(vt));
            
            % Set vertex-of-interest to the maximum vertex following upload
            VOI = vt; %[idx]
            % Next vertex to be defined
            nv = vt + 1; %[idx]
            
            % Update {x,y,z} coordinates in the GUI display
            % Update {x} coordinate in UI display
            str_x_t = num2str(xCube(VOI));
            % Update {y} coordinate in UI display
            str_y_t = num2str(yCube(VOI));
            % Update {z} coordinate in UI display
            str_z_t = num2str(zCube(VOI));
            
            % Update {x,y,z} coordinates in the GUI display
            UpdateXYZinGUI
            
            % Auto-set axes
            AxesFind
            % Refresh the vertices and segments in 2D and 3D
            ReRender
            % Register new design step and save design
            UponNewAction
            % Histogram for vertex spacings
            SpacingHistogram
            % Visual and transparent patch objects for element length range
            DisplayElementForSegmentSearch
        end
    end

% Save (1) current list of vertices + (2) the current segment design
    function ExportVertsExportSegs(GUI_VertexDefine_SaveCAD,event_data)
        
        % Advance the unique text file identifier
        i_xPort = i_xPort + 1; %[int]
        cd(SupportingFilesFolderName)
        save uID UniqueID i_xPort
        cd ../
        
        % Step #1: Export FEBiD CAD vertices
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        if vt > 0
            VertsFileName = sprintf('xPort_Verts_%g.txt',i_xPort);
            dlmwrite(VertsFileName,[xCube(1:vt)' yCube(1:vt)' zCube(1:vt)'],'\t');
            cd(DesignFolderName)
            dlmwrite(VertsFileName,[xCube(1:vt)' yCube(1:vt)' zCube(1:vt)'],'\t');
            cd ../
        end
        
        % Step #2: Export FEBiD CAD segments
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        if nSeg > 0
            xPort(:,:) = 0; %[idx]
            % Initialize column position index
            n_2 = 1; %[1,2,3,...]
            for v=1:MaxExposureLevel
                % Initial segment vertices for level #{v}
                xPort(1:n_e(v),n_2) = s_i(v,1:n_e(v)); %[idx]
                % Final segment vertices for level #{v}
                xPort(1:n_e(v),round(n_2+1)) = s_f(v,1:n_e(v)); %[idx]
                % Column position index
                n_2 = n_2 + 2; %[1,2,3,...]
            end
            SegsFileName = sprintf('xPort_Segs_%g.txt',i_xPort);
            dlmwrite(SegsFileName,xPort(1:max(n_e),1:round(2.*MaxExposureLevel)),'\t');
            cd(DesignFolderName)
            dlmwrite(SegsFileName,xPort(1:max(n_e),1:round(2.*MaxExposureLevel)),'\t');
            cd ../
        end
        
    end

% Update {x,y,z} coordinates in the GUI display text input boxes
    function UpdateXYZinGUI(~,event_data)
        
        % Update {x} coordinate in UI display
        set(GUI_VertexDefine_TypeX,'String',str_x_t); %[nm]
        % Update {y} coordinate in UI display
        set(GUI_VertexDefine_TypeY,'String',str_y_t); %[nm]
        % Update {z} coordinate in UI display
        set(GUI_VertexDefine_TypeZ,'String',str_z_t); %[nm]
    end


% GUI_VertexCopy_...{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Vertex string read from 'vertex list', where commas, spaces and dashes
% may be used, and converted in to numerical format
    function VertexRange(GUI_VertexCopy_VertexRange,event_data)
        
        % Vertices
        vRange = get(GUI_VertexCopy_VertexRange,'string'); %[1,2,3,...]
        
        % Vertex list converted from a string into a vector of numerals
        % {vRange}
        ReadString
        
        % Unique and range bound vertices determined
        vRange = unique(vRange); %[idx]
        vRange = 0.*(vRange < 1) + vt.*(vRange > vt) +...
            vRange.*(vRange >= 1 & vRange <= vt); %[idx]
        
    end

% Highlight the vertex list when a GUI function is executed that calls the
% list
    function FlashVertexList(~,event_data)
        % Yellow highlight of GUI element background color for {FlashFor}
        % seconds.  This reminds the User when a function is executed that
        % requires 'vertex list' input
        FlashFor = 1; %[s]
        set(GUI_VertexCopy_VertexRange,'BackgroundColor','y');
        pause(0.001)
        tic
        while toc < FlashFor
        end
        set(GUI_VertexCopy_VertexRange,'BackgroundColor',UIHue)
    end

% String of vertices converted to base 10 numerals
    function ReadString(~,event_data)
        
        % Index of number/number range
        StrIdx = 1; %[idx]
        % Current number/number range storage
        MultiDigit = [0; 0]; %[idx]
        % Current number/number range
        nrIdx = 1; %[idx]
        % Array of number/number ranges
        Rng1D = zeros(100,2); %[idx]
        % Number/number range position in {MultiDigit}
        cIdx = 1; %[idx]
        % Numbers in base 10
        tString = '1234567890';
        
        % Number/number range indicator
        NumOn = 0; %[0/1]
        
        % ...string
        while StrIdx <= length(vRange)
            
            % Reset number find trigger
            NumberFound = 0; %[0/1]
            
            % ...all possible numbers in base 10
            for m=1:10
                % number found in string
                if strcmp(vRange(StrIdx),tString(m))
                    
                    % Number is detected
                    NumberFound = 1; %[0/1]
                    
                    % No digits currently in memory
                    if NumOn == 0
                        % New digit detected
                        MultiDigit(1) = StrIdx; %[1,2,3,...]
                        NumOn = 1; %[0/1]
                        % Building number > 10
                    elseif NumOn == 1
                        % Advance order of magnitude
                        MultiDigit(2) = StrIdx; %[1,2,3,...]
                    end
                end
            end
            
            % Complete whole number detected
            if NumberFound == 0 || StrIdx == length(vRange)
                % Complete current number
                if NumOn == 1
                    if MultiDigit(2) > 0
                        % Number range input
                        Rng1D(nrIdx,cIdx) = str2double(vRange(MultiDigit(1):MultiDigit(2))); %[]
                    else
                        % Single number input
                        Rng1D(nrIdx,cIdx) = str2double(vRange(MultiDigit(1))); %[]
                    end
                    % Reset the multi-digit detector
                    MultiDigit(:) = 0; %[1,2,3,...]
                    NumOn = 0; %[0/1]
                    
                    % New number/number range
                    nrIdx = nrIdx + 1; %[1,2,3,...]
                    % Reset to number, not range
                    cIdx = 1; %[1/2]
                end
            end
            
            % Range format detected in the input
            if vRange(StrIdx) == '-'
                % Number range detected in string
                cIdx = 2; %[1/2]
                % Remain at current number range index
                nrIdx = nrIdx - 1; %[1/2]
            end
            % Advance to the next character
            StrIdx = StrIdx + 1; %[1,2,3,...]
        end
        
        % Number of numbers/number ranges
        nrIdx = nrIdx -1; %[idx]
        
        % Vector of vertex indices
        vIdx1D = zeros(100,1); %[idx]
        
        % Creation of vector of vertex indices from {MultiDigit}
        ndx = 0; %[idx]
        % ...number/number range
        for m=1:nrIdx
            % number detected
            if Rng1D(m,2) == 0
                ndx = ndx + 1;
                vIdx1D(ndx) = Rng1D(m,1); %[idx]
                % number range detected
            else
                vIdx1D((ndx+1):(ndx+1+(Rng1D(m,2)-Rng1D(m,1)))) =...
                    Rng1D(m,1):Rng1D(m,2); %[idx]
                % Number of vertices specified in the string
                ndx = ndx + (Rng1D(m,2)-Rng1D(m,1)) + 1; %[idx]
            end
        end
        % Vector of vertices
        vRange = vIdx1D(1:ndx); %[idx]
    end

% Initial vertex for segment compensation that defines the linear span over
% which to apply segment compensation
    function VertexRefForComp(GUI_SegmentCompensation_VertexRefForComp,event_data)
        
        % Current edge initial index
        vNow = str2double(get(GUI_SegmentCompensation_VertexRefForComp,'string')); %[1,2,3,...]
        % Vertex # constraints applied in the form of minimum and maximum
        % values
        VertexConstraints
        % Advance the global index number
        vComp = vNow; %[idx]
        % Set initial edge index
        set(GUI_SegmentCompensation_VertexRefForComp,'String',num2str(vComp));
        
    end

% Rate of change of the segment angle versus dwell time
    function SegComp(GUI_SegmentCompensation_SegComp,event_data)
        % Segment angle change as a function of distance along the length
        % of a segment projected in the focal plane 
        dZeta_ds = str2double(get(GUI_SegmentCompensation_SegComp,'string')); %[deg/nm]
    end

% Final vertex for segment compensation that defines the linear span over
% which to apply segment compensation
    function VertexRefForComp_f(GUI_SegmentCompensation_VertexRefForComp_f,event_data)
        
        % Current edge initial index
        vNow = str2double(get(GUI_SegmentCompensation_VertexRefForComp_f,'string')); %[1,2,3,...]
        % Vertex # constraints applied
        VertexConstraints
        % Advance the global index number
        vComp_f = vNow; %[idx]
        % Set initial edge index
        set(GUI_SegmentCompensation_VertexRefForComp_f,'String',num2str(vComp_f));
    end

    function TransferVertices(GUI_SegmentCompensation_TransferVertices,event_data)
        
        % Vertices lying along a linear element spanning vertices {i} and
        % {f}; the variables {vComp} and {vComp_f}
        vRangeDetect = zeros(1,100); %[idx]
        % vertex detection index
        m = 0; %[idx]
        % ...per vertex
        if vt > 0 && vComp ~= vComp_f
            
            % Partial slope y(x)
            dydx = (yCube(vComp_f) - yCube(vComp))./...
                (xCube(vComp_f) - xCube(vComp)); %[nm/nm]
            % Partial slope z(x)
            dzdx = (zCube(vComp_f) - zCube(vComp))./...
                (xCube(vComp_f) - xCube(vComp)); %[nm/nm]
            
            % ...vertices
            for n=1:vt
                % {y} guess
                yGuess = dydx.*...
                    xCube(n) + (yCube(vComp) - dydx.*xCube(vComp)); %[nm]
                % {z} guess
                zGuess = dzdx.*...
                    xCube(n) + (zCube(vComp) - dzdx.*xCube(vComp)); %[nm]
                
                % Remeshed vertex lies along the element of interest
                if abs(yGuess - yCube(n)) < ds && abs(zGuess - zCube(n)) < ds &&...
                        yGuess >= min([yCube(vComp) yCube(vComp_f)]) &&...
                        yGuess <= max([yCube(vComp) yCube(vComp_f)]) &&...
                        zGuess >= min([zCube(vComp) zCube(vComp_f)]) &&...
                        zGuess <= max([zCube(vComp) zCube(vComp_f)])
                    % Vertex resting on a line between {i} and {f} detected
                    m = m + 1; %[idx]
                    % Register new vertex
                    vRangeDetect(m) = n; %[idx]
                end
                
            end
            
            % Default text string used for creating the vertex list
            DCS = 'This is the default character string for determining vertices positioned along the remeshed element.';
            % Index in vertex list 'string'
            cPos = 0; %[idx]
            % Index into {vRangeDetect}
            n = 1; %[idx]
            % Vertices inserted as strings into vertex list
            [cPos,DCS] = Digit2String(cPos,DCS,vRangeDetect(n)); %[s]
            % ...for all vertices found {m}
            while n < m
                % ...per vertex analysis
                n = n + 1; %[idx]
                % ...continuous string detected
                if round(vRangeDetect(n-1) + 1) == vRangeDetect(n)
                    cPos = cPos + 1; %[s]
                    DCS(cPos) = '-'; %[s]
                    % established continuous range of vertices
                    while round(vRangeDetect(n-1) + 1) == vRangeDetect(n)
                        n = n + 1; %[idx]
                    end
                    n = n - 1; %[idx]
                    % Vertices inserted as strings into vertex list
                    [cPos,DCS] = Digit2String(cPos,DCS,vRangeDetect(n)); 
                    
                else
                    cPos = cPos + 1; %[s]
                    DCS(cPos) = ','; %[s]
                    % Vertices inserted as strings into vertex list
                    [cPos,DCS] = Digit2String(cPos,DCS,vRangeDetect(n)); 
                    
                end
                
            end
            % Vertex list update in GUI element
            set(GUI_VertexCopy_VertexRange,'String',DCS(1:cPos));
            % Vertex list update in number form
            vRange = vRangeDetect(1:m); %[idx]
        end
        
    end

% String elements required to convert an integer into a string element
    function [A,B] = Digit2String(A,B,C)
        
        idxChar = length(num2str(C));
        A = A + idxChar; %[idx]
        if idxChar == 1
            B(A) = num2str(C); %[s]
        elseif idxChar > 1
            B((A-(idxChar-1)):A) = num2str(C); %[s]
        end
        
    end


% Low angle segment compensation function application
    function GoSegComp(GUI_SegmentCompensation_GoSegComp,event_data)
        
        % Segment compensation will only execute if the {ReMesh} function
        % has been executed at least once
        if idx_ReMax > 0
            
            % 'Vertex List' text input box flashes yellow
            FlashVertexList
            
            % In-focal-plane segment length
            R_ip = sqrt( ( xCube(vComp_f) - xCube(vComp) ).^2 +...
                ( yCube(vComp_f) - yCube(vComp) ).^2 ); %[nm]
            % Sort the vertices in order of their length from {vComp}
            [~,iSeg] = sort( ( xCube(vRange) - xCube(vComp) ).^2 +...
                ( yCube(vRange) - yCube(vComp) ).^2 ); %[idx]
            vRange = vRange(iSeg); %[nm]
            
            % Remove the initial vertex in the case that the User of the
            % program provides the initial vertex in the vertex list.  The
            % {for} loop below will not work if the initial vertex is provided
            % in the vertex list.
            if vRange(1) == vComp
                vRange = vRange(2:length(vRange)); %[nm]
            end
            
            % Current segment angle for specified vertices
            Zeta_temp = atan( abs(zCube(vComp_f) - zCube(vComp))./R_ip ); %[rad]
            
            % ...compensation application per vertex
            for p=1:length(vRange)
                
                % New vertex
                vt  = vt + 1; %[1,2,3,...]
                
                % Replicate {x} & {y} position of current vertex for the newly
                % created vertex
                xCube(vt) = xCube(vRange(p));   yCube(vt) = yCube(vRange(p)); %[nm]
                
                % New {z} position of new vertex
                zCube(vt) = zCube(vComp) + tan( Zeta_temp + dZeta_ds.*(pi./180).*...
                    sqrt( ( xCube(vRange(p)) - xCube(vComp) ).^2 +...
                    ( yCube(vRange(p)) - yCube(vComp) ).^2 ) ).*...
                    sqrt( ( xCube(vRange(p)) - xCube(vComp) ).^2 +...
                    ( yCube(vRange(p)) - yCube(vComp) ).^2 ); %[nm]
                
                % Reassign the vertices for the old segment using the vertices
                % with applied compensation
                if p == 1
                    iSeg = find( s_i == vComp & s_f == vRange(1) ); %[idx]
                    if isempty(iSeg) == 0
                        s_i(iSeg) = vComp;   s_f(iSeg) = vt; %[idx]
                    end
                else
                    iSeg = find( s_i == vRange(p-1) & s_f == vRange(p) ); %[idx]
                    if isempty(iSeg) == 0
                        s_i(iSeg) = vt - 1;   s_f(iSeg) = vt; %[idx]
                    end
                end
                
                % Substrate contact identifier
                sCube(vt) = sCube(vRange(p)); %[0/1]
                
            end
            
            % New, maximum number of vertices
            set(GUI_VertexDefine_TypeVOI,'String',num2str(vt));
            set(GUI_VertexDefine_VertexNumber,'String',num2str(vt));
            
            % New vertex-of-interest
            VOI = vt; %[idx]
            % Number of vertices + 1
            nv = vt + 1; %[idx]
            
            % Update {x} coordinate in UI display
            str_x_t = num2str(xCube(VOI));
            % Update {y} coordinate in UI display
            str_y_t = num2str(yCube(VOI));
            % Update {z} coordinate in UI display
            str_z_t = num2str(zCube(VOI));
            
            % Update {x,y,z} coordinates in the GUI display
            UpdateXYZinGUI
            
            % Update {s} switch in UI display
            set(GUI_VertexDefine_SubstrateContact,...
                'String',num2str(sCube(VOI))); %[nm]
            
            % Visible vertices
            VisibleVertices
            % Refresh the vertices and segments in 2D and 3D
            ReRender
            % Register new design step and save design
            UponNewAction
            % Histogram for vertex spacings
            SpacingHistogram
            % Visual and transparent patch objects for element length range
            DisplayElementForSegmentSearch
            
        end
        
    end



% Will an {x} shift be applied during duplication of vertices?
    function SwitchForDxShift(GUI_VertexCopy_SwitchForDxShift,event_data)
        DxShift_Trig = get(GUI_VertexCopy_SwitchForDxShift,'value'); %[1,2,3,...]
        if DxShift_Trig == 1
            set(GUI_VertexCopy_DxShift,'Style','edit','BackgroundColor',UIHue);
        elseif DxShift_Trig == 0
            set(GUI_VertexCopy_DxShift,'Style','text','BackgroundColor',FigHue);
        end
    end
% Enter the {x} shift value
    function DxShift(GUI_Vertex_Copy,event_data)
        sdx = str2double(get(GUI_VertexCopy_DxShift,'string')); %[1,2,3,...]
    end
% Select mirror function for {x} coordinate
    function SignForDxShift(GUI_VertexCopy_SignForDxShift,event_data)
        DxShift_Sign = get(GUI_VertexCopy_SignForDxShift,'value'); %[1,2,3,...]
    end

% Will an {y} shift be applied during duplication of points?
    function SwitchForDyShift(GUI_VertexCopy_SwitchForDyShift,event_data)
        DyShift_Trig = get(GUI_VertexCopy_SwitchForDyShift,'value'); %[1,2,3,...]
        if DyShift_Trig == 1
            set(GUI_VertexCopy_DyShift,'Style','edit','BackgroundColor',UIHue);
        elseif DyShift_Trig == 0
            set(GUI_VertexCopy_DyShift,'Style','text','BackgroundColor',FigHue);
        end
    end
% Enter the {y} shift value
    function DyShift(GUI_VertexCopy_DyShift,event_data)
        sdy = str2double(get(GUI_VertexCopy_DyShift,'string')); %[1,2,3,...]
    end
% Select mirror function for {y} coordinate
    function SignForDyShift(GUI_VertexCopy_SignForDyShift,event_data)
        DyShift_Sign = get(GUI_VertexCopy_SignForDyShift,'value'); %[1,2,3,...]
    end

% Will an {z} shift be applied during duplication of points?
    function SwitchForDzShift(GUI_VertexCopy_SwitchForDzShift,event_data)
        DzShift_Trig = get(GUI_VertexCopy_SwitchForDzShift,'value'); %[1,2,3,...]
        if DzShift_Trig == 1
            set(GUI_VertexCopy_DzShift,'Style','edit','BackgroundColor',UIHue);
        elseif DzShift_Trig == 0
            set(GUI_VertexCopy_DzShift,'Style','text','BackgroundColor',FigHue);
        end
    end
% Enter the {z} shift value
    function DzShift(GUI_VertexCopy_DzShift,event_data)
        sdz = str2double(get(GUI_VertexCopy_DzShift,'string')); %[1,2,3,...]
    end
% Select mirror function for {z} coordinate
    function SignForDzShift(GUI_VertexCopy_SignForDzShift,event_data)
        DzShift_Sign = get(GUI_VertexCopy_SignForDzShift,'value'); %[1,2,3,...]
    end

% Active duplication of {x,y,z} coordinates
    function Duplicate(GUI_Duplicate,event_data)
        
        % 'Vertex List' text input box flashes yellow
        FlashVertexList
        
        % Number of new vertices
        NewPoints = length(vRange); %[1,2,3,...]
        
        if NewPoints > 0
            
            % Shift & Sign Operations
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            for v=1:NewPoints
                % New vertex
                vt  = vt + 1; %[1,2,3,...]
                
                if DxShift_Sign == 1
                    xCube(vt) = -xCube(vRange(v)); %[nm]
                    xCube(vt) = xCube(vt) +...
                        (DxShift_Trig > 0).*sdx; %[nm]
                elseif DxShift_Sign == 0
                    xCube(vt) = xCube(vRange(v)) +...
                        (DxShift_Trig > 0).*sdx; %[nm]
                end
                
                if DyShift_Sign == 1
                    yCube(vt) = -yCube(vRange(v)); %[nm]
                    yCube(vt) = yCube(vt) +...
                        (DyShift_Trig > 0).*sdy; %[nm]
                elseif DyShift_Sign == 0
                    yCube(vt) = yCube(vRange(v)) +...
                        (DyShift_Trig > 0).*sdy; %[nm]
                end
                
                if DzShift_Sign == 1
                    zCube(vt) = -zCube(vRange(v)); %[nm]
                    zCube(vt) = zCube(vt) +...
                        (DzShift_Trig > 0).*sdz; %[nm]
                elseif DzShift_Sign == 0
                    zCube(vt) = zCube(vRange(v)) +...
                        (DzShift_Trig > 0).*sdz; %[nm]
                end
                
                % Substrate contact identifier
                sCube(vt) = sCube(vRange(v)); %[0/1]
                
            end
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            
            % New, maximum number of vertices
            set(GUI_VertexDefine_TypeVOI,'String',num2str(vt));
            set(GUI_VertexDefine_VertexNumber,'String',num2str(vt));
            
            % New vertex-of-interest
            VOI = vt; %[idx]
            % Number of vertices + 1
            nv = vt + 1; %[idx]
            
            % Update {x} coordinate in UI display
            str_x_t = num2str(xCube(VOI));
            % Update {y} coordinate in UI display
            str_y_t = num2str(yCube(VOI));
            % Update {z} coordinate in UI display
            str_z_t = num2str(zCube(VOI));
            
            % Update {x,y,z} coordinates in the GUI display
            UpdateXYZinGUI
            
            % Update {s} switch in UI display
            set(GUI_VertexDefine_SubstrateContact,...
                'String',num2str(sCube(VOI))); %[nm]
            
            % Refresh the vertices and segments in 2D and 3D
            ReRender
            % Register new design step and save design
            UponNewAction
            % Histogram for vertex spacings
            SpacingHistogram
            % Visual and transparent patch objects for element length range
            DisplayElementForSegmentSearch
        end
    end

% Active shift of {x,y,z} coordinates
    function Shift(GUI_Shift,event_data)
        
        % 'Vertex List' text input box flashes yellow
        FlashVertexList
        
        % Shift {x} vertices
        if DxShift_Trig == 1
            xCube(vRange) = xCube(vRange) +...
                DxShift_Trig.*sdx; %[nm]
        end
        % Shift {y} vertices
        if DyShift_Trig == 1
            yCube(vRange) = yCube(vRange) +...
                DyShift_Trig.*sdy; %[nm]
        end
        % Shift {z} vertices
        if DzShift_Trig == 1
            zCube(vRange) = zCube(vRange) +...
                DzShift_Trig.*sdz; %[nm]
        end
        
        
        % Update {x} coordinate in UI display
        str_x_t = num2str(xCube(VOI));
        % Update {y} coordinate in UI display
        str_y_t = num2str(yCube(VOI));
        % Update {z} coordinate in UI display
        str_z_t = num2str(zCube(VOI));
        
        % Update {x,y,z} coordinates in the GUI display
        UpdateXYZinGUI
        
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        % Register new design step and save design
        UponNewAction
        % Histogram for vertex spacings
        SpacingHistogram
        % Visual and transparent patch objects for element length range
        DisplayElementForSegmentSearch
    end

% Remesh vertex and segment list for additional resolution
    function ReMesh(~,event_data)
        
        % ...Segment must exist
        if nSeg > 0
            
            % Record the number of vertices prior to ReMesh in order that
            % later only these vertices are text labelled on the 3D plot to
            % reduce clutter
            idx_ReMax = idx_ReMax + 1; %[idx]
            % Update the current ReMesh number
            set(GUI_ReMesh_Current,'String',num2str(idx_ReMax));
            % Record the total number of vertices prior to remeshing
            v_i_2D(idx_ReMax) = vt; %[idx]
            
            % Initial vertex duplication based on symmetery
            s_i(1:2:(2*MaxExposureLevel-1),1:MaxSegsPerLevel) =...
                s_i(1:MaxExposureLevel,1:MaxSegsPerLevel); %[idx]
            % Final vertex duplication based on symmetery
            s_f(2:2:(2*MaxExposureLevel),1:MaxSegsPerLevel) =...
                s_f(1:MaxExposureLevel,1:MaxSegsPerLevel); %[idx]
            % Segment index duplication
            eIdx(1:2:(2*MaxExposureLevel-1),1:MaxSegsPerLevel) =...
                eIdx(1:MaxExposureLevel,1:MaxSegsPerLevel); %[idx]
            
            % ...exposure level
            for n=1:MaxExposureLevel
                % ...segment
                for m=1:n_e(n)
                    
                    % New vertex
                    vt  = vt + 1; %[1,2,3,...]
                    % New converted segment indices
                    i_idx = round(2.*n-1);   f_idx = round(2.*n); %[idx]
                    % New segment indexed
                    s_i(f_idx,m) = vt;   s_f(i_idx,m) = vt; %[idx]

                    % New segment
                    nSeg = nSeg + 1; %[1,2,3,...]
                    eIdx(f_idx,m) = nSeg; %[1,2,3,...]

                    % New {x} coordinate
                    xCube(vt) = xCube(s_i(i_idx,m)) + 0.5.*...
                        (xCube(s_f(f_idx,m)) - xCube(s_i(i_idx,m))); %[nm]
                    % New {y} coordinate
                    yCube(vt) = yCube(s_i(i_idx,m)) + 0.5.*...
                        (yCube(s_f(f_idx,m)) - yCube(s_i(i_idx,m))); %[nm]
                    % New {y} coordinate
                    zCube(vt) = zCube(s_i(i_idx,m)) + 0.5.*...
                        (zCube(s_f(f_idx,m)) - zCube(s_i(i_idx,m))); %[nm]
                    
                end
            end
            % Number of segments per level copy and pasted
            n_e(1:2:(2*MaxExposureLevel-1)) = n_e(1:MaxExposureLevel); %[idx]
            n_e(2:2:(2*MaxExposureLevel)) = n_e(1:2:(2*MaxExposureLevel-1)); %[idx]
            
            % Display the maximum number of vertices in the main GUI window
            % following the operation and update the vertex-of-interest to
            % the maximum value
            set(GUI_VertexDefine_TypeVOI,'String',num2str(vt));
            set(GUI_VertexDefine_VertexNumber,'String',num2str(vt));
            
            % New level
            lvl = lvl + MaxExposureLevel; %[1,2,3,...]
            MaxExposureLevel = MaxExposureLevel + MaxExposureLevel; %[1,2,3,...]
            
            % Set vertex-of-interest to the maximum vertex following upload
            VOI = vt; %[idx]
            % Next vertex to be defined
            nv = vt + 1; %[idx]
            
            % Update {x,y,z} coordinates in the GUI display
            % Update {x} coordinate in UI display
            str_x_t = num2str(xCube(VOI));
            % Update {y} coordinate in UI display
            str_y_t = num2str(yCube(VOI));
            % Update {z} coordinate in UI display
            str_z_t = num2str(zCube(VOI));
            
            % Update {x,y,z} coordinates in the GUI display
            UpdateXYZinGUI
            
            % Set level indicator to maximum level number following
            % auto-segment find operation
            set(GUI_SegmentManual_lvl,'String',num2str(MaxExposureLevel));
            % Table of segments per level
            FillEdgesSpreadSheet
            
            % Visible vertices
            VisibleVertices
            % Refresh the vertices and segments in 2D and 3D
            ReRender
            % Register new design step and save design
            UponNewAction
            % Histogram for vertex spacings
            SpacingHistogram
            % Visual and transparent patch objects for element length range
            DisplayElementForSegmentSearch
            
        end
    end

% Step back to the previous ReMesh point
    function ReMesh_Older(GUI_ReMesh_Older,event_data)
        
        % Revert to previous Remeshed state
        if ( str2double(get(GUI_ReMesh_Current,'String')) - 1 ) >= 0
            % Update the remesh index
            idx_Re = str2double(get(GUI_ReMesh_Current,'String')) - 1; %[idx]
            set(GUI_ReMesh_Current,'String',num2str(idx_Re))
            
            % Refresh the vertices and segments in 2D and 3D
            ReRender
        end

    end

% Step back to the previous ReMesh point
    function ReMesh_Newer(GUI_ReMesh_Newer,event_data)
        
        % Advance toward a more refined remeshed state
        if ( str2double(get(GUI_ReMesh_Current,'String')) + 1 ) <= idx_ReMax
            % Update the remesh index
            idx_Re = str2double(get(GUI_ReMesh_Current,'String')) + 1; %[idx]
            set(GUI_ReMesh_Current,'String',num2str(idx_Re))
            
            %Refresh the vertices and segments in 2D and 3D
            ReRender
        end
    end

% GUI_SegmentManual_...{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Edit initial segment vertiex index in UI control
    function InitialVertexForSegment(GUI_SegmentManual_i,event_data)
        % Enter initial segment vertex
        vNow = str2double(get(GUI_SegmentManual_i,'string')); %[1,2,3,...]
        
        % Vertex # constraints applied
        VertexConstraints
        
        % Advance the global index number
        ei = vNow; %[idx]
        set(GUI_SegmentManual_i,'String',num2str(ei));
    end

% Advance initial segment vertex index using GUI/mouse
    function iUp(~,event_data)
        % Current segment initial vertex index
        vNow = str2double(get(GUI_SegmentManual_i,'string')); %[1,2,3,...]
        % Advance index number
        vNow = vNow + 1; %[1,2,3,...]
        
        % Vertex # constraints applied
        VertexConstraints
        
        % Advance the global index number
        ei = vNow; %[idx]
        % Set initial segment index
        set(GUI_SegmentManual_i,'String',num2str(ei));
    end

% Reduce initial segment vertex index using GUI/mouse
    function iDown(~,event_data)
        % Current segment vertex initial index
        vNow = str2double(get(GUI_SegmentManual_i,'string')); %[1,2,3,...]
        % Advance index number
        vNow = vNow - 1; %[1,2,3,...]
        
        % Vertex # constraints applied
        VertexConstraints
        
        % Advance the global index number
        ei = vNow; %[idx]
        set(GUI_SegmentManual_i,'String',num2str(ei));
    end

% Edit final segment vertex index in UI control
    function FinalVertexForSegment(GUI_SegmentManual_f,event_data)
        % Enter final segment vertex value
        vNow = str2double(get(GUI_SegmentManual_f,'string')); %[nm]
        
        % Vertex # constraints applied
        VertexConstraints
        
        % Advance the global index number
        ef = vNow; %[idx]
        set(GUI_SegmentManual_f,'String',num2str(ef));
    end

% Advance final segment vertex index using GUI/mouse
    function fUp(~,event_data)
        % Current segment vertex initial index
        vNow = str2double(get(GUI_SegmentManual_f,'string')); %[1,2,3,...]
        % Advance index number
        vNow = vNow + 1; %[1,2,3,...]
        
        % Vertex # constraints applied
        VertexConstraints
        
        % Advance the global index number
        ef = vNow; %[idx]
        set(GUI_SegmentManual_f,'String',num2str(ef));
    end

% Reduce initial segment vertex index using GUI/mouse
    function fDown(~,event_data)
        
        % Current segment vertex initial index
        vNow = str2double(get(GUI_SegmentManual_f,'string')); %[1,2,3,...]
        % Advance index number
        vNow = vNow - 1; %[1,2,3,...]
        
        % Vertex # constraints applied
        VertexConstraints
        
        % Advance the global index number
        ef = vNow; %[idx]
        set(GUI_SegmentManual_f,'String',num2str(ef));
    end

% Vertex value constraints
    function VertexConstraints(~,event_data)
        
        % Integer values only
        vNow = round(vNow);
        % Minimum integer value of 1
        if vNow < 1
            vNow = 1; %[1,2,3,...]
            % The vertex-of-interest is the maximum allowable integer
        elseif vNow > vt
            vNow = vt; %[1,2,3,...]
        end
    end

% Edit the exposure level number in UI control
    function LevelForSegment(GUI_SegmentManual_lvl,event_data)
        
        % Current exposure level value
        lvlNow = str2double(get(GUI_SegmentManual_lvl,'string')); %[nm]
        
        % Exposure level # constraints applied
        LevelConstraints
        
        % Update the exposure level GUI display
        set(GUI_SegmentManual_lvl,'String',num2str(lvl)); %[nm]
        % Table of segments per level
        FillEdgesSpreadSheet
    end

% Advance exposure level index using GUI/mouse
    function lvlUp(~,event_data)
        
        % Current exposure level value
        lvlNow = str2double(get(GUI_SegmentManual_lvl,'string')); %[1,2,3,...]
        % Advance index number
        lvlNow = lvlNow + 1; %[1,2,3,...]
        
        % Level # constraints applied
        LevelConstraints
        
        % Advance global index number
        % Update the level GUI display
        set(GUI_SegmentManual_lvl,'String',num2str(lvl));
        % Table of segments per level
        FillEdgesSpreadSheet
    end

% Reduce the exposure level index using GUI/mouse
    function lvlDown(~,event_data)
        
        % Current exposure level value
        lvlNow = str2double(get(GUI_SegmentManual_lvl,'string')); %[1,2,3,...]
        % Advance index number
        lvlNow = lvlNow - 1; %[1,2,3,...]
        
        % Level # constraints applied
        LevelConstraints
        
        % Set exposure level  index
        set(GUI_SegmentManual_lvl,'String',num2str(lvl)); %[1,2,3,...]
        % Table of segments per level
        FillEdgesSpreadSheet
    end

% Exposure level value constraints
    function LevelConstraints(~, event_data)
        
        % The exposure level number must be an integer
        lvlNow = round(lvlNow); %[1,2,3,...]
        % The minimum value allowable for {lvl} is 1
        if lvlNow < 1
            lvl = 1; %[1,2,3,...]
            % Exposure levels may not be skipped
        elseif lvlNow > (MaxExposureLevel + 1)
            % value will not be accepted
            lvl = MaxExposureLevel + 1; %[1,2,3,...]
        else
            lvl = lvlNow; %[1,2,3,...]
        end
    end

% Submission of new segment into the CAD list
    function Segment(GUI_SegmentManual_Segment,event_data)
        
        % Segment redundancy check
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        lvl_Test = MaxExposureLevel; %[idx]
        if lvl > MaxExposureLevel
            lvl_Test = lvl; %[1,2,3,...]
        end

        Redundant = 0; %[0/1]
        % ...per exposure level
        for n=1:lvl_Test
            % ...per segment
            for m=1:n_e(n)
                % Segment existance check
                if s_i(n,m) == ei && s_f(n,m) == ef
                    Redundant = 1; %[0/1]
                end
            end
        end
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        
        % Segment is unique
        if Redundant == 0
            
            % Number of exposure levels
            MaxExposureLevel = lvl_Test; %[idx]
            
            % Number of segments
            nSeg = nSeg + 1; %[1,2,3,...]
            % Segments per level (parallelism)
            n_e(lvl) = n_e(lvl) + 1; %[1,2,3,...]
            
            % Maximum number of shots per level
            MaxSegsPerLevel = max(n_e(1:MaxExposureLevel)); %[1,2,3,...]
            
            % Vertex index for segment initial position
            s_i(lvl,n_e(lvl)) = ei; %[]
            % Vertex index for segment final position
            s_f(lvl,n_e(lvl)) = ef; %[]
            % Segment number
            eIdx(lvl,n_e(lvl)) = nSeg; %[idx]
            
            % Plot segment
            Pobj_Segments(nSeg) = plot3(xyzAxis,...
                [xCube(s_i(lvl,n_e(lvl))) xCube(s_f(lvl,n_e(lvl)))],...
                [yCube(s_i(lvl,n_e(lvl))) yCube(s_f(lvl,n_e(lvl)))],...
                [zCube(s_i(lvl,n_e(lvl))) zCube(s_f(lvl,n_e(lvl)))],'-','Color',...
                iMap(lvl,:),'LineWidth',2);
            % Segment indices record
            Pobj_Segments_idxs(1,nSeg) = s_i(lvl,n_e(lvl)); %[idx]
            Pobj_Segments_idxs(2,nSeg) = s_f(lvl,n_e(lvl)); %[idx]
            % Visible vertices
            VisibleVertices
            % Register new design step and save design
            UponNewAction
            % Table of segments per level
            FillEdgesSpreadSheet
        end
        
    end

% Load segment list from an Excel file-like format and saved as a .txt file in tab
% delimited format
    function LoadSegments(GUI_SegmentManual_LoadSegments,event_data)
        
        ActionFileName = sprintf('%s.txt',ImportFileName);
        % Data import from text file
        SegmentList = dlmread(ActionFileName); %[nm]
        
        % Number of levels
        MaxExposureLevel = round( size(SegmentList,2)./2 ); %[1,2,3,...]
        % Maximum number of segments per level
        MaxSegsPerLevel = size(SegmentList,1); %[1,2,3,...]
        
        % Level number (reset)
        lvl = 0; %[1,2,3,...]
        % Segment number (reset)
        nSeg = 0; %[1,2,3,...]
        
        % Segments per level
        for a=1:2:size(SegmentList,2)
            
            % New level
            lvl = lvl + 1; %[1,2,3,...]
            % Segments per level {lvl}
            n_e(lvl) = sum(SegmentList(:,a) ~= 0); %[1,2,3,...]
            
            % ...Segments
            for b=1:n_e(lvl)
                
                % Initial vertex for the segment
                s_i(lvl,b) = SegmentList(b,a); %[1,2,3,...]
                % Final vertex for the segment
                s_f(lvl,b) = SegmentList(b,a+1); %[1,2,3,...]
                % Total number of segments in design
                nSeg = nSeg + 1; %[1,2,3,...]
                % Unique segment index
                eIdx(lvl,b) = nSeg; %[1,2,3,...]
            end
            
        end
        
        % Visible vertices
        VisibleVertices
        % Register new design step and save design
        UponNewAction
        % Set level indicator to maximum level number following
        % auto-segment find operation
        set(GUI_SegmentManual_lvl,'String',num2str(MaxExposureLevel));
        % Table of segments per level
        FillEdgesSpreadSheet
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        
    end

% Advance initial segment bundle indices using GUI/mouse
    function iLeft(GUI_SegmentManual_iLeft,event_data)
        % Advance index number
        if Bundle > 1
            Bundle = Bundle - 1; %[1,2,3,...]
        end
        FillEdgesSpreadSheet
    end

% Decrease initial segment bundle indices using  GUI/mouse
    function iRight(GUI_SegmentManual_iRight,event_data)
        % Advance index number
        Bundle = Bundle + 1; %[1,2,3,...]
        FillEdgesSpreadSheet
    end

% In the limit of a large number of segments per level, the list of segment
% characeristics can be cycled through the various pages of segment bundles
    function SegmentBundle(~,event_data)
        
        % Bundle display is limited by the number of segment per level
        MaxBundle = floor(n_e(lvl)./DispSegs) + 1;
        Segs4Display = DispSegs; %[]
        
        if Bundle == MaxBundle
            Segs4Display = n_e(lvl) - (MaxBundle-1).*DispSegs;
        elseif Bundle > MaxBundle
            Bundle = 1; %[1,2,3,...]
        end
        
        set(GUI_SegmentManual_iDisplayRange,...
            'String',num2str(round((Bundle - 1).*DispSegs + 1)));
        set(GUI_SegmentManual_fDisplayRange,...
            'String',num2str(round(Bundle.*DispSegs)));
        
        ij = round(MaxUIs.*(Bundle - 1)); %[1,2,3,...]
        jk = round((Bundle - 1).*DispSegs); %[1,2,3,...]
        
        for m=1:Segs4Display
            for n=1:2
                ij = ij + 1;
                set(Obj_xy(ij),'Visible','on');
            end
            jk = jk + 1;
            set(iObj_xy(jk),'Visible','on');
        end
        
    end

% Table of segments per level: GUI elements that are populated with initial
% and final vertex indices and the segment index for all segments on a
% given exposure level
    function FillEdgesSpreadSheet(~,event_data)
        
        % Reinitialize all initial and final vertex indices for the segment
        % table (for current active level)
        for n=1:round(2.*NumSegsPerLevel_Limit)
            set(Obj_xy(n),'String',num2str(0),'Visible','Off')
        end
        for n=1:NumSegsPerLevel_Limit
            set(iObj_xy(n),'String',num2str(0),'Visible','Off')
        end
        
        % Reorgranize the segment exposures in the current level based on
        % the changes made
        ij = 0;
        for n=1:n_e(lvl)
            ij = ij + 1;
            set(Obj_xy(ij),'String',num2str(s_i(lvl,n)))
            ij = ij + 1;
            set(Obj_xy(ij),'String',num2str(s_f(lvl,n)))
            set(iObj_xy(n),'String',num2str(n))
        end
        
        SegmentBundle
    end

% Change, edit, reorganize and delete segments from table
    function SegmentEdit(GUI_SegmentManual_SegmentEdit,event_data)
        
        % Number of segments counter
        New_n_e = 0; %[1,2,3,...]
        s_i_Tmp(:) = 0;   s_f_Tmp(:) = 0;   eIdx_Tmp(:) = 0;
        
        Deleted = zeros(1,n_e(lvl)); %[]
        % ...current number of segments
        for n=1:n_e(lvl)
            % Edge exists
            EdgeID = str2double(get(iObj_xy(n),'String')); %[0,1,2,3,...]
            if EdgeID == 0
                Deleted(n) = 1;
            end
        end
        
        % Number of deleted segments
        dEdgeID = cumsum(Deleted); %[1,2,3,...]
        
        % ...current number of segments
        for n=1:n_e(lvl)
            % Edge exists
            EdgeID = str2double(get(iObj_xy(n),'String')); %[0,1,2,3,...]
            % Segment will be kept
            if EdgeID > 0
                % Count new/old edge
                New_n_e = New_n_e + 1; %[1,2,3,...]
                % Initial index of edge
                s_i_Tmp(EdgeID-dEdgeID(EdgeID)) =...
                    str2double(get(Obj_xy(round(2.*n-1)),'String')); %[1,2,3,...]
                % Final index of edge
                s_f_Tmp(EdgeID-dEdgeID(EdgeID)) =...
                    str2double(get(Obj_xy(round(2.*n)),'String')); %[1,2,3,...]
                % Unique index of edge
                eIdx_Tmp(EdgeID-dEdgeID(EdgeID)) = eIdx(lvl,n); %[1,2,3,...]
            end
        end
        
        
        % Initial edge index (reassign)
        s_i(lvl,1:New_n_e) = s_i_Tmp(1:New_n_e); %[1,2,3,...]
        % Final edge index (reassign)
        s_f(lvl,1:New_n_e) = s_f_Tmp(1:New_n_e); %[1,2,3,...]
        % Unique ID for index
        eIdx(lvl,1:New_n_e) = eIdx_Tmp(1:New_n_e); %[1,2,3,...]
        % Number of segments
        n_e(lvl) = New_n_e; %[1,2,3,...]
        
        % Re-index segments and update the total number of levels and the
        % number of segments per level
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        nSeg = 0; %[1,2,3,...]
        eIdx(:,:) = 0; %[idx]
        for n=1:MaxExposureLevel
            for m=1:n_e(n)
                % Edge found
                nSeg = nSeg + 1; %[1,2,3,...]
                % Unique edge assignment
                eIdx(n,m) = nSeg; %[1,2,3,...]
            end
        end
        % Maximum number of segments over all levels
        MaxSegsPerLevel =...
            max( sum(eIdx(1:MaxExposureLevel,1:MaxSegsPerLevel) > 0,2) ); %[1,2,3,...]
        % Number of exposure levels
        MaxExposureLevel =...
            sum(sum(eIdx(1:MaxExposureLevel,1:MaxSegsPerLevel) > 0,2) > 0); %[1,2,3,...]

        % Visible vertices
        VisibleVertices
        % Register new design step and save design
        UponNewAction
        % Table of segments per level
        FillEdgesSpreadSheet
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        
    end

% Segment plot update in 3D (x,y,z)
    function SegmentRevisited(~,event_data)
        for n=1:nSeg
            if Pobj_Segments_idxs(1,n) == VOI || Pobj_Segments_idxs(2,n) == VOI
                set(Pobj_Segments(n),'XData',...
                    [xCube(Pobj_Segments_idxs(1,n)) xCube(Pobj_Segments_idxs(2,n))],...
                    'YData',...
                    [yCube(Pobj_Segments_idxs(1,n)) yCube(Pobj_Segments_idxs(2,n))],...
                    'ZData',...
                    [zCube(Pobj_Segments_idxs(1,n)) zCube(Pobj_Segments_idxs(2,n))])
            end
        end
    end



% GUI_FolderManage_{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% File name UI control (design folder)
    function LoadDesignFolder(GUI_FolderManage_LoadDesignFolder,event_data)
        
        % Reload/Create folder
        DesignFolderName = get(GUI_FolderManage_LoadDesignFolder,'string'); %[str]
        % Check if folder name exists and load it, if it does exit
        % File exists by default
        FileExists = 1; %[0/1]
        try
            cd(DesignFolderName)
        catch
            warndlg({DesignFolderName;' does not exist'},'!! Warning !!')
            set(GUI_FolderManage_LoadDesignFolder,'string',SaveDesignFolderName);
            FileExists = 0; %[0/1]
        end
        
        % Reload CAD design file and details
        % ooooooooooooooooooooooooooooooooooo
        if FileExists == 1
            load DesignSteps X14
            UndoRedo = X14; %[]
            
            set(GUI_DesignAction_InputActionNumber,'string',num2str(UndoRedo));
            NewActions = X14; %[]
            strNewActions = num2str(NewActions);
            set(GUI_DesignAction_MaxActionNumber,'string',strNewActions);
            
            cd ../
            
            % Reload design files for the selected action number
            ReLoadPastAction
        end
        % ooooooooooooooooooooooooooooooooooo
    end

% Active duplication of {x,y,z} coordinates
    function NewDesign(GUI_FolderManage_NewDesign,event_data)
        
        iSituation = 3; %[1,2,3]
        figure(InfoFig)
        set(InfoFig,'Visible','On')
        
        % User confirmation check
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        Request = 'Launch a new design - do you really want to start a new session?';
        set(GUI_UserInput_Question,'String',Request);
        % Press buttion set-up
        LeftButtonText = 'Yes';
        set(GUI_UserInput_LeftButton,'String',LeftButtonText);
        RightButtonText = 'No';
        set(GUI_UserInput_RightButton,'String',RightButtonText);
        % UI configuation for this particular case
        set(GUI_UserInput_LeftButton,'Visible','On');
        set(GUI_UserInput_RightButton,'Visible','On');
        set(GUI_UserInput_TypeName,'Visible','Off');
        uiwait
        
    end

% Capture current User Interface screen for documentation
    function ScreenCapture(~,event_data)
        
        % Image acquisition of User Interface Actions
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        cd(DesignFolderName)
        
        % Advance the User Interface snapshot counter
        New_UI_Image = New_UI_Image + 1; %[1,2,3,...]
        set(GUI_Document_ScreenCaptureFrame,'String',num2str(New_UI_Image));
        % Create unique image file name
        uiImageFileName = sprintf('ImageUI_%g.tif',New_UI_Image);
        % Capture frame of {MainFig}
        f = getframe(MainFig);
        % Convert to image
        [im,~] = frame2im(f);
        % Write image file
        imwrite(im,uiImageFileName);
        
        cd ../
        
    end

% Screen capture automatic toggle
    function ScreenCaptureOn(GUI_Document_ScreenCaptureOn,event_data)
        
        uiRecordActions = logical(get(GUI_Document_ScreenCaptureOn,'Value'));
        % Automatic screen image capture, per User action, is on and
        % indicated by green color
        if uiRecordActions == true
            set(GUI_Document_ScreenCaptureOn,'String','A',...
                'BackgroundColor',[0 1 0]);
            % Automatic screen image capture, per User action, is off and
            % indicated by red color
        elseif uiRecordActions == false
            set(GUI_Document_ScreenCaptureOn,'String','M',...
                'BackgroundColor',[1 0 0]);
        end
        
    end



% GUI_DesignAction_{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% User types an action number of interest for Undo/Redo
    function InputActionNumber(GUI_DesignAction_InputActionNumber,event_data)
        
        % UndoRedo to {UndoRedo} progress point
        UndoRedo = str2double(get(GUI_DesignAction_InputActionNumber,'string')); %[nm]
        
        % Round {UndoRedo} to prevent decimal value
        UndoRedo = round(UndoRedo); %[0,1,2,...]
        % {UndoRedo} is limited to a range
        if UndoRedo < 1
            UndoRedo = 1; %[> 1]
        elseif UndoRedo > NewActions
            UndoRedo = NewActions; %[< NewActions]
        end
        % Reload design files for the selected action number
        ReLoadPastAction;
        
    end

% Advance forward in 'past' actions
    function ActionForward(GUI_DesignAction_ActionForward,event_data)
        
        % Selected action cannot exceed the current maximum
        if UndoRedo < NewActions
            % Move forward in action number
            UndoRedo = UndoRedo + 1; %[1,2,3,...]
            % Reload design files for the selected action number
            ReLoadPastAction;
        end
        
        % Update current design step value
        set(GUI_DesignAction_InputActionNumber,'string',num2str(UndoRedo)); %[nm]
        
    end

% Advance backward in 'past' actions
    function ActionBackward(GUI_DesignAction_ActionBackward,event_data)
        
        % Selected action cannot be less than 1, such an action is
        % undefined
        if UndoRedo > 1
            % Move backward in action number
            UndoRedo = UndoRedo - 1; %[1,2,3,...]
            % Reload design files for the selected action number
            ReLoadPastAction;
        end
        
        % Update current design step value
        set(GUI_DesignAction_InputActionNumber,'string',num2str(UndoRedo)); %[nm]
        
    end

% Update the current, maximum number of design steps
    function MaxActionNumber(GUI_DesignAction_MaxActionNumber,event_data)
        % Display the new maximum number of design steps
        strNewActions = num2str(NewActions);
        set(GUI_DesignAction_MaxActionNumber,'string',strNewActions);
    end

% UndoRedo to previous design step of 3D object build
    function ReLoadPastAction(~,event_data)
        
        % Load past progress
        LoadName = sprintf('BuildHistory%g',UndoRedo);
        
        cd(DesignFolderName)
        load(LoadName,'iDes3D')
        cd ../
        
        % Load CAD parameters from the previous design
        xCube = iDes3D{1,1}; %[nm]
        yCube = iDes3D{2,1}; %[nm]
        zCube = iDes3D{3,1}; %[nm]
        s_i = iDes3D{4,1}; %[idx]
        s_f = iDes3D{5,1}; %[idx]
        eIdx = iDes3D{6,1}; %[idx]
        n_e = iDes3D{7,1}; %[1,2,3,...]
        vt = iDes3D{8,1}; %[1,2,3,...]
        nv = iDes3D{9,1}; %[1,2,3,...]
        nSeg = iDes3D{10,1}; %[1,2,3,...]
        ds = iDes3D{11,1}; %[nm]
        MaxExposureLevel = iDes3D{12,1}; %[idx]
        MaxSegsPerLevel = iDes3D{13,1}; %[idx]
        sCube = iDes3D{15,1}; %[0/1]
        vDz = iDes3D{17,1}; %[nm/s]
        xMin = iDes3D{20,1}; %[nm]
        xMax = iDes3D{21,1}; %[nm]
        yMin = iDes3D{22,1}; %[nm]
        yMax = iDes3D{23,1}; %[nm]
        zMin = iDes3D{24,1}; %[nm]
        zMax = iDes3D{25,1}; %[nm]
        xArtifact = iDes3D{26,1}; %[nm]
        yArtifact = iDes3D{27,1}; %[nm]
        FitVGR = iDes3D{28,1}; %[nm/s]
        FitpPD = iDes3D{29,1}; %[ms]
        FitrPD = iDes3D{30,1}; %[ms]
        TauMin = iDes3D{31,1}; %[ms]
        yInversion = iDes3D{32,1}; %[0/1]
        idx_ReMax = iDes3D{33,1}; %[idx]
        rN = iDes3D{34,1}; %[nm]
        FittedCalibData = iDes3D{35,1}; %[0/1]
        zFit = iDes3D{36,1}; %[deg]
        ForbiddenTau = iDes3D{37,1}; %[ms]
        v_i_2D = iDes3D{38,1}; %[1,2,3,...]
        
        
        % Vertex information update: set {VOI} to total number of vertices
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        % Voxel-of-interest
        VOI = vt; %[1,2,3,...]
        set(GUI_VertexDefine_TypeVOI,'String',num2str(VOI)); %[idx]
        
        % Number of vertices
        set(GUI_VertexDefine_VertexNumber,'String',num2str(vt));
        
        % {x} coordinate of vertex
        str_x_t = num2str(xCube(VOI));
        set(GUI_VertexDefine_SubstrateContact,'String',str_x_t)
        % {y} coordinate of vertex
        str_y_t = num2str(yCube(VOI));
        set(GUI_VertexDefine_SubstrateContact,'String',str_y_t)
        % {z} coordinate of vertex
        str_z_t = num2str(zCube(VOI));
        set(GUI_VertexDefine_SubstrateContact,'String',str_z_t)
        
        % Pixel point pitch
        set(GUI_Expose_PixelPointPitch,'String',num2str(ds));
        % Substrate contact
        set(GUI_VertexDefine_SubstrateContact,'String',num2str(sCube(VOI)))
        
        % Update current design step value
        set(GUI_DesignAction_InputActionNumber,'String',num2str(UndoRedo));
        
        % Vertical growth rate (experimental)
        set(GUI_Calibration_TypevDz,'String',num2str(vDz))
        
        % Axes limits in 3D plot
        set(GUI_VertexDefine_xMin,'String',num2str(xMin))
        set(GUI_VertexDefine_xMax,'String',num2str(xMax))
        set(GUI_VertexDefine_yMin,'String',num2str(yMin))
        set(GUI_VertexDefine_yMax,'String',num2str(yMax))
        set(GUI_VertexDefine_zMin,'String',num2str(zMin))
        set(GUI_VertexDefine_zMax,'String',num2str(zMax))
        
        % Artifact exposure coordinate
        set(GUI_Expose_xBad,'String',num2str(xArtifact))
        set(GUI_Expose_yBad,'String',num2str(yArtifact))
        
        % Calibration curve fitting parameters
        set(GUI_Calibration_VGR_Fit,'String',num2str(FitVGR));
        set(GUI_Calibration_pPD_Fit,'String',num2str(FitpPD));
        set(GUI_Calibration_rPD_Fit,'String',num2str(FitrPD));
        set(GUI_Calibration_TauMin,'String',num2str(TauMin));
        
        % {y}-axis inversion setting
        set(GUI_Expose_Flip_y,'Value',yInversion); %[0/1]
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        % Table of segments per level
        FillEdgesSpreadSheet
        % Histogram for vertex spacings
        SpacingHistogram
        % Visual and transparent patch objects for element length range
        DisplayElementForSegmentSearch
        % Determine the minimum allowed segment angle from the user defined
        % input box
        TauMinSet
        % Axes limits in 3D updated
        AxesLimits
        
    end

% Register new design step and save design
    function UponNewAction(~,event_data)
        
        % New 'action detected'
        NewActions = NewActions + 1; %[1,2,3,...]
        
        % Update the action tracking number
        UndoRedo = NewActions; %[1,2,3,...]
        set(GUI_DesignAction_InputActionNumber,'String',num2str(UndoRedo));
        % Update the current maximum action number
        strNewActions = num2str(NewActions);
        set(GUI_DesignAction_MaxActionNumber,'String',strNewActions);
        % Object build progress save
        SaveName = sprintf('BuildHistory%g',NewActions);
        
        cd(SupportingFilesFolderName)
        load StructureData iDes3D
        cd ../
        
        % Variable registration for save
        iDes3D{1,1} = xCube; %[nm]
        iDes3D{2,1} = yCube; %[nm]
        iDes3D{3,1} = zCube; %[nm]
        iDes3D{4,1} = s_i; %[idx]
        iDes3D{5,1} = s_f; %[idx]
        iDes3D{6,1} = eIdx; %[idx]
        iDes3D{7,1} = n_e; %[1,2,3,...]
        iDes3D{8,1} = vt; %[1,2,3,...]
        iDes3D{9,1} = nv; %[1,2,3,...]
        iDes3D{10,1} = nSeg; %[1,2,3,...]
        iDes3D{11,1} = ds; %[nm]
        iDes3D{12,1} = MaxExposureLevel; %[idx]
        iDes3D{13,1} = MaxSegsPerLevel; %[idx]
        iDes3D{15,1} = sCube; %[0/1]
        iDes3D{17,1} = vDz; %[nm/s]
        iDes3D{20,1} = xMin; %[nm]
        iDes3D{21,1} = xMax; %[nm]
        iDes3D{22,1} = yMin; %[nm]
        iDes3D{23,1} = yMax; %[nm]
        iDes3D{24,1} = zMin; %[nm]
        iDes3D{25,1} = zMax; %[nm]
        iDes3D{26,1} = xArtifact; %[nm]
        iDes3D{27,1} = yArtifact; %[nm]
        iDes3D{28,1} = FitVGR; %[nm/s]
        iDes3D{29,1} = FitpPD; %[ms]
        iDes3D{30,1} = FitrPD; %[ms]
        iDes3D{31,1} = TauMin; %[ms]
        iDes3D{32,1} = yInversion; %[0/1]
        iDes3D{33,1} = idx_ReMax; %[idx]
        iDes3D{34,1} = rN; %[nm]
        iDes3D{35,1} = FittedCalibData; %[0/1]
        iDes3D{36,1} = zFit; %[deg]
        iDes3D{37,1} = ForbiddenTau; %[ms]
        iDes3D{38,1} = v_i_2D; %[1,2,3,...]
        
        cd(DesignFolderName)
        save(SaveName,'iDes3D')
        X14 = NewActions;
        save DesignSteps X14
        cd ../
        
        % Image acquisition of User Interface Actions
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        if uiRecordActions == true
            ScreenCapture
        end
    end



% GUI_Operations_{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Center 3D object in  {xy-plane}
    function Cxy(~,event_data)
        
        % Centering action: {x} & {y} shift to center in {xy-plane}
        xCube(1:vt) = xCube(1:vt) -...
            mean( [max(xCube(1:vt)) min(xCube(1:vt))] ); %[nm]  
        yCube(1:vt) = yCube(1:vt) -...
            mean( [max(yCube(1:vt)) min(yCube(1:vt))] ); %[nm]
        
        % {x} coordinate of vertex
        str_x_t = num2str(xCube(VOI));
        % {y} coordinate of vertex
        str_y_t = num2str(yCube(VOI));
        % {z} coordinate of vertex
        str_z_t = num2str(zCube(VOI));
        
        % Update {x,y,z} coordinates in the GUI display
        UpdateXYZinGUI
        
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        % Register new design step and save design
        UponNewAction
    end

% Substrate contact (forces the lowest point in the CAD to {z = 0} and
% applies the same shift to all vertices)
    function zAttach(GUI_Operations_zAttach,event_data)
        
        % Place 3D object on the surface
        zCube(1:vt) = zCube(1:vt) -...
            min(zCube(1:vt)); %[nm]; %[nm]
        
        % {x} coordinate of vertex
        str_x_t = num2str(xCube(VOI));
        % {y} coordinate of vertex
        str_y_t = num2str(yCube(VOI));
        % {z} coordinate of vertex
        str_z_t = num2str(zCube(VOI));
        
        % Update {x,y,z} coordinates in the GUI display
        UpdateXYZinGUI
        
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        % Register new design step and save design
        UponNewAction
    end

% Vertices in the 3D object design that should be in contact with the
% substrate.  Important for auto-segment detection
    function zBond(GUI_Operations_zBond,event_data)
        
        % 'Vertex List' text input box flashes yellow
        FlashVertexList
        
        % Reset the state of surface contact points
        sCube(1:vt) = 0; %[0/1]
        % Place 3D object on the surface
        sCube(vRange) = 1; %[0/1]
        % Update surface digital ID in UI display
        set(GUI_VertexDefine_SubstrateContact,'String',num2str(sCube(VOI))); %[0/1]
              
        % Register new design step and save design
        UponNewAction
    end

% Rotation about the z-axis in the {xy-plane}
    function Rxy(GUI_Operations_Rxy,event_data)
        
        % 'Vertex List' text input box flashes yellow
        FlashVertexList
        
        % Rotation in the {xy-plane}
        xt = xCube(vRange).*cos(theta.*pi./180) -...
            yCube(vRange).*sin(theta.*pi./180); %[nm]
        yt = xCube(vRange).*sin(theta.*pi./180) +...
            yCube(vRange).*cos(theta.*pi./180); %[nm]
        
        xCube(vRange) = xt;   yCube(vRange) = yt; %[nm]
        
        % {x} coordinate of vertex
        str_x_t = num2str(xCube(VOI));
        % {y} coordinate of vertex
        str_y_t = num2str(yCube(VOI));
        % {z} coordinate of vertex
        str_z_t = num2str(zCube(VOI));
        
        % Update {x,y,z} coordinates in the GUI display
        UpdateXYZinGUI
        
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        % Register new design step and save design
        UponNewAction
    end

% Edit rotation value in {xy-plane}
    function RxyValue(GUI_Operations_RxyValue,event_data)
        theta = str2double(get(GUI_Operations_RxyValue,'string')); %[deg]
    end

% Rotation about the y-axis in the {xz-plane}
    function Txz(GUI_Operations_Txz,event_data)
        
        % 'Vertex List' text input box flashes yellow
        FlashVertexList
        
        % Rotation in the {xz-plane}
        xt = xCube(vRange).*cos(alpha.*pi./180) -...
            zCube(vRange).*sin(alpha.*pi./180); %[nm]
        zt = xCube(vRange).*sin(alpha.*pi./180) +...
            zCube(vRange).*cos(alpha.*pi./180); %[nm]
        
        xCube(vRange) = xt;   zCube(vRange) = zt; %[nm]
        
        % {x} coordinate of vertex
        str_x_t = num2str(xCube(VOI));
        % {y} coordinate of vertex
        str_y_t = num2str(yCube(VOI));
        % {z} coordinate of vertex
        str_z_t = num2str(zCube(VOI));
        
        % Update {x,y,z} coordinates in the GUI display
        UpdateXYZinGUI
        
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        % Register new design step and save design
        UponNewAction
    end

% Edit rotation value in {xz-plane}
    function TxzValue(GUI_Operations_TxzValue,event_data)
        alpha = str2double(get(GUI_Operations_TxzValue,'string')); %[deg]
    end

% Rotation about the z-axis in the {yz-plane}
    function Tyz(GUI_Operations_Tyz,event_data)
        
        % 'Vertex List' text input box flashes yellow
        FlashVertexList
        
        % Rotation in the {yz-plane}
        yt = yCube(vRange).*cos(beta.*pi./180) -...
            zCube(vRange).*sin(beta.*pi./180); %[nm]
        zt = yCube(vRange).*sin(beta.*pi./180) +...
            zCube(vRange).*cos(beta.*pi./180); %[nm]
        
        yCube(vRange) = yt;   zCube(vRange) = zt; %[nm]
        
        % {x} coordinate of vertex
        str_x_t = num2str(xCube(VOI));
        % {y} coordinate of vertex
        str_y_t = num2str(yCube(VOI));
        % {z} coordinate of vertex
        str_z_t = num2str(zCube(VOI));
        
        % Update {x,y,z} coordinates in the GUI display
        UpdateXYZinGUI
        
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        % Register new design step and save design
        UponNewAction
    end

% Edit rotation value in {yz-plane}
    function TyzValue(GUI_Operations_TyzValue,event_data)
        beta = str2double(get(GUI_Operations_TyzValue,'string')); %[deg]
    end

% All vertices are (1) converted from (x,y,z) to (x,0,z) and then (2) 
% wrapped onto the surface of a cylinder which points along the z-axis
% and is centered at (x=0,y=0).  The text input box is the radius (rCyl) 
% of the cylinder in nanometers.  
    function Wxy(GUI_Operations_Wxy,event_data)
        
        % 'Vertex List' text input box flashes yellow
        FlashVertexList
        
        % Rotation in the {xy-plane}
        xt = rWrap.*cos(xCube(vRange)./rWrap); %[nm]
        yt = rWrap.*sin(xCube(vRange)./rWrap); %[nm]
        
        xCube(vRange) = xt;   yCube(vRange) = yt; %[nm]
        
        % {x} coordinate of vertex
        str_x_t = num2str(xCube(VOI));
        % {y} coordinate of vertex
        str_y_t = num2str(yCube(VOI));
        % {z} coordinate of vertex
        str_z_t = num2str(zCube(VOI));
        
        % Update {x,y,z} coordinates in the GUI display
        UpdateXYZinGUI
        
        % Refresh the vertices and segments in 2D and 3D
        ReRender
        % Register new design step and save design
        UponNewAction
        % Histogram for vertex spacings
        SpacingHistogram
        % Visual and transparent patch objects for element length range
        DisplayElementForSegmentSearch
    end

% Edit rotation value in {xy-plane}
    function WxyValue(GUI_Operations_WxyValue,event_data)
        rWrap = str2double(get(GUI_Operations_WxyValue,'string')); %[deg]
    end


% GUI_SegmentAutomatic_{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Upload new element length and element length deviation for segment search
    function NewElements(GUI_SegmentAutomatic_NewElements,event_data)
        % {get} all values related to element spacing of interest
        c_Lxyz1D = str2double(get(GUI_SegmentAutomatic_ElementIndex,'string')); %[idx]
        Lxyz1D(c_Lxyz1D) = str2double(get(GUI_SegmentAutomatic_CriticalRadii,'string')); %[nm]
        % Negative values not allowed
        if Lxyz1D(c_Lxyz1D) < 0
            Lxyz1D(c_Lxyz1D) = -Lxyz1D(c_Lxyz1D); %[nm]
            set(GUI_SegmentAutomatic_CriticalRadii,'String',num2str(Lxyz1D(c_Lxyz1D)));
        end
        dLxyz1D(c_Lxyz1D) = str2double(get(GUI_SegmentAutomatic_CriticalRadiiDev,'string')); %[nm]
        % Negative values not allowed
        if dLxyz1D(c_Lxyz1D) < 0
            dLxyz1D(c_Lxyz1D) = -dLxyz1D(c_Lxyz1D); %[nm]
            set(GUI_SegmentAutomatic_CriticalRadiiDev,'String',num2str(dLxyz1D(c_Lxyz1D)));
        end
        % New element length has been uploaded versus changing a past value
        if c_Lxyz1D > n_Lxyz1D
            % Total number of submitted elements
            n_Lxyz1D = n_Lxyz1D + 1; %[idx]
            % UI name reflects current number of submitted elements for
            % search
            LxyzCritIndex = sprintf('index #(%g)',n_Lxyz1D); %[idx]
            set(GUI_SegmentAutomatic_IndexLabel,'string',LxyzCritIndex);
        end
        set(GUI_SegmentAutomatic_ElementIndex,'string',num2str(c_Lxyz1D));
        
        % Visual and transparent patch objects for element length range
        DisplayElementForSegmentSearch
        
    end

% Render transparent patch objects for element length range
    function DisplayElementForSegmentSearch(~,event_data)
        
        % ...per element length submitted
        for a=1:MaxNumBins
            % must be less than the total number of bins submitted
            if a <= n_Lxyz1D
                % Vertex spacing intensity
                set(Rng_Hist(a),'XData',[0 max(Io1D) max(Io1D) 0],...
                    'YData',Lxyz1D(a)+[(-dLxyz1D(a)) (-dLxyz1D(a)) dLxyz1D(a) dLxyz1D(a)],...
                    'Visible','On')
            else
                set(Rng_Hist(a),'Visible','Off')
            end
        end
    end

% Update; (1) element length and (2) element length deviation, in response
% to changing the sumbitted element index
    function ChangeElementCharacteristics(GUI_SegmentAutomatic_ElementIndex,event_data)
        
        c_Lxyz1D = str2double(get(GUI_SegmentAutomatic_ElementIndex,'string')); %[idx]
        % Update values of critical radii and critical radii deviation
        if c_Lxyz1D <= n_Lxyz1D
            set(GUI_SegmentAutomatic_CriticalRadii,'string',num2str(Lxyz1D(c_Lxyz1D))) %[nm]
            set(GUI_SegmentAutomatic_CriticalRadiiDev,'string',num2str(dLxyz1D(c_Lxyz1D))) %[nm]
        end
    end

% Reset the element length vector 
    function ElementsReset(GUI_SegmentAutomatic_ElementsReset,event_data)
        
        % Index for element length submission prepared for sending
        c_Lxyz1D = 1; %[idx]
        set(GUI_SegmentAutomatic_ElementIndex,'string',num2str(c_Lxyz1D)); %[idx]
        % Maximum current number of element length
        n_Lxyz1D = 0; %[1,2,3,...]
        LxyzCritIndex = sprintf('index #(%g)',n_Lxyz1D);
        set(GUI_SegmentAutomatic_IndexLabel,'string',LxyzCritIndex);
        % Default vertex spacing
        Lxyz1D(2:length(Lxyz1D)) = 0; %[nm] 
        set(GUI_SegmentAutomatic_CriticalRadii,'string',num2str(Lxyz1D(1))); %[nm]
        % Default vertex spacing deviation
        dLxyz1D(2:length(dLxyz1D)) = 0; %[nm]
        set(GUI_SegmentAutomatic_CriticalRadiiDev,'string',num2str(dLxyz1D(1))); %[nm]
        
        % Visual and transparent patch objects for element length range
        DisplayElementForSegmentSearch
    end

% Identify segments based on the element lengths and ranges specified in
% the vertex spacing histogram
    function AutoSegmentID(GUI_SegmentAutomatic_AutoSegmentID,event_data)
        
        % ...if at least one element length has been submitted to the
        % vertex spacing historam
        if n_Lxyz1D > 0
            
            % Segment indices
            Pairs2D = zeros(vt,MaxNumSegsPerNode); %[vertices,segments per vertex]
            % Segments per vertex
            Pairs = zeros(1,vt); %[1,2,3,...]
            % Number of segments found
            Seg = 0; %[1,2,3,...]
            
            % ...number of element lengths specified for auto segment
            % detection
            for b=1:n_Lxyz1D
                
                % Vertex spacings that satisfy the element spacing
                % {Lxyz1D(b)} bounds. Spacings were updated the last with
                % that the spacing histogram was updated
                idy = find( (Lxyz(1:nIdx,3)' < (Lxyz1D(b)+dLxyz1D(b))) &...
                    (Lxyz(1:nIdx,3)' > (Lxyz1D(b)-dLxyz1D(b))) ); %[idx]
                
                if isempty(idy) == 0
                    % Further testing of determined segments
                    for c=1:length(idy)
                        % Advance the segment number for the current vertex
                        Pairs(Lxyz(idy(c),1)) = Pairs(Lxyz(idy(c),1)) + 1; %[1,2,3,...]
                        % Add segment to the list
                        Pairs2D(Lxyz(idy(c),1),Pairs(Lxyz(idy(c),1))) = Lxyz(idy(c),2); %[idx]
                        % Additional registration for the new segment
                        Seg = Seg + 1; %[1,2,3,...]
                    end
                end
                
            end
        end
        
        if Seg == 0
            warndlg('No segments were found','!! Warning !!')
        end
        
    end

% Identify segments based on the specified element lengths in the vertex
% spacing histogram
    function AutoExposureOrder(GUI_SegmentAutomatic_AutoExposureOrder,event_data)
        
        if sum(sCube) == 0
            warndlg({'A substrate contact vertex';'has not been defined.'},'!! Warning !!')
        end
        if Seg == 0
            warndlg('No segments exist','!! Warning !!')
        end
   
        % ...if segments were found.
        if Seg > 0 && sum(sCube) > 0
            
            % Indices of substrate contact vertices
            idxs = find(sCube == 1); %[idx]
            % Number of substrate contact vertices
            nSv = length(idxs); %[1,2,3,...]
            
            % Prevents segment double counting
            OneCount2D = zeros(size(Pairs2D)); %[0/1]
            
            % Total number of segments
            nSeg = 0; %[1,2,3,...]
            
            % Clear current segments, if they exist
            s_i(:,:) = 0; %[idx]
            s_f(:,:) = 0; %[idx]
            eIdx(:,:) = 0; %[idx]
            n_e(:) = 0; %[idx]
            
            % The search for
            % segments/pillar begins at each vertex, defined by the User, as
            % touching the surface.  All segments that have this vertex,
            % specified as the initial vertex for the segment, are
            % associated with the current exposure level.  These segments
            % have already been tested for element length in the function
            % {AutoSegmentID}.  The list of vertices that terminate these
            % segments populate a new list of vertices that will serve as
            % the initial vertices on the next exposure level.  This
            % process repeats until no further segments are detected.
            for a=1:nSv
                
                % Current level number
                lvl = 0; %[1,2,3,...]
                
                % Initial vertices for the level
                VperL(:) = 0; %[idx]
                VperL(1) = idxs(a); %[idx]
                % Number of vertices for this level
                nVerts = 1; %[1,2,3,...]
                
                % ...segment identification continues until no more
                % vertices remain.
                while nVerts > 0
                    
                    % New level for exposure
                    lvl = lvl + 1; %[1,2,3,...]
                    % Maximum level number
                    if lvl > MaxExposureLevel
                        MaxExposureLevel = lvl; %[1,2,3,...]
                    end
                    
                    % Number of vertices for this level (reset)
                    nVerts_Next = 0; %[1,2,3,...]
                    
                    % ...number of initial vertices for new level
                    for b=1:nVerts
                        % ...per segment on this exposure level {lvl}
                        for c=1:Pairs(VperL(b))
                            
                            % Prevents the double counting of segments
                            if OneCount2D(VperL(b),c) == 0
                                
                                % New exposure segment, per level
                                Segs = n_e(lvl) + 1; %[1,2,3,...]
                                % Total number of segments in 3D object
                                nSeg = nSeg + 1; %[1,2,3,...]
                                
                                % Segment initial vertex
                                s_i(lvl,Segs) = VperL(b); %[1,2,3,...]
                                % Segments final vertex
                                s_f(lvl,Segs) = Pairs2D(VperL(b),c); %[1,2,3,...]
                                % Number of segments per level
                                n_e(lvl) = n_e(lvl) + 1; %[1,2,3,...]
                                % Unique segments ID
                                eIdx(lvl,Segs) = nSeg; %[idx]
                                
                                % Unique registration of exposure segment; prevents
                                % double counting
                                OneCount2D(VperL(b),c) = 1; %[0/1]
                                
                                % Number of initial vertices for the next level
                                % (temporary)
                                nVerts_Next = nVerts_Next + 1; %[1,2,3,...]
                                % Initial vertices for the next level (temporary)
                                VperL_Next(nVerts_Next) = Pairs2D(VperL(b),c); %[]
                                
                            end
                        end
                    end
                    
                    % Number of initial vertices for the next level
                    nVerts = nVerts_Next; %[1,2,3,...]
                    % Initial vertices for the next level
                    VperL = VperL_Next; %[idx]
                    
                    % Number of initial vertices for the next level
                    % (temporary, reset)
                    nVerts_Next = 0; %[]
                    % Initial vertices for the next level (temporary, reset)
                    VperL_Next(:) = 0; %[]
                    
                end
                
            end
           
            % Number of exposure levels
            MaxExposureLevel = MaxExposureLevel - 1; %[idx]
            lvl = MaxExposureLevel; %[idx]
            
            % Maximum number of exposures, per level, over all current
            % levels
            MaxSegsPerLevel = max(n_e(1:MaxExposureLevel)); %[1,2,3,...]
            
            % Visible vertices
            VisibleVertices
            % Register new design step and save design
            UponNewAction
            % Set level indicator to maximum level number following
            % auto-segment find operation
            set(GUI_SegmentManual_lvl,'String',num2str(MaxExposureLevel));
            % Table of segments per level
            FillEdgesSpreadSheet
            % Refresh the vertices and segments in 2D and 3D
            ReRender
            
        end
        
    end




% GUI_Expose_...{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% The beam displacement will be rendered, per shot, as a red circle on the
% 3D plot showing the User the serial and/or parallel nature of the shot
% distribution
    function VisualizeExposure(GUI_Expose_VisualizeExposure,event_data)
        ShowShots = logical(get(GUI_Expose_VisualizeExposure,'value')); %[0/1]
    end

% Array exposure initialized.  Program will look to ArrayRequest.txt for
% instructions
    function ArrayExposure(GUI_Expose_Arrays,event_data)
        TrigArrayExp = logical(get(GUI_Expose_Arrays,'value')); %[0/1]
    end

% Invert the sign of the {y}-coordinate for FEI 12-bit systems
    function Flip_y(GUI_Expose_Flip_y,event_data)
        yInversion = logical(get(GUI_Expose_Flip_y,'value')); %[0/1]
        % Register new design step and save design
        UponNewAction
    end

% File name UI control
    function ExposureFileName(GUI_Expose_ExposureFileName,event_data) %#ok<*INUSD>
        FileName = get(GUI_Expose_ExposureFileName,'string'); %[str]
    end

% Pixel point pitch value for FEBID.  A constant for all exposure elements
    function PixelPointPitch(GUI_Expose_PixelPointPitch,event_data)
        
        % Pixel point pitch value update
        ds = str2double(get(GUI_Expose_PixelPointPitch,'string')); %[nm]
        
        % Force any simple proximity correction into increments of {ds}
        PrxCi = ds.*round(PrxCi./ds); %[{ds} nm]
        PrxCf = ds.*round(PrxCf./ds); %[{ds} nm]
        % Register new design step and save design
        UponNewAction
    end

% Magnification and Image size/magnification factor update based on
% Microscope
    function MagnificationSetting(~,event_data)
        % Image pixel size {PoP >= iPoP}
        iPoP = str2double(get(GUI_Expose_iPoP,'String'));
        % Recalculate the magnification required for exposure
        Mag = round( MagHFW./(iPoP.*(pow2_Bits).*0.001) ); %[um/um]
        % Update Mag/HFW text field
        set(GUI_Expose_MagHFW,'String',num2str(MagHFW))
        % Update the Mag text field
        set(GUI_Expose_Mag,'String',sprintf('%gx',Mag))
    end

% Beam dwell artifact position for FEI exposures
    function ArtifactDwell(~,event_data)
        % Update remote beam dwell position
        xArtifact = str2double(get(GUI_Expose_xBad,'string')); %[nm]
        yArtifact = str2double(get(GUI_Expose_yBad,'string')); %[nm]
        % Plot updated position
        if xArtifact > xMin && xArtifact < xMax &&...
                yArtifact > yMin && yArtifact < yMax
            set(xyBadObj,'XData',xArtifact,'YData',yArtifact,'Visible','On');
        else
            disp('Artifact position has been moved outside the field of view');
            set(xyBadObj,'Visible','Off')
        end
        % Register new design step and save design
        UponNewAction
    end

% Toggle switch for FEI patterning bit depth
    function SwitchForBitDepth(~,event_data)
        
        if BitDepth == 12
            set(GUI_Expose_sOff,'CData',sOff);
        elseif BitDepth == 16
            set(GUI_Expose_sOff,'CData',sOn);
        end
        % Update the magnification setting
            MagnificationSetting
    end

% Toggle switch for 3D plot zoom
    function Zoom3Dplot(~,event_data)
        
        % Toggle switch for magnified 3D view of CAD object
        Plot3D = logical(get(GUI_VertexDefine_Plot3D,'Value')); %0/1]
        
        % Demagnify the 3D plot
        if Plot3D == true
            set(xyzAxis,'Position',fGUI.*[625 zPivPlot 500 500],'Parent',MainFig);
            set(GUI_ZoomPanel,'Visible','off')
            set(GUI_VertexDefine_Plot3D,'CData',sOff);
            
            % Magnify the 3D plot
        elseif Plot3D == false
            set(GUI_ZoomPanel,'Visible','on','BackgroundColor',FigHue)
            set(xyzAxis,'Position',fGUI.*xyzAxisPos,'Parent',GUI_ZoomPanel)
            axes(xyzAxis)
            set(GUI_VertexDefine_Plot3D,'CData',sOn);
        end
        
    end

% Creation of CAD file for FEBID experiment
    function CADbuild(GUI_Expose_CAD,event_data)
        
        % Register new design step and save design
        UponNewAction
        
        % Load experimentally determined calibration file or fitted data to
        % experimental calibration curve
        if CalibrateByExpData == 1
            
            cd(SupportingFilesFolderName)
            ActionFileName = sprintf('%s.txt',Recipes{1,Recipe});
            New_xyz = dlmread(ActionFileName);
            cd ../
            
            % Dwell time
            tD1D = New_xyz(:,1); %[ms]
            % Segment angle
            Zeta1D = New_xyz(:,2); %[deg]
            
            % Use fitted data by constructing fine extrapolation
        elseif CalibrateByExpData == 0
            
            % Dwell times
            tD1D = xFit(ForbiddenTau:length(xFit)); %[ms]
            % Segment angles
            Zeta1D = zFit(ForbiddenTau:length(xFit)); %[ms]
        end
        
        % Determine the minimum allowed segment angle from the user defined
        % input box
        TauMinSet
        
        % Array Exposure
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        if TrigArrayExp == true
            % Text file (read)
            DuplicationFileName = 'ArrayRequest.txt';
            
            % Read file
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % Open array duplication file
            DuplicationFileID = fopen(DuplicationFileName,'r');
            % Extract parameter from the duplication file
            CellData = textscan(DuplicationFileID, ...
                '%*s %f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %f', ...
                'Delimiter', '\n', ...
                'CollectOutput',true);
            % Close the array duplication file
            fclose(DuplicationFileID);
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            
            % 3D Object, 2D array exposure basis vectors (initialize)
            xBasis = zeros(1,2);   yBasis = zeros(1,2); %[nm]
            
            % Basis vector #1
            xBasis(1) = CellData{1}(1,1).*cos(CellData{1}(1,2).*pi./180); %[nm]
            yBasis(1) = CellData{1}(1,1).*sin(CellData{1}(1,2).*pi./180); %[nm]
            % Number of {x} nodes
            xArrayNodes = CellData{1}(1,3); %[1,2,3,...]
            
            % Basis vector #2
            xBasis(2) = CellData{1}(1,4).*cos(CellData{1}(1,5).*pi./180); %[nm]
            yBasis(2) = CellData{1}(1,4).*sin(CellData{1}(1,5).*pi./180); %[nm]
            % Array limits in {y}
            yArrayNodes = CellData{1}(1,6); %[1,2,3,...]
            
            % Array exposure type (continuous vs intermittent)
            ArrayIntermittent = CellData{1}(1,7); %[0/1]
            
            % Number of array elements
            xyNodes = 0; %[1,2,3,...]
            
            % 2D array positions
            xArray = zeros(1,xyNodes); %[nm]
            yArray = zeros(1,xyNodes); %[nm]
            for p=1:yArrayNodes
                for q=1:xArrayNodes
                    % New node registered
                    xyNodes = xyNodes + 1; %[1,2,3,...]
                    % Array position
                    xArray(xyNodes) = xBasis(1).*(q - 1) + xBasis(2).*(p - 1); %[nm]
                    yArray(xyNodes) = yBasis(1).*(q - 1) + yBasis(2).*(p - 1); %[nm]
                end
            end
            
            % Center the array in a virtual field of view
            xArray = xArray - mean(xArray); %[nm]
            yArray = yArray - mean(yArray); %[nm]
            
            % Half Horizontal field width (HFW)
            hHFW = (iPoP.*(pow2_Bits))./2; %[nm]
            
            % 2D array exposure elements that fall within the FEBID
            % write field
            idx = find(xArray > -hHFW & xArray < hHFW &...
                yArray > -hHFW*pAspRatio & yArray < hHFW*pAspRatio);
            
            % Final 2D array points after consideration of boundaries
            xArray = round(xArray(idx)); %[nm]
            yArray = round(yArray(idx)); %[nm]
            xyNodes = length(xArray); %[]
            
            % Multi-element exposure
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % Replication number
            s = 0; %[1,2,3,...]
            % 3D object vertices
            xCube_0 = xCube(1:vt);   yCube_0 = yCube(1:vt); %[nm]
            zCube_0 = zCube(1:vt); %[nm]
            sCube_0 = sCube(1:vt); %[0/1]
            
            % ...2D array elements
            for p=1:xyNodes
                
                % Vertex replication
                % oooooooooooooooooooooooooooooooooooooooooooooooo
                s = p - 1; %[0,1,2,...]
                % Coordinate replication
                xCube(s.*vt + (1:vt)) = xCube_0 + xArray(p); %[nm]
                yCube(s.*vt + (1:vt)) = yCube_0 + yArray(p); %[nm]
                zCube(s.*vt + (1:vt)) = zCube_0; %[nm]
                
                % Surface contact replication
                sCube(s.*vt + (1:vt)) = sCube_0; %[0/1]
                % oooooooooooooooooooooooooooooooooooooooooooooooo
                
                % Segment replication
                % oooooooooooooooooooooooooooooooooooooooooooooooo
                % Intermittent array exposure
                if ArrayIntermittent == 1
                    % ...exposure levels
                    for t1=1:MaxExposureLevel
                        % Segment indices replication
                        s_i(t1,s.*n_e(t1) + (1:n_e(t1))) =...
                            s_i(t1,1:n_e(t1)) + s.*vt; %[idx]
                        s_f(t1,s.*n_e(t1) + (1:n_e(t1))) =...
                            s_f(t1,1:n_e(t1)) + s.*vt; %[idx]
                        % Segment identifier replication
                        eIdx(t1,s.*n_e(t1) + (1:n_e(t1))) =...
                            eIdx(t1,1:n_e(t1)) + s.*nSeg; %[idx]
                    end
                else % Continuous array exposure
                    % ...exposure levels
                    for t1=1:MaxExposureLevel
                        % Segment indices replication
                        s_i(t1 + s.*MaxExposureLevel,1:n_e(t1)) =...
                            s_i(t1,1:n_e(t1)) + s.*vt; %[idx]
                        s_f(t1 + s.*MaxExposureLevel,1:n_e(t1)) =...
                            s_f(t1,1:n_e(t1)) + s.*vt; %[idx]
                        % Segment identifier replication
                        eIdx(t1 + s.*MaxExposureLevel,1:n_e(t1)) =...
                            eIdx(t1,1:n_e(t1)) + s.*nSeg; %[idx]
                        % Number of segments per level
                        n_e(t1 + s.*MaxExposureLevel) = n_e(t1); %[idx]
                    end
                end
                % oooooooooooooooooooooooooooooooooooooooooooooooo
                
            end
            
            % Intermittent array exposure
            if ArrayIntermittent == 1
                % Number of segments per level (update)
                n_e(1:MaxExposureLevel) = n_e(1:MaxExposureLevel).*xyNodes; %[1,2,3,...]
                % Maximum number of shots per level
                MaxSegsPerLevel = max(n_e(1:MaxExposureLevel)); %[1,2,3,...]
            else % Continuous array exposure
                % Number of exposure levels
                MaxExposureLevel = MaxExposureLevel.*xyNodes; %[1,2,3,...]
            end
            
            % Number of vertices (update)
            vt = vt.*xyNodes; %[1,2,3,...]
            % Next vertex update
            nv = vt + 1; %[1,2,3,...]
            % Number of segments (update)
            nSeg = nSeg.*xyNodes; %[1,2,3,...]
            
            s_i = round(s_i);   s_f = round(s_f);   eIdx = round(eIdx);   n_e = round(n_e);
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            
            % Center array in the {x} dimension
            xCube(1:vt) = xCube(1:vt) - mean(xCube_0); %[nm]
            % Center array in the {y} dimension
            yCube(1:vt) = yCube(1:vt) - mean(yCube_0); %[nm]
            
            % Array exposure map
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            arrayFig = figure('Name','Array Map','NumberTitle','off',...
                'MenuBar','none');
            set(arrayFig,'Color',FigHue,...
                'Position',fGUI.*[250 50 800 800],'Renderer','opengl')
            hold on;
            % ...number of levels
            for q=1:MaxExposureLevel
                for p=1:n_e(q)
                    plot([xCube(s_i(q,p)) xCube(s_f(q,p))] + hHFW,...
                        [yCube(s_i(q,p)) yCube(s_f(q,p))] + hHFW.*pAspRatio,'-',...
                        'LineWidth',2,'Color', iMap(q,:))
                end
            end
            set(gca,'FontSize',(FS+5),'Box','on','LineWidth',2);
            box on
            axis equal
            axis([0 2*hHFW 0 2*hHFW*pAspRatio])
            ylabel('y (nm)','FontSize',(FS+7))
            xlabel('x (nm)','FontSize',(FS+7))
            cd(DesignFolderName)
            saveas(arrayFig,'ArrayExposureMap.tif');
            cd ../
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        end
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

        
        % Segment angles (with respect to the {xy} plane)
        Zeta = zeros(MaxExposureLevel,MaxSegsPerLevel); %[deg]
        % Segment-dependent dwell time
        tDe = zeros(MaxExposureLevel,MaxSegsPerLevel); %[ms]
        % Segment-dependent dwell time (no FEI filter applied to restrict
        % the dwell time to the maximum allowable value)
        tDe_Raw = zeros(MaxExposureLevel,MaxSegsPerLevel); %[ms]
        
        
        % Experimental output variables
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        % Beam shot position storage (temporary)
        xBeamer = zeros(nSeg,NumShots_Limit); %[nm]
        yBeamer= xBeamer;   zBeamer = xBeamer; %[nm]
        % Element number storage (temporary)
        eBeamer = zeros(1,NumShots_Limit); %[idx]
        % Number of shots per element "pillar/segment"
        BeamLen = zeros(MaxExposureLevel,MaxSegsPerLevel); %[nm]
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        
        
        % {x} coordinates, per segment, after expansion due to relatively
        % large dwell time
        x1Dn = zeros(1,NumShots_Limit); %[nm]
        % {y} coordinates, per segment, after expansion due to relatively
        % large dwell time
        y1Dn = zeros(1,NumShots_Limit); %[nm]
        
        % Linear extrapolation parameters for dwell times that exceed the
        % range of the current calbration curve
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        % dZeta/dt slope extrapolation
        mZeta = (4./7).*( Zeta1D(length(Zeta1D)) - Zeta1D(length(Zeta1D) - 1) )./...
            ( tD1D(length(Zeta1D)) - tD1D(length(Zeta1D) - 1) ) +...
            (2./7).*( Zeta1D(length(Zeta1D)) - Zeta1D(length(Zeta1D) - 2) )./...
            (tD1D(length(Zeta1D)) - tD1D(length(Zeta1D) - 2)) +...
            (1./7).*( Zeta1D(length(Zeta1D)) - Zeta1D(length(Zeta1D) - 3) )./...
            (tD1D(length(Zeta1D)) - tD1D(length(Zeta1D) - 3)); %[deg/ms]
        % Zeta, at t=0, intercept extrapolation
        bZeta = Zeta1D(length(Zeta1D)) - mZeta.*tD1D(length(Zeta1D)); %[deg]
        
        
        % ...# of exposure levels
        for p=1:MaxExposureLevel
            
            % ...segments per exposure level
            for q=1:n_e(p)
                
                % !!!!! {Pillar} !!!!! qualification
                if sqrt( ((xCube(s_f(p,q)) - xCube(s_i(p,q))).^2) +...
                        ((yCube(s_f(p,q)) - yCube(s_i(p,q))).^2) ) <=...
                        iPoP
                    
                    % Number of dwells for pure vertical growth using the
                    % fixed dwell time of {tdPillar}
                    ds1Dlen = round( (zCube(s_f(p,q)) - zCube(s_i(p,q)))./...
                        (vDz.*tdPillar.*0.001) ); %[]
                    % Dwell time for pillar element
                    tDe(p,q) = tdPillar; %[ms]
                    % Dwell time for pillar element
                    tDe_Raw(p,q) = tDe(p,q); %[ms]
                    % Pillar angle
                    Zeta(p,q) = 90; %[degrees]
                    
                    % Shot generation
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
                    % Linear index of element(p,q)
                    idx = eIdx(p,q); %[idx]
                    % Generate exposure shots
                    xBeamer(idx,1:ds1Dlen) = xCube(s_i(p,q)); %[nm]
                    yBeamer(idx,1:ds1Dlen) = yCube(s_i(p,q)); %[nm]
                    zBeamer(idx,1:ds1Dlen) = zCube(s_i(p,q)) +...
                        (1:ds1Dlen).*vDz.*tdPillar.*0.001; %[nm]
                    % Element number for shot batch
                    eBeamer(idx,1:ds1Dlen) = eIdx(p,q); %[idx]
                    % % # of pixel shots for the pillar
                    BeamLen(p,q) = ds1Dlen; %[]
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
                     
                else % !!!!! {Segment} !!!!! qualification
                    
                    % Segment length & the segment length projected in the
                    % focal plane
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
                    % Projected segment length in the {xy} plane
                    L_xy = sqrt( (xCube(s_f(p,q)) - xCube(s_i(p,q))).^2 +...
                        (yCube(s_f(p,q)) - yCube(s_i(p,q))).^2 ); %[nm]
                    % Segment length
                    L_xyz = sqrt( (xCube(s_f(p,q)) - xCube(s_i(p,q))).^2 +...
                        (yCube(s_f(p,q)) - yCube(s_i(p,q))).^2 +...
                        (zCube(s_f(p,q)) - zCube(s_i(p,q))).^2 ); %[nm]
                    % Sign {x}
                    sx = sign( xCube(s_f(p,q)) - xCube(s_i(p,q)) ); %[+/-]
                    % Sign {y}
                    sy = sign( yCube(s_f(p,q)) - yCube(s_i(p,q)) ); %[+/-]
                    
                    
                    % In-plane {xy} shot steps
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
                    % In-plane {xy} slope
                    slope = ( yCube(s_f(p,q)) - yCube(s_i(p,q)) )./...
                        ( xCube(s_f(p,q)) - xCube(s_i(p,q)) ); %[nm/nm]
                    
                    % Simple proximity correction
                    if ProxCorrOn == true
                        
                        % (1) The initial segment pixel is always
                        % skipped to avoid over exposure.  However, an
                        % additional increment of {PrxCi} is
                        % applied if multiple segments diverge from the
                        % same node
                        % Diverging, connected segments detected
                        Div_Idxs = sum(s_i(p,q) == s_i(p,1:n_e(p))) > 1; %[idx]
                        % Initial segment exposure position
                        iSeg = ds+Div_Idxs.*PrxCi; %[nm]
                        
                        % (2) The final segment pixel is always
                        % included unless multiple segments converage
                        % at the final node.  In this case of multiple
                        % segments, {PrxCf} is subtracted from the
                        % final node position.
                        % Converging, connected segments detected
                        Conv_Idxs = sum(s_f(p,q) == s_f(p,1:n_e(p))) > 1; %[idx]
                        % Final segment exposure position
                        fSeg = Conv_Idxs.*PrxCf; %[nm]
                        
                        % (3) Real segment pixel displacements are not in perfect
                        % increments of {1nm}.  The pitch is adjusted
                        % slightly to achieve a uniform pitch along the
                        % segment length.  {ceil} function is used so
                        % the pitch will be slightly less than {<~1nm}.
                        L_xy_Real = L_xy - iSeg - fSeg; %[nm]
                        % Actual pixel point pitch for the current segment
                        s_PoP(p,q) = L_xy_Real./...
                            ceil(L_xy_Real./ds); %[nm]
                        
                        % In-plane edge shot vector
                        ds1D = iSeg:s_PoP(p,q):L_xy_Real; %[nm]
                        
                    elseif ProxCorrOn == false
                        % In-plane edge shot vector
                        ds1D = ds:ds:round( L_xy./ds )*ds; %[nm]
                    end
                    ds1Dlen = length(ds1D); %[]
                    
                    % In-plane increment vectors (consistant with {ds})
                    x1D = sx.*ds1D./sqrt(1 + slope.^2); %[nm]
                    y1D = sy.*sqrt( ds1D.^2 - x1D.^2 ); %[nm]
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
                    
                    % Beam Dwell time calculation
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
                    % Segment angle
                    Zeta(p,q) = acos( L_xy./L_xyz ).*180./pi; %[deg]
                    
                    
                    % Dwell time for exposure
                    % oooooooooooooooooooooooooooooooooooooooooooooooo
                    % Segment angle minimum -> force to minimum
                    if Zeta(p,q) <= ZetaLimit
                        Zeta(p,q) = ZetaLimit; %[deg]
                        % Beam dwell time (minimum value)
                        tDe(p,q) = TauMin; %[ms]
                        
                        % Segment angle maximum -> extrapolation
                    elseif Zeta(p,q) >= Zeta1D(length(Zeta1D))
                        % Beam dwell time (extrapolation beyond known maximum)
                        tDe(p,q) = f_tDe.*( Zeta(p,q) - bZeta )./mZeta; %[ms]
                        
                        % Segment angle interpolation
                    else
                        idxFile = sum(Zeta(p,q) > Zeta1D); %[idx]
                        % Beam dwell time (Look Up Table)
                        tDe(p,q) = f_tDe.*( tD1D(idxFile) +...
                            (Zeta(p,q) - Zeta1D(idxFile))./(Zeta1D(idxFile+1) - Zeta1D(idxFile)).*...
                            (tD1D(idxFile+1) - tD1D(idxFile)) ); %[ms]
                    end
                    % ooooooooooooooooooooooooooooooooooooooooooooooo
                    
                    % Segment angle and dwell time plotted on the calibration
                    % curve
                    plot(tzAxis,tDe(p,q),Zeta(p,q),'+r','MarkerSize',MS_Interp)
                    
                    
                    
                    if ProxCorrOn == true
                        % Conserves the beam speed in the event that
                        % proximity correction is applied
                        tDe(p,q) = tDe(p,q).*(s_PoP(p,q)./ds); %[nm]
                    end
                    
                    % Beam dwell time (without imposing a maximum dwell
                    % time).  If a maximum exists, multiple shots per pixel
                    % are imposed.
                    tDe_Raw(p,q) = tDe(p,q); %[ms]
                    
                    if PatterningEngine == 2
                        % NVPE patterning requirement - constant dwell
                        % time for all exposures
                        tdMax = tdMax_NVPE; %[ms]
                    elseif PatterningEngine == 1
                        % FEI patterning requirment - upper limit on
                        % the dwell time
                        tdMax = tdMax_FEI; %[ms]
                    end
                    
                    % Beam dwell time special conditions...
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    % Trigger for dwell time exceeding the FEI tool
                    % maximum dwell time
                    Xpnd = false; %[0/1]
                    if tDe(p,q) > tdMax
                        % Trigger coordinate expansion and dwell time
                        % modulation per segment
                        Xpnd = true; %[0/1]
                    end
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    
                    
                    % Impose multiple FEBID exposures per pixel
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    if Xpnd == true
                        
                        % Number of dwell time increments, in units
                        % of the maximum, per
                        % static dwell, required to achieve the required
                        % segment angle
                        f_tau = tDe(p,q)./tdMax; %[]
                        % Counter for expanded coordinates
                        u3 = 0; %[1,2,3,...
                        % ...current number of coordinates for the
                        % segment-of-interest
                        for u1=1:ds1Dlen
                            % ...New coordinates required per the old
                            % coordinate
                            for u2=1:ceil(f_tau)
                                % Register the new coordinate
                                u3 = u3+1; %[1,2,3,...]
                                % Additional {x} coordinate
                                x1Dn(u3) = x1D(u1); %[nm]
                                % Additional {y} coordinate
                                y1Dn(u3) = y1D(u1); %[nm]
                            end
                        end
                        % Repopulate the coordinates
                        x1D = x1Dn(1:u3); %[nm]
                        y1D = y1Dn(1:u3); %[nm]
                        % Updated number of coordinates for the segment
                        ds1Dlen = u3; %[1,2,3,...]
                        
                        % Beam dwell time (averaged over new points per old
                        % dwell)
                        if PatterningEngine == 2
                            % NVPE patterning requirement
                            tDe(p,q) = tdMax; %[ms]
                        elseif PatterningEngine == 1
                            % FEI patterning requirement
                            tDe(p,q) = tDe(p,q)./ceil(f_tau); %[ms]
                        end
                        
                    end
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    
                    
                    % FEBID pixel exposures for experiments
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    % Linear index of segment(p,q)
                    idx = eIdx(p,q); %[idx]
                    % Generate segment exposure pixels
                    xBeamer(idx,1:ds1Dlen) = xCube(s_i(p,q)) + x1D; %[nm]
                    yBeamer(idx,1:ds1Dlen) = yCube(s_i(p,q)) + y1D; %[nm]
                    % Dwell time did not exceed the maximum
                    if Xpnd == false
                        zBeamer(idx,1:ds1Dlen) = zCube(s_i(p,q)) +...
                            ds.*(1:ds1Dlen).*tan(Zeta(p,q).*pi./180); %[nm]
                        % Dwell time exceeded the maximum
                    elseif Xpnd == true
                        zBeamer(idx,1:ds1Dlen) = zCube(s_i(p,q)) +...
                            (ds./ceil(f_tau)).*(1:ds1Dlen).*tan(Zeta(p,q).*pi./180); %[nm]
                    end
                    % Element number for segment exposure
                    eBeamer(idx,1:ds1Dlen) = eIdx(p,q); %[idx]
                    % % # of shots per segment
                    BeamLen(p,q) = ds1Dlen; %[]
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    
                end
                
            end
        end
        
        
        % Computer Aided Design Visualization & Final Exposure
        % Parameters
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        cd(DesignFolderName)
        
        ExposureData = zeros(nSeg,12); %[ ]
        
        % Current segment number counter
        nSeg_t = 0; %[]
        % ...# of exposure levels
        for p=1:MaxExposureLevel
            % ...segments per exposure level
            for q=1:n_e(p)
                
                % Current segment number
                nSeg_t = nSeg_t + 1; %[1,2,3,...]
                
                % Segment exposure index
                ExposureData(nSeg_t,1) = eIdx(p,q); %[idx]
                % Exposure level
                ExposureData(nSeg_t,2) = p; %[idx]
                % Segment number in level
                ExposureData(nSeg_t,3) = q; %[idx]
                
                % Initial segment position
                ExposureData(nSeg_t,4) = xCube(s_i(p,q)); %[nm]
                ExposureData(nSeg_t,5) = yCube(s_i(p,q)); %[nm]
                ExposureData(nSeg_t,6) = zCube(s_i(p,q)); %[nm]
                
                % Final segment position
                ExposureData(nSeg_t,7) = xCube(s_f(p,q)); %[nm]
                ExposureData(nSeg_t,8) = yCube(s_f(p,q)); %[nm]
                ExposureData(nSeg_t,9) = zCube(s_f(p,q)); %[nm]
                
                % Exposure dwell time
                ExposureData(nSeg_t,10) = tDe_Raw(p,q); %[ms]
                % Segment angle
                ExposureData(nSeg_t,11) = Zeta(p,q); %[deg]
                % Practical exposure dwell time (maximum dwell time
                % enforced
                ExposureData(nSeg_t,12) = tDe(p,q); %[ms]
                
            end
        end
        dlmwrite('FEBiD_3D_ExpFile.txt',ExposureData);
        
        cd ../
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

        
        % Total # of exposures coordinates
        Dwells = sum(sum(BeamLen)); %[1,2,3,...]
        % Beam position list {x,y}
        xyScan = zeros(2,Dwells); %[nm]
        % Anticipated {z} of deposit predicted, based on the calibration
        % curve
        zScan = zeros(1,Dwells); %[nm]
        % Beam dwell time per shot
        tdScan = zeros(1,Dwells); %[ms]
        % Camera trigger (for exposure render)
        pDwells = zeros(1,Dwells); %[0/1]
        
        % Camera exposure index
        Clic = 0; %[idx]
        % Camera exposure counter
        s2 = 0; %[1,2,3,...]
        
        % Shot number (serial)
        s = 0; %[1,2,3,...]
        
        % ...exposure level
        for p=1:MaxExposureLevel
            
            % 3D Object total FEBID exposure sequence
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % ...maximum number of exposures per segment among all segments
            % on level {p}
            for u=1:max(BeamLen(p,:))
                
                % Advance image exposure increment
                Clic = Clic + 1; %[1,2,3,...]
                
                % !!!!! Intermittent exposure !!!!!
                
                % ...per segment on exposure level {p}
                for q=1:n_e(p)
                    
                    % Linear index of element(p,q)
                    idx = eIdx(p,q); %[idx]
                    
                    % ...not all elements will have the same length 
                    if u <= BeamLen(p,q)
                        
                        % Single-exposure
                        % oooooooooooooooooooooooooooooooooooooooooooo
                        % New shot #
                        s = s + 1; %[1,2,3,...]
                        % Shot coordinates
                        xyScan(1,s) = xBeamer(idx,u); %[nm]
                        xyScan(2,s) = yBeamer(idx,u); %[nm]
                        % Shot "height" - anticipated position of deposit
                        % based on calibration curve
                        zScan(1,s) = zBeamer(idx,u); %[nm]
                        % Shot dwell time
                        tdScan(1,s) = tDe(p,q); %[ms]
                        % oooooooooooooooooooooooooooooooooooooooooooo
                        
                        % Simulation image exposure
                        % oooooooooooooooooooooooooooooooooooooooooooo
                        if Clic == sPerLevel
                            s2 = s2 + 1; %[1,2,3,...]
                            pDwells(s2) = s; %[0/1]
                        end
     
                    end
                    
                end
                
                % Level image exposure trigger (reset)
                % oooooooooooooooooooooooooooooooooooooooooooooooo
                if Clic == sPerLevel
                    Clic = 0; %[0/1]
                end
                
            end
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % {end} Structural segment for this level
            
        end
        
        % Dwell time per shot
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        tauFig = figure('Name','Electron beam dwell map','NumberTitle','off',...
            'MenuBar','none');
        set(tauFig,'Color',FigHue,'Position',fGUI.*[250 50 800 800],'Renderer','opengl')
        plot(tdScan(1,1:Dwells),'LineWidth',2)
        set(gca,'FontSize',(FS+5),'Box','on','LineWidth',2);
        axis([0 Dwells 0 ceil(max(tdScan))])
        box on
        ylabel('\tau_d (ms)','FontSize',(FS+9))
        xlabel('beam shot number','FontSize',(FS+7))
        TauPlotName = 'TauPlot_FEI.tif';
        cd(DesignFolderName)
        saveas(gcf,TauPlotName);
        cd ../
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        
        
        % Render 3D shot distribution in {x,y,z} plot?
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        if ShowShots == true && TrigArrayExp == false
            figure(MainFig)
            % Superimpose the simulated deposition on the 3D plot
            Po = plot3(xyzAxis,xyScan(1,1),xyScan(2,1),zScan(1),'or',...
                'MarkerSize',MS_Render,...
                'MarkerFaceColor','r','MarkerEdgeColor',[0.5 0 0]);
            % Every exposure shown
            if AllShots == 1
                % All exposure pixels shown
                for qq=1:Dwells
                    set(Po,'XData',xyScan(1,qq),'YData',xyScan(2,qq),'ZData',zScan(qq));
                    drawnow
                end
                % Limited number of exposures shown
            elseif AllShots == 0
                % Only exposure pixels that will be data sampled during
                % the simulation (performed later) will be shown
                for qq=1:length(nonzeros(pDwells))
                    set(Po,'XData',xyScan(1,pDwells(qq)),...
                        'YData',xyScan(2,pDwells(qq)),'ZData',zScan(pDwells(qq)));
                    drawnow
                end
            end
            delete(Po)
        end
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        
        % Remove any zeros from dwell time sampling vector.  This
        % vector is used during the FEBID simulation and has no effect
        % on real FEBID exposures
        pDwells = nonzeros(pDwells); %[idx]
        
        % Save: Coordinates in the design folder
        cd(DesignFolderName)
        

        % General exposure file creation {name_GEF.txt}
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        % Export: ...to Experimental platform
        ActionFileName = sprintf('%s_GEF.txt',FileName);
        dlmwrite(ActionFileName,[xyScan' tdScan']); %[nm, nm, ms]
        
        
        % Stream file creation
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        % NVPE option for patterning
        if PatterningEngine == 2
            
            % NVPE Stream File (formatting)
            % oooooooooooooooooooooooooooooooooooooooooooooooooooo
            StreamFileName = 'NVPE.txt';
            ActionFileName = sprintf('%s_%s',FileName,StreamFileName);
            
            % Create stream file
            StreamFileID = fopen(ActionFileName,'w');
            fprintf(StreamFileID,'NPVE Deflection List \r\n'); %[NPVE]
            fprintf(StreamFileID,'UNITS=um \r\n'); %[NPVE]
            fprintf(StreamFileID,'START \r\n'); %[NPVE]
            
            % Units conversion
            xyScan = xyScan.*0.001; %[um]
            
            for n=1:size(xyScan,2)
                fprintf(StreamFileID,'%4.3f, %4.3f \r\n',...
                    xyScan(1,n),xyScan(2,n));
            end
            fprintf(StreamFileID,'END'); %[NPVE]
            fclose(StreamFileID);
            
            % NVPE dwell time exported to text file for
            % documentation
            dlmwrite('NVPE_DwellTime_ms.txt',tdMax_NVPE);
            
            % FEI option for patterning
        elseif PatterningEngine == 1
            
            % FEI Stream File (formatting)
            % oooooooooooooooooooooooooooooooooooooooooooooooooooo
            StreamFileName = 'FEI.str';
            ActionFileName = sprintf('%s_%s',FileName,StreamFileName);
            
            % Dwell time preparation
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % Dwell times in {PIA} increment
            tdScanCopy = ceil(tdScan./PIA).*PIA; %[ms]
            % Dwell times range bounds (2^12 = 4096)
            tdScanCopy = tdScanCopy.*(tdScanCopy >= PIA & tdScanCopy <= (4096.*PIA)) +...
                PIA.*(tdScanCopy < PIA) +...
                (4096.*PIA).*(tdScanCopy > (4096.*PIA)); %[ms]
            % Units conversions [100 ns]
            tdScanCopy = uint16(tdScanCopy.*10000); %[100 ns]
            
            % Coordinate preparation
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % Matches {x,y} coordinate orientations for FEBID CAD program
            % and FEI console
            if yInversion == true
                % Invert {y} sign
                xyScan_Temp = xyScan; %[nm]
                xyScan_Temp(2,:) = -xyScan_Temp(2,:); %[nm]
                % Coordinates in pixels (+ shift to SEM image center)
                xyScanCopy(1,:) = round(xyScan_Temp(1,:)./iPoP) + (pow2_Bits)./2; %[pixels]
                xyScanCopy(2,:) = round(xyScan_Temp(2,:)./iPoP) + (pAspRatio.*(pow2_Bits))./2; %[pixels]
                % {y}-axis sign inversion between FEBID CAD program
            % and FEI console
            elseif yInversion == false
                % Coordinates in pixels (+ shift to SEM image center)
                xyScanCopy(1,:) = round(xyScan(1,:)./iPoP) + (pow2_Bits)./2; %[pixels]
                xyScanCopy(2,:) = round(xyScan(2,:)./iPoP) + (pAspRatio.*(pow2_Bits))./2; %[pixels]
            end
            % Coordinates forced within range
            xyScanCopy(1,:) = uint16( xyScanCopy(1,:).*(xyScanCopy(1,:) >= 0 & xyScanCopy(1,:) <= (pow2_Bits)) +...
                0.*(xyScanCopy(1,:) < 0) + (pow2_Bits).*(xyScanCopy(1,:) > (pow2_Bits)) ); %[pix]
            xyScanCopy(2,:) = uint16( xyScanCopy(2,:).*(xyScanCopy(2,:) >= 0 & xyScanCopy(2,:) <= pAspRatio.*(pow2_Bits)) +...
                0.*(xyScanCopy(2,:) < 0) + pAspRatio.*(pow2_Bits).*(xyScanCopy(2,:) > pAspRatio.*(pow2_Bits)) ); %[pix]
            
            % Create stream file
            StreamFileID = fopen(ActionFileName,'w');
            % Stream file type
            if BitDepth == 12
                fprintf(StreamFileID,'%s \r\n','s'); %[FEI Nova 600]
            elseif BitDepth == 16
                fprintf(StreamFileID,'%s \r\n','s16'); %[FEI Nova 200/Helios]
            end
            % Number of exposure loops
            fprintf(StreamFileID,'%s \r\n','1'); %[1]
            % Number of exposures + 2 (+2 to avoid over exposure of
            % feature at the beginning and end of exposure)
            ExpFEI = length(tdScanCopy); %[1,2,3,...]
            if BitDepth == 12
                fprintf(StreamFileID,'%i \r\n',uint32(ExpFEI+2));
            elseif BitDepth == 16
                fprintf(StreamFileID,'%i \r\n',uint32(ExpFEI));
            end
            
            % Initial dwell (beam away from structure)
            if BitDepth == 12
                
                % {x} dwell artifact position
                xArtifactCopy = round(xArtifact./iPoP) + (pow2_Bits)./2; %[pixels]
                % Coordinates forced within range
                xArtifactCopy = uint16( xArtifactCopy.*(xArtifactCopy >= 0 &...
                    xArtifactCopy <= (pow2_Bits)) +...
                    0.*(xArtifactCopy < 0) +...
                    (pow2_Bits).*(xArtifactCopy > (pow2_Bits)) ); %[pix]
                
                % {y} dwell artifact position
                yArtifactCopy = round(yArtifact./iPoP) + pAspRatio.*(pow2_Bits)./2; %[pixels]
                % Coordinates forced within range
                yArtifactCopy = uint16( yArtifactCopy.*(yArtifactCopy >= 0 &...
                    yArtifactCopy <= pAspRatio.*(pow2_Bits)) +...
                    0.*(yArtifactCopy < 0) +...
                    pAspRatio.*(pow2_Bits).*(yArtifactCopy > pAspRatio.*(pow2_Bits)) ); %[pix]
                
                fprintf(StreamFileID,'%i %i %i \r\n',...
                    round(PIA.*10000),xArtifactCopy,yArtifactCopy); %[100 ns,nm,nm]
            end
            
            % ...dwell time list created in the stream file
            for n=1:ExpFEI
                
                if n < ExpFEI
                    fprintf(StreamFileID,'%i %i %i \r\n',...
                        tdScanCopy(1,n),xyScanCopy(1,n),xyScanCopy(2,n)); %[100 ns,nm,nm]
                elseif n == ExpFEI
                    if BitDepth == 12
                        % Beam blanking not available on the 12-bit
                        % system
                        fprintf(StreamFileID,'%i %i %i \r\n',...
                            tdScanCopy(1,n),xyScanCopy(1,n),xyScanCopy(2,n)); %[100 ns,nm,nm]
                        % Blank the beam for 16-bit system
                    elseif BitDepth == 16
                        fprintf(StreamFileID,'%i %i %i %i \r\n',...
                            tdScanCopy(1,n),xyScanCopy(1,n),xyScanCopy(2,n),0); %[100 ns,nm,nm]
                    end
                    
                end
            end
            
            % Final dwell time (beam away from structure)
            if BitDepth == 12
                fprintf(StreamFileID,'%i %i %i \r\n',...
                    round(PIA.*10000),xArtifactCopy,yArtifactCopy);
            end
            
            fclose(StreamFileID);
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        end
        
        cd ../
        
        % Important: Vertex and Segment data returns to single element
        % values, recovered from multi element definition
        ReLoadPastAction
        % Return to main figure
        figure(MainFig);
        
    end



% GUI_Calibration_...{Functions}
% Fitting of calibration curve
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

% Edit {VGR} for "pillar" exposure element
    function TypevDz(GUI_Calibration_TypevDz,event_data)
        
        % Retrieve the User-based {VGR} selection
        GetVar = str2double(get(GUI_Calibration_TypevDz,'string')); %[nm/s]
        if GetVar > 0
            vDz = GetVar; %[nm/s]
        end
        set(GUI_Calibration_TypevDz,'String',num2str(vDz));
        
        % Register new design step and save design
        UponNewAction
    end

% Edit {VGR} for calibration fitting
    function TypeVGR(GUI_Calibration_TypeVGR,event_data)
        
        % Retrieve the User-based {VGR} selection
        GetVar = str2double(get(GUI_Calibration_TypeVGR,'string')); %[nm/s]
        if GetVar > 0
            VGR = GetVar; %[nm/s]
        end
        set(GUI_Calibration_TypeVGR,'String',num2str(VGR)); %[nm/s]
        
        % Update range for {VGR} accordingly
        TypeVGR_Range
    end

% Edit {VGR} range for calibration fitting
    function TypeVGR_Range(~,event_data)
        
        % Retrieve the User-based {rVGR} selection
        GetVar = str2double(get(GUI_Calibration_TypeVGR_Range,'string')); %[nm/s]
        if GetVar > 0 && GetVar < VGR
            rVGR = GetVar; %[nm/s]
        elseif GetVar >= VGR
            rVGR = (VGR-dVGR); %[nm/s]
        end
        set(GUI_Calibration_TypeVGR_Range,'String',num2str(rVGR)); %[nm/s]
    end

% Edit {VGR} increment for calibration fitting
    function TypeVGR_Increment(GUI_Calibration_TypeVGR_Increment,event_data)
        
        % Retrieve the User-based {rVGR} selection
        GetVar = str2double(get(GUI_Calibration_TypeVGR_Increment,'string')); %[nm/s]
        if GetVar > 0 && GetVar <= rVGR
            dVGR = GetVar; %[nm/s]
        elseif GetVar > rVGR
            dVGR = rVGR; %[nm/s]
        end
        set(GUI_Calibration_TypeVGR_Increment,'String',num2str(dVGR)); %[nm/s]
    end

% Edit {pPD} for calibration fitting
    function TypepPD(GUI_Calibration_TypepPD,event_data)
        
        % Retrieve the User-based {VGR} selection
        GetVar = str2double(get(GUI_Calibration_TypepPD,'string')); %[nm]
        if GetVar > 0 && GetVar < 0.98
            pPD = GetVar; %[nm/s]
        end
        set(GUI_Calibration_TypepPD,'String',num2str(pPD)); %[nm]
        
        % Update range for {pPD} accordingly
        TypepPD_Range
        
    end

% Edit {pPD} range for calibration fitting
    function TypepPD_Range(~,event_data)
        
        % Retrieve the User-based {rVGR} selection
        GetVar = str2double(get(GUI_Calibration_TypepPD_Range,'string')); %[nm]
        if GetVar > 0 && GetVar < pPD
            rpPD = GetVar; %[nm/s]
        elseif GetVar >= pPD
            rpPD = (pPD-dpPD); %[nm/s]
        end
        set(GUI_Calibration_TypepPD_Range,'String',num2str(rpPD)); %[nm]
    end

% Edit {pPD} increment for calibration fitting
    function TypepPD_Increment(GUI_Calibration_TypepPD_Increment,event_data)
        
        % Retrieve the User-based {rVGR} selection
        GetVar = str2double(get(GUI_Calibration_TypepPD_Increment,'string')); %[nm]
        if GetVar > 0 && GetVar <= rpPD
            dpPD = GetVar; %[nm/s]
        elseif GetVar > rpPD
            dpPD = rpPD; %[nm/s]
        end
        set(GUI_Calibration_TypepPD_Increment,'String',num2str(dpPD));
    end

% Edit {rPD} for calibration fitting
    function TyperPD(GUI_Calibration_TyperPD,event_data)
        
        % Retrieve the User-based {VGR} selection
        GetVar = str2double(get(GUI_Calibration_TyperPD,'string')); %[ms]
        if GetVar > 0
            rPD = GetVar; %[nm/s]
        end
        set(GUI_Calibration_TyperPD,'String',num2str(rPD)); %[ms]
        
        % Update range for {rPD} accordingly
        TyperPD_Range
        
    end

% Edit {rPD} range for calibration fitting
    function TyperPD_Range(~,event_data)
        
        % Retrieve the User-based {rVGR} selection
        GetVar = str2double(get(GUI_Calibration_TyperPD_Range,'string')); %[ms]
        if GetVar > 0 && GetVar < rPD
            rrPD = GetVar; %[nm/s]
        elseif GetVar >= rPD
            rrPD = (rPD-drPD); %[nm/s]
        end
        set(GUI_Calibration_TyperPD_Range,'String',num2str(rrPD)); %[ms]
    end

% Edit {rPD} increment for calibration fitting
    function TyperPD_Increment(GUI_Calibration_TyperPD_Increment,event_data)
        
        % Retrieve the User-based {rVGR} selection
        GetVar = str2double(get(GUI_Calibration_TyperPD_Increment,'string')); %[ms]
        if GetVar > 0 && GetVar <= rrPD
            drPD = GetVar; %[nm/s]
        elseif GetVar > rrPD
            drPD = rrPD; %[nm/s]
        end
        set(GUI_Calibration_TyperPD_Increment,'String',num2str(drPD));
    end

% Edit {Q} to relieve constraints on the allowable segment angle deviation
% for at least {Q} data points
    function FitQuality(GUI_Calibration_FitQuality,event_data)
        
        % Retrieve the User-based allowable segment variation selection
        GetVar = str2double(get(GUI_Calibration_FitQuality,'string')); %[deg]
        if GetVar > 0 && GetVar <= dSegMax
            dSeg = GetVar; %[deg]
        elseif GetVar > dSegMax
            dSeg = dSegMax; %[deg]
        end
        set(GUI_Calibration_FitQuality,'String',num2str(dSeg));
    end

% Update the experimentally determined VGR with the fitted one
    function SendFitVGR(GUI_Calibration_Send,event_data)
        
        % Update the experimental value with the fitted one
        vDz = FitVGR; %[nm]
        set(GUI_Calibration_TypevDz,'String',num2str(vDz));
        
    end

% Define minimum allowed dwell time
    function TauMinSet(~,event_data)
        
        % Gather the minimum allowed dwell time
        FleetingTime = str2double(get(GUI_Calibration_TauMin,'String'));
        
        % Set limit to minimum allowable segment angle
        ZetaLimit = ZetaMin; %[deg]
        
        % Set limit based on the calibration curve fit
        if FittedCalibData == true && CalibrateByExpData == 0
            
            % Minimum dwell time must fall within the experimental data
            % range
            if FleetingTime > xFit(ForbiddenTau) &&...
                    FleetingTime <= xFit(length(xFit))
                
                % Accept user defined minimum dwell time
                TauMin = FleetingTime; %[ms]
                
                % Segment angle (dwell time) by interpolation
                idxFile = sum(TauMin > xFit); %[ms]
                % Segment angle by (Look Up Table)
                ZetaLimit = zFit(idxFile) +...
                    (TauMin - xFit(idxFile))./(xFit(idxFile+1) - xFit(idxFile)).*...
                    (zFit(idxFile+1) - zFit(idxFile)); %[deg]
            end
            
            % Set limit based on the raw experimental calibration curve
        elseif CalibrateByExpData == 1
            
            % [ms] to [s]
            FleetingTime = FleetingTime.*1E-3; %[s]
            
            % Minimum dwell time must fall within the experimental data
            % range
            if FleetingTime > xDwell(1) &&...
                    FleetingTime <= xDwell(ExpPoints) %#ok<*BDSCI>
                
                % Accept user defined minimum dwell time
                TauMin = FleetingTime.*1000; %[ms]
                
                % Segment angle (dwell time) by interpolation
                idxFile = sum(FleetingTime > xDwell); %[ms]
                % Segement angle by (Look Up Table)
                ZetaLimit = zAngle(idxFile) +...
                    (FleetingTime - xDwell(idxFile))./(xDwell(idxFile+1) - xDwell(idxFile)).*...
                    (zAngle(idxFile+1) - zAngle(idxFile)); %[deg]
            end
            
        end
        
        % Update {TauMin} in the GUI input box
        set(GUI_Calibration_TauMin,'String',num2str(TauMin));
        % Update {ZetaMin} in the GUI text box
        set(GUI_Calibration_ZetaMin,'String',num2str(ZetaLimit));
    end


% Calibration curve {tau,zeta} data plot
    function Plot_tz_Fit(~,event_data)
        
        % Experimental data plot
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        if ExpPlot == true
            set(tzAxis,'NextPlot','replace')
            
            % Surface contact vertex (red), otherwise (green)
            Ptz = plot(tzAxis,xDwell.*1E3,zAngle,'o','MarkerFaceColor',...
                FitHue,'MarkerEdgeColor',FitHue,'MarkerSize',MS_Ptz);
            
            axes(tzAxis)
            set(tzAxis,'NextPlot','add','XColor',FitHue,'YColor',FitHue,...
                'YTick',tzAxesYTick)
            
            axis(tzAxesLimits)
            xlabel('\tau_d (ms)','FontSize',(FS+3),'FontWeight','bold','Color',FitHue);
            ylabel('\zeta','FontSize',(FS+7),'FontWeight','bold','Color',FitHue);
            
        end
        
        % Fitted, experimental data plot
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        if ExpPlot == false
            if FitPlotData == false
              
                PtzFit = plot(tzAxis,xFit,zFit,'-.r',...
                    'LineWidth',2);
                drawnow
                % Fit plot now exists
                FitPlotData = true; %[0/1]
                % Fit plot object exists, update
            elseif FitPlotData == true
                axes(tzAxis)
                set(PtzFit,'XData',xFit.*1000,'YData',zFit)
                drawnow
            end
        end
    end

% Load coordinate list from a text file and add these coordinates to the
% current CAD pattern
    function LoadCalibrationFile(~,event_data)
        
        % Calibration curve receives unique index identifier
        Recipe = get(GUI_Calibration_FileName,'value'); %[1,2,3...]
        
        if Recipe <= nRecipes
            
            ActionFileName = sprintf('%s_Parameters.txt',Recipes{1,Recipe});
            
            % Microscope parameters import
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % Data import from text file
            cd(SupportingFilesFolderName)
            % Open segment angle calibration file
            RecipeFileID = fopen(ActionFileName,'r');
            % Read parameter from the text file...call by Parameters{x,x}
            Parameters = textscan(RecipeFileID,...
                '%*s %s %*s %f %*s %f %*s %f %*s %s %*s %f %*s %f %*s %f %*s %f %*s %f %*s %s %*s %f %*s %f',...
                'Delimiter','\n');
            % Close the array duplication file
            fclose(RecipeFileID);
            cd ../
            
            CalibrationFileInfo{1,Recipe} =...
                sprintf('Energy = %g[keV], Current = %g[pA], Nozzle_X = %g[um], Nozzle_Y = %g[um], Nozzle_Z = %g[um], T = %g[C], Gas = %s, GIS = %g[deg], Sub=%s',...
                Parameters{1,2},Parameters{1,3},Parameters{1,7},Parameters{1,8},...
                Parameters{1,9},Parameters{1,6},char(Parameters{1,5}),Parameters{1,10},char(Parameters{1,11}));
            
            % Patterning engine
            PatterningEngine = char(Parameters{1,1}); %[s]
            if strcmp(PatterningEngine,'FEI')
                PatterningEngine = 1; %[1,2,...]
            elseif strcmp(PatterningEngine,'NVPE')
                PatterningEngine = 2; %[1,2,...]
            end
            
            % FEBID exposure conditions
            set(GUI_Expose_CalibrationFileDetails,'String',CalibrationFileInfo{1,Recipe});
            
            % Beam size (FWHM)
            FWHM = Parameters{1,4}; %[nm]
            % Beam size (Standard Deviation)
            BeamSig
            % Update the {FWHM} value in the 'Adv'anced dropdown menu IF
            % {FWHM} is currently selected
            if AdvVar == 9
                set(GUI_Advanced_Variables_Input,'String',num2str(FWHM)); %[nm]
            end
            
            % HFW*MAG factor
            MagHFW = Parameters{1,12}; %[um]
            set(GUI_Expose_MagHFW,'String',num2str(MagHFW));
            
            % 12 or 16 bit
            BitDepth = Parameters{1,13}; %[nm]
            pow2_Bits = 2.^BitDepth; %[1,2,4,...]
            
            % FEI Nova 600 (12-bit only)
            if BitDepth == 16
                SwitchForBitDepth
                % FEI Nova 200 (16-bit only)
            elseif BitDepth == 12
                SwitchForBitDepth
            end
            
            % Update magnification and magnification/horizontal field width
            MagnificationSetting
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            
            % Read dwell time and segment angle experimental data from file
            ReadCalibrationFile
            
            
            % Load fitted calibration curve values if they exist
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % Fitting minimization parameter is a function of calibration
            % file (reset)
            GlobalFit = 1E9; %[0/1]
              
            cd(SupportingFilesFolderName)
            % Has the calibration curve been fitted previously?
            ExistCalibFit = exist(sprintf('%s_Fit.txt',Recipes{1,Recipe}),'file');
            % Has the calibration curve been fitted previously?
            if ExistCalibFit == 2
                
                % Fitted calibration data exits for use
                FittedCalibData = true; %[0/1]
                
                fid = fopen( sprintf('%s_Fit.txt',Recipes{1,Recipe}) );
                % ...lines in text file
                for q=1:33
                    tEmP = fgetl(fid); %[string]
                    if q == 8
                        % Vertical growth rate (VGR)
                        FitVGR = str2double(tEmP); %[nm/s]
                        set(GUI_Calibration_VGR_Fit,'String',num2str(FitVGR));
                    elseif q == 12
                        % percent Precursor Depletion (pPD)
                        FitpPD = str2double(tEmP); %[0-1]
                        set(GUI_Calibration_pPD_Fit,'String',num2str(FitpPD));
                    elseif q == 16
                        % rate of Precursor Depletion (rPD)
                        FitrPD = str2double(tEmP); %[ms]
                        set(GUI_Calibration_rPD_Fit,'String',num2str(FitrPD));
                    elseif q == 20
                        % Nuclei radius (rN)
                        rN = str2double(tEmP); %[nm]
                    elseif q == 24
                        % Minimum dwell time based on fitted data
                        ForbiddenTau = str2double(tEmP); %[ms]
                    elseif q == 28
                        % Fitting minimization parameter
                        GlobalFit = str2double(tEmP); %[]
                    end
                    
                    % Load calibration curve fit
                    % ooooooooooooooooooooooooooooooooooooooo
                    if q == 32
                        % ...dwell times in fit
                        for dp=1:length(xFit)
                            % Line-by-line reading
                            H = sscanf(fgetl(fid),'%f'); %[string]
                            xFit(dp) = H(1); %[s]
                            zFit(dp) = H(2); %[degrees]
                        end
                        xFit = xFit.*1000; %[ms]
                    end
                    
                end
                fclose(fid);
                
            end
            cd ../
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

            
            % Raw experimental data for segment angle determination when a
            % calibration file is reloaded
            CalibrateByExpData = 1; %0/1]
            set(GUI_Calibration_sOff,'CData',sOff);

            % Minimum dwell time updated to reflect the experimental data
            % set
            TauMin = xDwell(1); %[ms]
            set(GUI_Calibration_TauMin,'Style','edit',...
                'BackgroundColor',UIHue,'String',num2str(TauMin));
            
            % Segment minimum (display)
            ZetaMin = min(zAngle); %[ ]
            ZetaLimit = ZetaMin; %[]
            set(GUI_Calibration_ZetaMin,'String',num2str(ZetaMin));
            
            % Segment maximum (display)
            ZetaMax = max(zAngle);
            set(GUI_Calibration_ZetaMax,'String',num2str(ZetaMax));
            
            % Units Conversions
            xDwell = xDwell.*1E-3; %[s]
            
            % Plot experimental data
            ExpPlot = true; %[0/1]
            Plot_tz_Fit
            
            % Plot/update fitted data
            FitPlotData = false; %[0/1]
            % Calibration fit text file exists?
            if ExistCalibFit == 2
                % Plot fitted data
                ExpPlot = false; %[0/1]
                Plot_tz_Fit
            end
                
            
        elseif Recipe > nRecipes
            
            % Load new calibration file
            iSituation = 2; %[1,2,3]
            
            figure(InfoFig)
            set(InfoFig,'Visible','On')
            
            % User confirmation check
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            Request = 'Calibration file name - please enter the calibration file name';
            set(GUI_UserInput_Question,'String',Request);
            
            % UI configuation for this particular case
            set(GUI_UserInput_LeftButton,'Visible','Off');
            set(GUI_UserInput_RightButton,'Visible','Off');
            set(GUI_UserInput_TypeName,'Visible','On');
            uiwait
            
            % Check for the existance of the file
            cd(SupportingFilesFolderName)
            FileCheck = exist(sprintf('%s.txt',FleetingFileName),'file');
            cd ../
            
            if FileCheck == 0
                % File does not exist, no new calibration file will be
                % created
                Recipe = 1; %[1,2,3,...]
                set(GUI_Calibration_FileName,'value',Recipe); %[1,2,3...]
                
            elseif FileCheck == 2
                
                % File exits, add calibration file to the recipe list
                Recipes{1,Recipe} = FleetingFileName;
                % Number of current recipes
                nRecipes = size(Recipes,2); %[1,2,3,...]
                % Recipe list string
                RecipesPopUp = sprintf('%s |',Recipes{1,1:size(Recipes,2)});
                RecipesPopUp = sprintf('%snew',RecipesPopUp);
                set(GUI_Calibration_FileName,'String',RecipesPopUp);
                
                % Save the recipe list
                cd(SupportingFilesFolderName)
                save HistoryOfExp Recipe Recipes nRecipes RecipesPopUp...
                    CalibrationFileInfo MagHFW
                cd ../
            end
            
            % Segment calibration curve
            LoadCalibrationFile
            
        end
        
    end

% Read calibration file data: reads the calibration data file when the
% program is first executed and when a calibration file is selected by the
% User
    function ReadCalibrationFile(~,event_data)
        
        cd(SupportingFilesFolderName)
        ActionFileName = sprintf('%s.txt',Recipes{1,Recipe});
        New_xyz = dlmread(ActionFileName);
        cd ../
        
        % Number of new vertices
        ExpPoints = size(New_xyz,1); %[1,2,3,...]
        
        % Dwell times (experimental data)
        xDwell = zeros(1,ExpPoints); %[ms]
        % Segment angles (experimental data)
        zAngle = zeros(1,ExpPoints); %[deg]
        
        % ...data points
        if ExpPoints > 0
            for dp=1:ExpPoints
                % New {x} coordinate
                xDwell(dp) = New_xyz(dp,1); %[ms]
                % New {y} coordinate
                zAngle(dp) = New_xyz(dp,2); %[deg]
            end
        end
    end

% Beam standard deviation
    function BeamSig(~,event_data)
        % Beam size (Standard Deviation)
        Sig = FWHM./(2.*sqrt(2.*log(2))); %[nm]
    end


% Segment angle data fitting routine
    function SegmentDataFit(GUI_Calbration_Fit,event_data)
        
        % Vertical growth rate (guesses)
        VGR1D = (VGR-rVGR):dVGR:(VGR+rVGR); %[nm/s]
        % Percent precursor depletion (guesses)
        SD1D = (pPD-rpPD):dpPD:(pPD+rpPD); %[0-1]
        % Rate of precursor depletion (guesses)
        TD1D = (rPD-rrPD):drPD:(rPD+rrPD); %[ms]
        
        % Fitting rule
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        % The base 10 log of the calibration curve slope is used as a
        % weighting factor for how a data point contributes to the
        % minimization parameter calculation.
        logDiv = log10( (zAngle(3:ExpPoints) - zAngle(1:(ExpPoints-2)))./...
            (xDwell(3:ExpPoints) - xDwell(1:(ExpPoints-2))) ); %[log10(nm/nm)]
        dZdt = [1 1+(logDiv-min(logDiv)) 1]; %[log10(nm/nm)]
        
        % Fitted values of segment angle
        zAngleFit = zeros(1,ExpPoints); %[deg]
        zAngleFitSave = zAngleFit; %[deg]
        
        % Progress of fit shown in 'Fit' pressbutton (1 of 2)
        % oooooooooooooooooooooooooooooooooooooooooooooooooooo
        Candidates = round( length(VGR1D).*length(SD1D).*length(TD1D) );
        UpDateWait = 0;
        CheckTimes = (0.1:0.1:1).*Candidates;
        iCheckTimes = 1;
        set(GUI_Calibration_Fit,'String','Fit (started)');
        set(GUI_Calibration_Fit,'BackgroundColor',...
            [UpDateWait./Candidates 1-UpDateWait./Candidates 0]);
        pause(0.02)
        
        
        % Units Conversions
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        TD1D = TD1D.*0.001; %[s]
        
        % Scalars, Vectors, Matrices and Arrays
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        % Surface resolution (initial value)
        dSurf_0 = rN.*dAng; %[nm]
        % Number of time steps in fit simulation
        tLen = length(xFit); %[]
        
        % Surface definition: {x} coordinate
        xs1D = zeros(SurfaceNodes,1); %[nm]
        xs1Dt = xs1D; %[nm]
        % Surface definition: {z} coordinate
        zs1D = zeros(SurfaceNodes,1); %[nm]
        zs1Dt = zs1D; %[nm]
        % Surface derivative
        dzdx = zeros(SurfaceNodes,1); %[nm/nm]
        % Surface coordinate spacings
        dxz1D = zeros(SurfaceNodes,1); %[nm]
        % Cumulative path length on surface
        Int_S = zeros(SurfaceNodes,1); %[nm]
        % Segment angle
        Zeta = zeros(tLen,1); %[deg]
        
        % Nuclei definition
        % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
        % Quarter circle nuclei
        Ang1D = fliplr(0:dAng:(pi/2)); %[rad]
        % Number of surface nodes
        sNodes = length(Ang1D); %[]
        
        xFit = xFit.*0.001; %[s]
        F1 = 1./(2.*(Sig.^2)); %[1/nm2]
        
        % Trigger that a new fit has been detected
        NewFit = false; %[0/1]
        
        % ...vertical growth rate
        for n=1:length(VGR1D)
            % ...beam size/pillar width (ELR)
            for m=1:length(SD1D)
                % ...dwell time at segment "take-off"
                for q=1:length(TD1D)
                    
                    % Progress of fit shown in 'Fit' pressbutton (2 of 2)
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    UpDateWait = UpDateWait + 1;
                    if UpDateWait > CheckTimes(iCheckTimes)
                        ProgressString = sprintf('%g%% complete',...
                            10.*round(10.*(UpDateWait./Candidates)));
                        set(GUI_Calibration_Fit,'string',ProgressString);
                        set(GUI_Calibration_Fit,'BackgroundColor',...
                            [UpDateWait./Candidates 1-UpDateWait./Candidates 0]);
                        pause(0.005)
                        iCheckTimes = iCheckTimes + 1; %[]
                    end
                    
                    % Number of surface nodes
                    sNodes = length(Ang1D); %[]
                    
                    % Nuclei: {x} coordinate
                    xs1D(1:sNodes) = rN.*cos(Ang1D); %[nm]
                    % Nuclei: {y} coordinate
                    zs1D(1:sNodes) = rN.*sin(Ang1D); %[nm]
                    
                    % Reset segment angle solution vector
                    Zeta(:) = 0; %[deg]
                    
                    % ...dwell time
                    for t=2:tLen
                        
                        % Surface derivative
                        % oooooooooooooooooooooooooooooooooooooooooooooooo
                        dzdx(1) = 0; %[nm/nm]
                        dzdx(2:(sNodes-1)) = (zs1D(3:sNodes) - zs1D(1:(sNodes-2)))./...
                            (xs1D(3:sNodes) - xs1D(1:(sNodes-2))); %[nm/nm]
                        dzdx(sNodes) = (zs1D(sNodes) - zs1D(sNodes-1))./...
                            (xs1D(sNodes) - xs1D(sNodes-1)); %[nm/nm]
                        
                        
                        % Surface evolution
                        % oooooooooooooooooooooooooooooooooooooooooooooooo
                        % Surface normal angle with respect to +{x}
                        sNorm = atan(dzdx(1:sNodes)) + pi./2; %[rad]
                        % Primary electron beam perturbation
                        eBeam = exp( -F1.*(xs1D(1:sNodes).^2) ); %[]
                        % Depletion function
                        dGas = ((1-SD1D(m)) + SD1D(m).*exp(-xFit(t)./TD1D(q))); %[]
                        % Surface growth {x}
                        xs1D(1:sNodes) = xs1D(1:sNodes) + VGR1D(n).*dTau.*...
                            cos(sNorm).*eBeam.*dGas; %[nm]
                        % Surface growth {z}
                        zs1D(1:sNodes) = zs1D(1:sNodes) + VGR1D(n).*dTau.*...
                            sin(sNorm).*eBeam.*dGas; %[nm]
                        
                        
                        % Re-Discretize surface
                        % oooooooooooooooooooooooooooooooooooooooooooooooo
                        % Surface pixel spacings
                        dxz1D(1:(sNodes-1)) =...
                            sqrt( (xs1D(2:sNodes) - xs1D(1:(sNodes-1))).^2 +...
                            (zs1D(2:sNodes) - zs1D(1:(sNodes-1))).^2 ); %[nm]
                        % Surface path length
                        S = sum(dxz1D(1:(sNodes-1))); %[nm]
                        
                        % Number of nodes
                        New_sNodes = ceil(S./dSurf_0); %1,2,3,...]
                        % Updated node spacing
                        dSurf = S./(New_sNodes - 1); %[nm]
                        
                        % Integrated surface path length
                        Int_S(1) = 0; %[nm]
                        Int_S(2:sNodes) = cumsum(dxz1D(1:(sNodes-1))); %[nm]
                        
                        % Surface coordinates (new)
                        xs1Dt(1) = xs1D(1); %[nm]
                        zs1Dt(1) = zs1D(1); %[nm]
                        
                        % ...new surface nodes
                        for p=2:(New_sNodes-1)
                            % Surface node {n} is located beyond {xs1D(1:idxL)} coordinates from
                            % the previous time step (moving in positive {x} direction)
                            idxL = sum((p-1).*dSurf > Int_S(2:(sNodes-1))) + 1; %[idx]
                            
                            % New {x} coordinate
                            xs1Dt(p) = xs1D(idxL) +...
                                (xs1D(idxL+1) - xs1D(idxL)).*...
                                ( (p-1).*dSurf - Int_S(idxL) )./dxz1D(idxL); %[nm]
                            
                            % New {z} coordinate
                            zs1Dt(p) = zs1D( idxL ) +...
                                (zs1D(idxL+1) - zs1D(idxL)).*...
                                ( (p-1).*dSurf - Int_S(idxL) )./dxz1D(idxL); %[nm]
                        end
                        xs1Dt(New_sNodes) = xs1D(sNodes); %[nm]
                        zs1Dt(New_sNodes) = zs1D(sNodes); %[nm]
                        
                        % Number of coordinates defining the surface (update)
                        sNodes = New_sNodes; %[1,2,3,...]
                        % Apply temporary coordinates to the actual coordinates
                        xs1D(1:sNodes) = xs1Dt(1:sNodes);
                        zs1D(1:sNodes) = zs1Dt(1:sNodes); %[nm]
                        
                        % Segment angle (extrapolation)
                        idxL = sum(xs1D(1:sNodes) < ds); %[idx]
                        
                        % Segment substrate 'take-off' condition
                        if max(xs1D(1:sNodes)) >= ds
                            Zeta(t) = zs1D(idxL) +...
                                (zs1D(idxL+1) - zs1D(idxL)).*...
                                ( ds - xs1D(idxL))./(xs1D(idxL+1) - xs1D(idxL)); %[rad]
                            % Segment angle
                            Zeta(t) = atan(Zeta(t)./ds).*180./pi; %[deg]
                        end
                        
                    end
                    
                    % ...segment angle data point
                    for p=1:ExpPoints
                        
                        % FEBiD segment angle
                        % oooooooooooooooooooooooooooooooooooooooooooooooo
                        % Segment substrate 'take-off' condition
                        idxL = sum(xFit <= xDwell(p));%[idx]
                        % Interpolated segment angle
                        zAngleFit(p) = Zeta(idxL) +...
                            (Zeta(idxL+1) - Zeta(idxL)).*...
                            ( xDwell(p) - xFit(idxL))./(xFit(idxL+1) - xFit(idxL)); %[deg]
                    end
                    
                    % Data fitting (rules)
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    cd(SupportingFilesFolderName)
                    [Fit,Rule_1] = FittingRules(zAngleFit,zAngle,dSeg,dZdt);
                    cd ../
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    
                    % Fit sensing
                    % oooooooooooooooooooooooooooooooooooooooooooooooooooo
                    if Fit < GlobalFit && Rule_1 <= Rule_1_Max
                        
                        % New global value of minimization parameter
                        % detected.
                        GlobalFit = Fit; %[]
                        
                        % Vertical growth rate (fitted)
                        FitVGR = VGR1D(n); %[nm/s]
                        set(GUI_Calibration_VGR_Fit,'String',num2str(FitVGR));
                        % Percent precursor depletion
                        FitpPD = SD1D(m); %[0-1]
                        set(GUI_Calibration_pPD_Fit,'String',num2str(FitpPD));
                        % Rate of precursor depletion
                        FitrPD = TD1D(q).*1000; %[ms]
                        set(GUI_Calibration_rPD_Fit,'String',num2str(FitrPD));
                        % Initial pre-existing nuclei radius
                        FitrN = rN; %[nm]
                        
                        % Fitted segment angles
                        zFit = Zeta; %[deg]
                        % Dwell times insufficient to promote segment growth removed
                        ForbiddenTau = sum(zFit == 0) + 1; %[idx]
                        
                        % Save interpolated segment angle values from model
                        % fit
                        zAngleFitSave = zAngleFit; %[deg]
                        
                        % A data fit exists
                        FittedCalibData = true; %[0/1]
                        % At least one fit was detected during this fitting
                        % cycle
                        NewFit = true; %[0/1]
                        
                        % Update fit plot
                        ExpPlot = false; %[0/1]
                        % Plot calibration data
                        Plot_tz_Fit
                        
                    end
                    
                end
            end
        end
        
        set(GUI_Calibration_Fit,'String','Fit');
        
        % Segment angle deviation plot between experimental data and the
        % current best fit of the calibration curve
        if NewFit == true
            
            % Quality of fitting plot
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            Fx = figure;
            set(Fx,'Color','white','Position',fGUI.*[50 50 800 500])
            xMaxAxis = 10*ceil( max(xDwell*1000)/10 ); %[ms]
            plot(xDwell.*1000,zAngleFitSave - zAngle,'ob','MarkerSize',8,...
                'MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 0.8])
            set(gca,'FontSize',(FS+5),'YTick',-5:1:5,'XTick',0:10:xMaxAxis);
            xlabel('\tau_d (ms)','FontSize',(FS+7));
            ylabel('+/-\Delta\zeta (degrees)','FontSize',(FS+13));
            axis([0 xMaxAxis -5 5])
            pause(2)
            
            cd(DesignFolderName)
            saveas(Fx,'FitQuality.tif')
            save FEBiDModelFit ds FitrN FitVGR FitpPD FitrPD FWHM zAngleFitSave...
                zAngle xDwell ExpPoints DesignFolderName
            cd ../
            save FEBiDModelFit ds FitrN FitVGR FitpPD FitrPD FWHM zAngleFitSave...
                zAngle xDwell ExpPoints DesignFolderName
            
            close(Fx)
            
            
            % Associated textfile with calibration curve data in the Supporting Files
            % Folder
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            cd(SupportingFilesFolderName)
            
            % Raith file name for export
            FitFileName = sprintf('%s_Fit.txt',Recipes{1,Recipe});
            % Raith (text file creation)
            fid = fopen(FitFileName, 'wt');
            
            fprintf(fid,'--------------------------------------------------------- \n');
            fprintf(fid,'Calibration Fit & Parameters \n');
            fprintf(fid,'--------------------------------------------------------- \n');
            fprintf(fid,'--------------------------------------------------------- \n');
            
            fprintf(fid,'\n');
            
            fprintf(fid,'Vertical Growth Rate (VGR) (nm/s) \n');
            fprintf(fid,'----------------------------------------------- \n');
            fprintf(fid,'%4.1f \n',FitVGR);
            fprintf(fid,'\n');
            
            fprintf(fid,'percent Precursor Depletion (pPD) (0-1) \n');
            fprintf(fid,'----------------------------------------------- \n');
            fprintf(fid,'%3.2f \n',FitpPD);
            fprintf(fid,'\n');
            
            fprintf(fid,'rate of Precursor Depletion (rPD) (ms) \n');
            fprintf(fid,'----------------------------------------------- \n');
            fprintf(fid,'%4.2f \n',FitrPD);
            fprintf(fid,'\n');
            
            fprintf(fid,'Nuclei radius (rN) (nm) \n');
            fprintf(fid,'----------------------------------------------- \n');
            fprintf(fid,'%3.2f \n',rN);
            fprintf(fid,'\n');
            
            fprintf(fid,'Minimum dwell time index (ForbiddenTau) (1,2,3...) \n');
            fprintf(fid,'----------------------------------------------- \n');
            fprintf(fid,'%4.2f \n',ForbiddenTau);
            fprintf(fid,'\n');
            
            fprintf(fid,'Minimization parameter \n');
            fprintf(fid,'----------------------------------------------- \n');
            fprintf(fid,'%d \n',GlobalFit);
            fprintf(fid,'\n');
            
            fprintf(fid,'tau_d   Zeta\n');
            fprintf(fid,' (s)   (deg)\n');
            fprintf(fid,'--------------- \n');
            for dp=1:length(xFit)
                fprintf(fid,'%5.3f\t%5.3f \n',xFit(dp),zFit(dp)); %[s,deg]
            end
            
            fprintf(fid,'\n\n');
            fprintf(fid,'--------------------------------------------------------- \n');
            fprintf(fid,'%c',datestr(clock));
            fprintf(fid,'\n');
            fprintf(fid,'--------------------------------------------------------- \n');
            
            fclose(fid);
            cd ../
            % oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
            
        end
        
        % [s] to [ms]
        xFit = xFit.*1000; %[ms]
        
        % Register new design step and save design
        UponNewAction
    end


% Toggle switch state for segment angle LUT
    function SwitchForExpData(GUI_Calibration_sOff,event_data)
        
        % A fit of the experimental data must exist for the switch to
        % activate
        if FittedCalibData == true
            % Raw experimental data for segment angle determination
            if CalibrateByExpData == 0
                CalibrateByExpData = 1; %[0/1]
                set(GUI_Calibration_sOff,'CData',sOff);
                
                % Minimum allowable dwell time
                TauMin = xDwell(1).*1E3; %[ms]
                set(GUI_Calibration_TauMin,'String',num2str(TauMin));
                % Segment minimum (display)
                ZetaMin = min(zAngle); %[deg] 
                set(GUI_Calibration_ZetaMin,'String',num2str(ZetaMin));
                % Segment maximum (display)
                ZetaMax = max(zAngle); %[deg]
                set(GUI_Calibration_ZetaMax,'String',num2str(ZetaMax));
                
                % Fitted data interpolation for segment angle determination
            elseif CalibrateByExpData == 1
                CalibrateByExpData = 0; %[0/1]
                set(GUI_Calibration_sOff,'CData',sOn);
                
                % Minimum allowable dwell time
                TauMin = xFit(ForbiddenTau); %[ms]
                set(GUI_Calibration_TauMin,'String',num2str(TauMin));
                % Segment minimum (display)
                ZetaMin = zFit(ForbiddenTau); %[deg]
                set(GUI_Calibration_ZetaMin,'String',num2str(ZetaMin));
                % Segment maximum (display)
                ZetaMax = max(zFit); %[deg]
                set(GUI_Calibration_ZetaMax,'String',num2str(ZetaMax));
            end
        end
        
    end

% GUI_Advanced_...{Functions}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Selected advanced variable and change the units appropriately
    function AdvancedVariablesEdit(~,event_data)
        
        % Current advanced variable of interest
        AdvVar = get(GUI_Advanced_Variables,'Value'); %[1,2,3...]
        % Update the variable units
        set(GUI_Advanced_Variables_Units,'String',AdvVarUnits(AdvVar)); %[1,2,3...]
        
        if AdvVar == 1
            set(GUI_Advanced_Variables_Input,'String',num2str(f_tDe)); %[ ]
            set(GUI_Advanced_Variables,'TooltipString',...
                sprintf('Multliplcation factor applied to all dwell times \nduring exposure file creation. \n{min,max} = {0,2}'));
        elseif AdvVar == 2
            set(GUI_Advanced_Variables_Input,'String',num2str(PrxCi)); %[nm]
            set(GUI_Advanced_Variables,'TooltipString',...
                sprintf('Simple proximity correction \nInitiate segment exposure at +{s_i} [nm] past segment origin \nif two or more segments diverge from a \ncommon vertex. \n{min,max} = {0,10}'));
        elseif AdvVar == 3
            set(GUI_Advanced_Variables_Input,'String',num2str(PrxCf)); %[nm]
            set(GUI_Advanced_Variables,'TooltipString',...
                sprintf('Simple proximity correction \nDeduct -{s_f} [nm] from segment terminus \nif two or more segments converge at a \ncommon vertex. \n{min,max} = {0,10}'));
        elseif AdvVar == 4
            set(GUI_Advanced_Variables_Input,'String',num2str(tdMax_NVPE)); %[ms]
            set(GUI_Advanced_Variables,'TooltipString',...
                sprintf('NVPE uses a constant exposure dwell time \nfor all exposure pixels.  Segments will be exposed \nin increments of this value. \n{min,max} = {0,1}'));
        elseif AdvVar == 5
            set(GUI_Advanced_Variables_Input,'String',num2str(AllShots)); %[0/1]
            set(GUI_Advanced_Variables,'TooltipString',...
                sprintf('Simulation dwell time sampling activation and \nactivates abbreviated exposure mapping in {x,y,z} plot.'));
        elseif AdvVar == 6
            set(GUI_Advanced_Variables_Input,'String',num2str(sPerLevel)); %[level]
            set(GUI_Advanced_Variables,'TooltipString',...
                sprintf('Simulation dwell time sampling every {sPerLevel} dwells per segment, \n for all segments on the current exposure level. {min,max} = {1,10}'));
        elseif AdvVar == 7
            set(GUI_Advanced_Variables_Input,'String',num2str(rN)); %[nm]
            set(GUI_Advanced_Variables,'TooltipString',...
                sprintf('Calibration Curve Fitting Parameter \nRadius of the initial nuclei. \n{min,max} = {0.1,1}'));
        elseif AdvVar == 8
            set(GUI_Advanced_Variables_Input,'String',num2str(Rule_1_Max)); %[1,2,3,...]
            set(GUI_Advanced_Variables,'TooltipString',...
                sprintf('Calibration Curve Fitting Constraint Relief \n{Q} range not enforced on {x} calibration curve data points. \n{min,max} = {0,10}'));
        elseif AdvVar == 9
            set(GUI_Advanced_Variables_Input,'String',num2str(FWHM)); %[nm]
            set(GUI_Advanced_Variables,'TooltipString',...
                sprintf('Calibration Curve Fitting Constraint \nChange the beam {FWHM} from that specified in the \n{}_Parameters.txt file. \n{min,max} = {1,50}'));
        end
    end

% Advanced variable change
    function AdvancedVariablesInput(GUI_Advanced_Variables_Input,event_data)
        
        % Input new value for advanced variable and test for variable
        % constraints
        if AdvVar == 1
            f_tDe = str2double(get(GUI_Advanced_Variables_Input,'String')); %[ ]
            % Variable constraints
            if f_tDe <= f_tDe_MinMax(1) || f_tDe > f_tDe_MinMax(2)
                f_tDe = 1; %[]
                AdvancedVariablesEdit
            end
        elseif AdvVar == 2
            PrxCi = round(str2double(get(GUI_Advanced_Variables_Input,'String'))); %[nm]
            % Variable constraints
            if PrxCi <= PrxCi_MinMax(1) || PrxCi > PrxCi_MinMax(2)
                PrxCi = 0; %[nm]
                AdvancedVariablesEdit
            end
        elseif AdvVar == 3
            PrxCf = round(str2double(get(GUI_Advanced_Variables_Input,'String'))); %[nm]
            % Variable constraints
            if PrxCf <= PrxCf_MinMax(1) || PrxCf > PrxCf_MinMax(2)
                PrxCf = 0; %[nm]
                AdvancedVariablesEdit
            end
        elseif AdvVar == 4
            tdMax_NVPE = str2double(get(GUI_Advanced_Variables_Input,'String')); %[nm]
            % Variable constraints
            if tdMax_NVPE <= tdMax_NVPE_MinMax(1) || tdMax_NVPE > tdMax_NVPE_MinMax(2)
                tdMax = 0.5; %[ms]
                AdvancedVariablesEdit
            end
        elseif AdvVar == 5
            AllShots = str2double(get(GUI_Advanced_Variables_Input,'String')); %[nm]
            % Variable constraints
            if AllShots <= 0
                AllShots = false; %[0/1]
            elseif AllShots > 0
                AllShots = true; %[01]
            end
            AdvancedVariablesEdit
        elseif AdvVar == 6
            sPerLevel = round(str2double(get(GUI_Advanced_Variables_Input,'String'))); %[nm]
            % Variable constraints
            if sPerLevel < sPerLevel_MinMax(1)
                sPerLevel = sPerLevel_MinMax(1); %[1,2,3,...passes through the level]
            elseif sPerLevel > sPerLevel_MinMax(2)
                sPerLevel = sPerLevel_MinMax(2); %[1,2,3,...passes through the level]
            end
            AdvancedVariablesEdit
        elseif AdvVar == 7
            rN = str2double(get(GUI_Advanced_Variables_Input,'String')); %[nm]
            % Variable constraints
            if rN <= rN_MinMax(1)
                rN = rN_MinMax(1); %[nm]
            elseif rN > rN_MinMax(2)
                rN = rN_MinMax(2); %[nm]
            end
            AdvancedVariablesEdit
        elseif AdvVar == 8
            Rule_1_Max = round(str2double(get(GUI_Advanced_Variables_Input,'String'))); %[]
            % Variable constraints
            if Rule_1_Max < Rule_1_Max_MinMax(1)
                Rule_1_Max = Rule_1_Max_MinMax(1); %[1,2,3,...]
            elseif Rule_1_Max > Rule_1_Max_MinMax(2)
                Rule_1_Max = Rule_1_Max_MinMax(2); %[1,2,3,...]
            end
            AdvancedVariablesEdit
        elseif AdvVar == 9
            FWHM = str2double(get(GUI_Advanced_Variables_Input,'String')); %[nm]
            % Variable constraints
            if FWHM < FWHM_MinMax(1)
                FWHM = FWHM_MinMax(1); %[nm]
            elseif FWHM > FWHM_MinMax(2)
                FWHM = FWHM_MinMax(2); %[nm]
            end
            % Beam standard deviation
            BeamSig
            AdvancedVariablesEdit
        end
        
        % Proximity Correction Activation
        % ooooooooooooooooooooooooooooooooooooooooooooo
        ProxCorrOn = false; %[0/1]
        if PrxCi ~= 0 || PrxCf ~= 0
            ProxCorrOn = true; %[0/1]
        end

    end


% GUI_ReStart_...{Function}
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
% Restart .m file
    function ReStartFEBiD_CAD(~,event_data)
        close(MainFig)
        FEBiD_CAD_v9p2
    end

end