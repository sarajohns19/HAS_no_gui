%   set(groot,'DefaultFigureWindowStyle', 'normal' ) % For not tiling this gui.
clear all
handles = guihandles(gcf);
set(handles.edit12,'string','Load files in this order: source (ERFA), param, Modl.')
currentdirstr=pwd; addpath(currentdirstr);