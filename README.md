# graphgrabber
A small program to digitise points from a graph in a bitmap
GraphGrabber is a simple program to obtain coordinates/data from a scanned image or graph.
This text is the entire manual; below is the link to download the program.

About GraphGrabber
GraphGrabber is a simple program to determine the coordinates of points in a bitmap. It has been designed with the aim to load a scanned chart, define the horizontal and vertical axis, and then determine the values for data points in the chart. Yet it can be used for any type of determining coordinates in an image.

Installation:
Place the program in a directory you see fit. The program has no registry settings, drivers or otherwise that need to be installed elsewhere. Some settings are stored in a configuration (graphgrabber.ini) file. If you delete this file, the program will make a new one the next time the program is started.

Operation:
Load a bitmap. Define the first coordinate axis (x-axis) by drawing a line, starting at the origin. Move the mouse pointer to the origin, press the left button down, keep it pressed, and drag along the x-axis to the end point of the axis, after which the button can be released. 
Define the second axis (y-axis) by clicking the end point of the y-axis. The drawing of the line is automatic. 
Define the numerical value of the origin and the end points in the panel on the right. Axes need not be perpendicular, nor need the image be aligned to the window. You can change the axes by repeating this procedure. Once your axes are at the right location, click the 'Grab Data' tab, and then click on the points of which you want to know the coordinates.

Some default settings may be changed by editing the GraphGrabber.ini file, such as default open- and savedirectory, default numerical values for the axes, and the format of the output of coordinates. Good luck.

Shortcuts:
* `<ctrl>` + d = delete all data
* `<ctrl>` + c = copy data to clipboard
* `<ctrl>` + t = toggle tabs

GraphGrabber is © 1996 - 2016 P.J. van der Wolk. You may use it under the clear BSD licence.

On the programming:
GraphGrabber is written in Borland Delphi. If you have any comments, requests, etc. e-mail me. If you have suggestions to improve these very limited instructions, e-mail me.

Version history
0.33 Rewritten in Lazarus / free pascal, overhaul of interface

0.31 release
(27-09-00):
Small changes: removed the delete-key response since it is prone to accidents.
0.30 release (11-07-00):
Major bugfix for the offset of the axes when not logarithmic. Added more shortcuts and correct response to <delete> key in the grabbed data.
0.28k intermediate release for bugfix

0.20 release: added shortcut keys

0.10 initial release
