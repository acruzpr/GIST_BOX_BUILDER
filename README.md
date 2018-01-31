# README
---  


## GIST Box Builder
GIST Box Builder is a VMD plugin to create a grid box around a molecule for use in docking or GIST calculation.  

The plugin uses the dimensions of a small molecule "drug or ligand" to create a grid box around it. By defaults, the plugin create the grid box with a buffer region of 7 Å from the ligand to the grid box edge.

The dimensions of the box and the box center can be edited using the graphical interface and the results can be seen on the VMD OpenGL window in real time.  

The plugin provide the GIST command to run the calculation with cpptraj. If the prmtop and trajectory file are provided the plugin can generate the input file for running the GIST calculation with cpptraj.

In summary the plugin allows:
* The creation of:
  1. The grid box for a GIST or docking calculation.
  1. VMD visualization state that can be used to visualize the grid box without loading a dx file.
  1. Input file for the GIST calculation with cpptraj.
  1. The generation of the cpptraj GIST command.

## Setup Instructions
### Deployment   
Clone the GIST Box Builder repository in any location:
```
git clone https://github.com/acruzpr/GIST_BOX_BUILDER.git
```
### Configuration
In order for the plugin to work properly, its locations needs to be specified every time is executed. In order to avoid this behavior, its location can be specified using the **GBOX_GUI_HOME** environment variable.

#### Linux and Mac (OSx)
For BASH copy this line to your .bashrc:
```
export GBOX_GUI_HOME="path to GIST_BOX_BUILDER"
```
For CSHELL copy this line to your .cshellrc:
```
setenv GBOX_GUI_HOME "path to GIST_BOX_BUILDER"
```

#### Windows 7 and Windows 10
>1. For ***Windows 7***, open the Start Menu and right click on **Computer**. Select **Properties**. (For ***Windows 10***, right click on the Start Menu and select ***System***.)
>1. Select ***Advanced system settings***.
>1. In the ***Advanced*** tab, select ***Environment Variables***.
>1. Select **New**.
>1. You will now be able to enter the environmental variable in the **New User Variable** dialog window.
    * You would enter "GBOX_GUI_HOME" in the **Variable name field** and "path to GIST_BOX_BUILDER" in the ***Variable value field***.
>1. Press ***OK***.
------------------
------------------
#### Usage
>1. Load the starting structure of the trajectory. 
>1. Load GIST_Box_Builder.tcl from the VMD Tk console. If the **GBOX_GUI_HOME** environment variable was not specified then select the location of the plugin with the directory selection dialog.
>1. The script will guide you to load the ligand (previously aligned to the trajectory).
>1. Resize or move the center of the grid box to include the area that you want to study.
>1. If you want to generate a gist input for cpptraj:
    2. Click the **Generate GIST cpptraj command** button and verify that the information is correct.
    2. Load the topology and trajectory file using the **AMBER Files** section.
    2. Save the gist input for cpptraj by selecting the save location and name in the **Actions** section.
>1. If you want to visualize the gridbox later save the gidbox as a vmd state file using the **Actions** section.

#### AMBER Files   
* Used to load the AMBER topology and trajectory for use in the creation of GIST input for cpptraj.  
#### Setup Parameters 
* Setup grid size and steep size for the grid center movement.  
* Setup the format for the AMBER topology and trajectory files in the GIST input files.  
#### Box Details  
* Increase the grid box size and move the grid box center.  
#### GIST cpptraj command  
* Generate the GIST command to use in the cpptraj input file.  
#### Actions 
* Save the cpptraj input file for the GIST calculation.  
* Save VMD visualization state of the box for later visualization.
