#===============================================================================
#
#          FILE: GIST_Box_Builder.tcl
# 
#         USAGE: source GIST_Box_Builder.tcl 
# 
#   DESCRIPTION: Wrapper GIST_Box_Builder Gui interface in VMD
#                Need to have a ligand
# 
#       OPTIONS: ---
#  REQUIREMENTS: VMD ver >= 1.9 and a ligand
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Anthony Cruz-Balberdy (acb), anthony.cruzbalberdy@lehamn.cuny.edu
#  ORGANIZATION: Lehman College
#       CREATED: 04/24/2017 14:08
#      REVISION: 2.0
#===============================================================================

package require Tk

set envok 0
#Setup environment
if { [ array names env GBOX_HOME ] == "" } {
	set answer [tk_messageBox -message "GBOX_HOME is not set. Want to select the GBOX_HOME directory?" \
		-icon warning -type yesno -title "GIST BOX Builder"]
	switch -exact -- $answer {
		yes {
			set GBOX_GUI_HOME [tk_chooseDirectory -title "Choose GBOX_HOME directory" -initialdir [pwd] -mustexist true]
			set envok 1
		}
		no {
			tk_messageBox -message "Reload the script after seting the GBOX_HOME environmental variable" \
        			-icon info -type ok -title "GIST BOX Builder"
		}
	}
	#set GBOX_GUI_HOME [pwd]
} else {
	set GBOX_GUI_HOME $env(GBOX_HOME)
	set envok 1
}
 


proc splash {} {
	global GBOX_GUI_HOME
    toplevel .x -bd 3 -relief raised
    wm withdraw .x
    set sw [winfo screenwidth .]
    set sh [winfo screenheight .]
    set statusMsg "GIST Box Builder"
    image create photo "title" \
	-file [file join $GBOX_GUI_HOME images GIST.gif]
	#/Users/acruz/programming/vmd_gui/images/GIST.gif
	#
	#"/home/acruz/Development/vmd_gui/GIST.gif"
    wm overrideredirect .x 1
    label .x.l -image title -bd 1 -relief sunken -background black
    pack .x.l -side top -expand 1 -fill both
    label .x.status -relief flat -background white -foreground black \
    	-text "GIST BOX Builder" -font "Helvetica 20"
    pack .x.status -side bottom -expand 1 -fill both
    set x [expr {($sw - 200)/2}]
    set y [expr {($sh - 250)/2}]
    wm geometry .x +$x+$y
    wm deiconify .x
    #update idletasks
    after 3000 {catch {destroy .x}}
}

if {$envok == 1} {

	splash

	after 3000 {
	set ready 0
	#Check if we have a ligand or a protein before loading the script
	if {[llength [molinfo list]] == 0 || [[atomselect top "all not water"] num] > 200} {
		set answer [tk_messageBox -message "Need to load a ligand first!!!" \
	        -icon warning -type okcancel -title "GIST BOX Builder" \
	        -detail "Let's load a ligand..."]
	    switch -exact -- $answer {
	    	ok {
					set types {
					    {{All Structure Files}        *             }
					}
					set ligfile [tk_getOpenFile -title "Load ligand file" -filetypes $types]
					if {$ligfile ne ""} {
						# Open the file ...
						mol new $ligfile 
						mol rename top ligand
						mol delrep 0 top
						mol representation CPK 1.000000 0.300000 12.000000 12.000000
						mol selection {all not water}
						mol material Opaque
						mol addrep top
						mol selupdate 0 top 0
						mol colupdate 0 top 0
						set ready 1
					} else {
						tk_messageBox -message "There is a problem. Reload the script!" \
							-icon warning -type ok -title "GIST BOX Builder"
					}
			}
			cancel {
					tk_messageBox -message "Reload the script after loading a ligand!" \
	        			-icon info -type ok -title "GIST BOX Builder"
	        }
		}
	} else {
		set ready 1
	}

	if { $ready == 1} {
		# Load the gui
		source [file join $GBOX_GUI_HOME resources gbox_gui_v3.tcl]
		#/home/acruz/Development/vmd_gui/gbox_gui_v3.tcl
		#source /Users/acruz/programming/vmd_gui/resources/gbox_gui_v3.tcl

		# Load the script
		source [file join $GBOX_GUI_HOME resources gbox_pdb_v8.tcl]
		#/home/acruz/Development/vmd_scripts/gbox_pdb_v7.tcl
		#source /Users/acruz/programming/vmd_gui/resources/gbox_pdb_v8.tcl
	}

	}
}