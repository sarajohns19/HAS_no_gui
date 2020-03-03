# HAS_no_gui
For developing a non-GUI version of HAS for lab members. 

The goal of this project is to isolate the "guts" of HAS necessary for calculating acoustic pressure and energy deposition over a 3D model for automatic batch processing of HAS simulations. Users may require batch simulations if input variables such as as model properties, electronic steering, acoustic power, and model offset may change with each iteration. Therefore, as many HAS GUI inputs as possible should also be defined as inputs in the script version of HAS. These will likely include but are not limited to the following:  

%%%% INPUTS %%%%   
% c0        = Speed of sound in water (m/s)  
% rho0      = Density of water  
% Dx        = Modl resolution in 2nd dimension  
% Dy        = Modl resolution in 1st dimension  
% Dz        = Modl resolution in 3rd dimension  
% c         = vector of Speed of sound values in each Modl domain (m/s)  
% a         = vector of total Attenuation in each Modl domain  
% rho       = vector of Density in each Modl domain  
% Pr        = Acoustic power output of transducer  
% res       = Model resolution as a vector, probably not needed  
% Modl      = 3D segmented model, corresponds to values in a, rho, c  
% perfa     = Input the pre-loaded perfa from the ERFA file because it takes a long time to
%             load  
  
  
%%% for the following inputs, a (+) value progresses to a higher slice number:  
% offsetxmm  = mechanical offset from center of Modl (along 2nd dimension) (mm)  
% offsetymm  = mechanical offset from center of Modl (along 1st dimension) (mm)  
% dmm        = Distance from Xducer base to Modl base (mm)  
% hmm        = electronic steering in x-direction (along 2nd dimension) (mm)  
% vmm        = electronic steering in y-direction (alond 1st dimension) (mm)  
% zmm        = electronic steering in z-direction (along 3rd dimension) (mm)  
  
%%%%%%%%%%%%%%%%%%%%%%  
  
Importantly, it will be assumed that the input 3D Model is already permuted and rotated as necessary for the HAS transducer convention. In this convention, transverse US propagation is in the X-Y plane (1st-2nd dimensions), and longitudinal propagation is in the Z-plane (3rd dimension).   
  
For non-orthoganol Model rotations, the GUI is extremely useful for resampling rotated models. A portion of this package may include the option to export a rotated model from the GUI to use as an input for batch HAS simulations.   

  
    
Updates:  
3/2/2020 S. Johnson  
Uploaded useful files. I wrote a function "HASgui8d_AltSara.m" which runs the "guts" of HAS with most of the necessary user-input. I used a similar approach in making "HASgui8e_AltSara.m" in the 8e version folder, although I haven't yet validated this script.   
