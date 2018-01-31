#===============================================================================
#
#          FILE: g_box_pdb_v7.tcl
# 
#         USAGE: source g_box_pdb_v7.tcl 
# 
#   DESCRIPTION: Generate the box for the GIST calculation and provide the command
#				 to run the gist calculation.
# 
#       OPTIONS: ---
#  REQUIREMENTS: VMD ver >= 1.8.3 and a ligand
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Anthony Cruz-Balberdy (acb), anthony.cruzbalberdy@lehamn.cuny.edu
#  ORGANIZATION: Lehman College
#       CREATED: 04/04/2017 11:38
#      REVISION: 0.7
#===============================================================================


#===============================================================================
# Define Procedures
#===============================================================================

#create gist_box.pdb
proc mkboxpdb {} \
{
	set b_pdb [open "gist_box.vmd" w]
	puts $b_pdb "HEADER    CORNERS OF BOX"
	puts $b_pdb "ATOM      1  DUA BOX     1       0.000   0.000   0.000"
	puts $b_pdb "ATOM      2  DUB BOX     1       0.000   0.000   0.000"
	puts $b_pdb "ATOM      3  DUC BOX     1       0.000   0.000   0.000"
	puts $b_pdb "ATOM      4  DUD BOX     1       0.000   0.000   0.000"
	puts $b_pdb "ATOM      5  DUE BOX     1       0.000   0.000   0.000"
	puts $b_pdb "ATOM      6  DUF BOX     1       0.000   0.000   0.000"
	puts $b_pdb "ATOM      7  DUG BOX     1       0.000   0.000   0.000"
	puts $b_pdb "ATOM      8  DUH BOX     1       0.000   0.000   0.000"
	puts $b_pdb "CONECT    1    2    4    5"
	puts $b_pdb "CONECT    2    1    3    6"
	puts $b_pdb "CONECT    3    2    4    7"
	puts $b_pdb "CONECT    4    1    3    8"
	puts $b_pdb "CONECT    5    1    6    8"
	puts $b_pdb "CONECT    6    2    5    7"
	puts $b_pdb "CONECT    7    3    6    8"
	puts $b_pdb "CONECT    8    4    5    7"
	close $b_pdb
}

#give gist command
proc gist_com {} \
{
	global vxl_sz
	global vxls
	global cntr

	set x_vxl [lindex $vxls 0]
	set y_vxl [lindex $vxls 1]
	set z_vxl [lindex $vxls 2]
	if { [expr $x_vxl%2] != 0 } { set x_vxl [expr $x_vxl + 1] }
	if { [expr $y_vxl%2] != 0 } { set y_vxl [expr $y_vxl + 1] }
	if { [expr $z_vxl%2] != 0 } { set z_vxl [expr $z_vxl + 1] }
	#print gist commant
	puts ""
	#puts -nonewline "gist gridcntr [format {%.3f %.3f %.3f} [lindex $cntr 0] [lindex $cntr 1] [lindex $cntr 2]] griddim [lindex $vxls 0] [lindex $vxls 1] [lindex $vxls 2] " 
	puts -nonewline "gist gridcntr [format {%.3f %.3f %.3f} [lindex $cntr 0] [lindex $cntr 1] [lindex $cntr 2]] griddim $x_vxl $y_vxl $z_vxl " 
	puts "gridspacn $vxl_sz out gits_out.dat\n"
}

#save cpptraj input
proc svcpp_in {topfilename trajfilename gist_cmd cpptraj_in} \
{
	set cppinfile [open $cpptraj_in w]
	puts $cppinfile "parm $topfilename\ntrajin $trajfilename\n$gist_cmd\ngo\nquit"
	close $cppinfile	
}

#save box visualization
proc svbox_vis {box_vmd} \
{
	global sel_b
	set b_vmd [open $box_vmd w]
	set pos 0
	set b_ori [measure $sel_b center]
	foreach coord [$sel_b get {x y z}] {
		set v_$pos $coord
		incr pos
	}
	puts $b_vmd "#!/usr/local/bin/vmd"
	puts $b_vmd "# VMD script written by GIST Box Builder"
	puts $b_vmd "#Load  box.pdb"
	puts $b_vmd "graphics top material \"Transparent\""
	puts $b_vmd "graphics top color 1"
	puts $b_vmd "graphics top triangle {$v_0} {$v_3} {$v_7}"
	puts $b_vmd "graphics top triangle {$v_0} {$v_4} {$v_7}"
	puts $b_vmd "graphics top triangle {$v_1} {$v_2} {$v_6}"
	puts $b_vmd "graphics top triangle {$v_1} {$v_5} {$v_6}"
	set middle [vecadd $v_0 [vecscale 0.90 [vecsub $v_1 $v_0]]]
	puts $b_vmd "graphics top cylinder {$v_0} {$middle} radius 0.250000 resolution 6 filled 0"
	puts $b_vmd "graphics top cone {$middle} {$v_1} radius 0.350000 radius2 0.000000 resolution 6"
	set p [vecadd $v_1 {1 0 0}]
	puts $b_vmd "graphics top text {$p} {X} size 1.500000 thickness 2.000000"
	puts $b_vmd "graphics top color 7"
	puts $b_vmd "graphics top triangle {$v_4} {$v_5} {$v_6}"
	puts $b_vmd "graphics top triangle {$v_4} {$v_7} {$v_6}"
	puts $b_vmd "graphics top triangle {$v_0} {$v_1} {$v_2}"
	puts $b_vmd "graphics top triangle {$v_0} {$v_3} {$v_2}"
	set middle [vecadd $v_0 [vecscale 0.90 [vecsub $v_4 $v_0]]]
	puts $b_vmd "graphics top cylinder {$v_0} {$middle} radius 0.250000 resolution 6 filled 0"
	puts $b_vmd "graphics top cone {$middle} {$v_4} radius 0.350000 radius2 0.000000 resolution 6"
	set p [vecadd $v_4 {-1 0 0}]
	puts $b_vmd "graphics top text {$p} {Y} size 1.500000 thickness 2.000000"
	puts $b_vmd "graphics top color 0"
	puts $b_vmd "graphics top triangle {$v_0} {$v_1} {$v_5}"
	puts $b_vmd "graphics top triangle {$v_0} {$v_4} {$v_5}"
	puts $b_vmd "graphics top triangle {$v_3} {$v_2} {$v_6}"
	puts $b_vmd "graphics top triangle {$v_3} {$v_7} {$v_6}"
	set middle [vecadd $v_0 [vecscale 0.90 [vecsub $v_3 $v_0]]]
	puts $b_vmd "graphics top cylinder {$v_0} {$middle} radius 0.250000 resolution 6 filled 0"
	puts $b_vmd "graphics top cone {$middle} {$v_3} radius 0.350000 radius2 0.000000 resolution 6"
	set p [vecadd $v_3 {-1 0 0}]
	puts $b_vmd "graphics top text {$p} {Z} size 1.500000 thickness 2.000000"
	puts $b_vmd "graphics top color 8"
	puts $b_vmd "graphics top sphere {$v_0} radius 0.800000 resolution 12"
	puts $b_vmd "graphics top color 6"
	puts $b_vmd "graphics top sphere {$b_ori} radius 0.800000 resolution 12"
	puts $b_vmd "graphics top material \"Transparent\""
	close $b_vmd
}

#draw box origin
proc vmd_draw_borig {mol orig} \
{
	set objs {}
	lappend objs [graphics $mol sphere $orig radius 0.80 resolution 12]
	return objs
}

#Function to draw the box axes
proc vmd_draw_arrow {mol start end coord} \
{
	#http://www.ks.uiuc.edu/Research/vmd/current/ug/node127.html
	set objs {}
    # an arrow is made of a cylinder and a cone
    set middle [vecadd $start [vecscale 0.90 [vecsub $end $start]]]
    lappend objs [graphics $mol cylinder $start $middle radius 0.25]
    lappend objs [graphics $mol cone $middle $end radius 0.35]
	switch -exact -- $coord {
		X {
			set p {1 0 0}
		}
		default {
			set p {-1 0 0}
		}  
	}  
    lappend objs [graphics $mol text [vecadd $end $p] $coord size 1.5 thickness 2]
    return objs
}

proc vmd_draw_arrow2 {mol start end} \
{
	#http://www.ks.uiuc.edu/Research/vmd/current/ug/node127.html
	set objs {}
    # an arrow is made of a cylinder and a cone
    set middle [vecadd $start [vecscale 0.90 [vecsub $end $start]]]
    lappend objs [graphics $mol cylinder $start $middle radius 0.05]
    lappend objs [graphics $mol cone $middle $end radius 0.15]
    return objs
}

#funtion draw box faces
proc vmd_draw_bface {mol sel_b} \
{
	draw delete all
	#http://www.ks.uiuc.edu/Research/vmd/mailing_list/vmd-l/3050.html
	#http://www.ks.uiuc.edu/Research/vmd/mailing_list/vmd-l/13169.html
	set objs {}
	#get vertx 
	set pos 0
	foreach coord [$sel_b get {x y z}] {
		set v_$pos $coord
		incr pos
	}
	set b_o [measure center $sel_b]
	draw material Transparent
	#draw transparent surface for box
	#X coord
	draw color red 
	lappend objs [graphics $mol triangle $v_0 $v_3 $v_7] 
	lappend objs [graphics $mol triangle $v_0 $v_4 $v_7]
	lappend objs [graphics $mol triangle $v_1 $v_2 $v_6]
	lappend objs [graphics $mol triangle $v_1 $v_5 $v_6]
	#draw X axes
	set objs [concat $objs [draw arrow $v_0 $v_1 "X"]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {1 0 0}]]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {-1 0 0}]]]
	#Y coord
	draw color green
	lappend objs [graphics $mol triangle $v_4 $v_5 $v_6] 
	lappend objs [graphics $mol triangle $v_4 $v_7 $v_6]
	lappend objs [graphics $mol triangle $v_0 $v_1 $v_2]
	lappend objs [graphics $mol triangle $v_0 $v_3 $v_2]
	#draw Y axes
	set objs [concat objs [draw arrow $v_0 $v_4 "Y"]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {0 1 0}]]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {0 -1 0}]]]
	#Z coord
	draw color blue
	lappend objs [graphics $mol triangle $v_0 $v_1 $v_5] 
	lappend objs [graphics $mol triangle $v_0 $v_4 $v_5]
	lappend objs [graphics $mol triangle $v_3 $v_2 $v_6]
	lappend objs [graphics $mol triangle $v_3 $v_7 $v_6]
	#draw Z axes 
	set objs [concat objs [draw arrow $v_0 $v_3 "Z"]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {0 0 1}]]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {0 0 -1}]]]

	#draw box origin
	draw color white
	set objs [concat objs [draw borig $v_0]]
	#retern list of objects incase we want to delete any
	return $objs
}

proc vmd_draw_boxorig {mol sel_b} \
{
	draw delete all
	set objs {}
	#get vertx 
	set pos 0
	foreach coord [$sel_b get {x y z}] {
		set v_$pos $coord
		incr pos
	}
	set b_o [measure center $sel_b]
	draw material Opaque
	#draw transparent surface for box
	#X coord
	draw color red 
	#draw X axes
	set objs [concat $objs [draw arrow $v_0 $v_1 "X"]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {1 0 0}]]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {-1 0 0}]]]
	#Y coord
	draw color green
	#draw Y axes
	set objs [concat objs [draw arrow $v_0 $v_4 "Y"]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {0 1 0}]]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {0 -1 0}]]]
	#Z coord
	draw color blue
	#draw Z axes 
	set objs [concat objs [draw arrow $v_0 $v_3 "Z"]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {0 0 1}]]]
	set objs [concat $objs [draw arrow2 $b_o [vecadd $b_o {0 0 -1}]]]
	#draw box origin
	draw color white
	set objs [concat objs [draw borig $v_0]]
	#retern list of objects incase we want to delete any
	return $objs
}

proc mkbox {} \
{
	mol new gist_box.vmd type pdb waitfor all
	mol rename top box
	#change box properties
	mol delrep 0 top
	mol representation Licorice 0.100000 12.000000 12.000000
	mol color ColorID 6
	mol selection {all}
	mol material Opaque
	mol addrep top
	mol selupdate 0 top 0
	mol colupdate 0 top 0
}

proc ldim {} \
{
	global minmax
	#ligand size in xyz coord
	set l_xdim [expr [lindex [lindex $minmax 1] 0]-[lindex [lindex $minmax 0] 0]]
	set l_ydim [expr [lindex [lindex $minmax 1] 1]-[lindex [lindex $minmax 0] 1]]
	set l_zdim [expr [lindex [lindex $minmax 1] 2]-[lindex [lindex $minmax 0] 2]]
	return [list $l_xdim $l_ydim $l_zdim]
}

proc boxo {} \
{
	global l_dims
	global cntr
	global box
	#get box origin
	set box_o [expr (([lindex $cntr 0] - ([lindex $l_dims 0]/2.0)) - $box)]
	lappend box_o [expr (([lindex $cntr 1] - ([lindex $l_dims 1]/2.0)) - $box)]
	lappend box_o [expr (([lindex $cntr 2] - ([lindex $l_dims 2]/2.0)) - $box)]
	return $box_o
}

proc up_boxcntr {} \
{
	global sel_b
	global cntr
	set cntr [measure center $sel_b]
}
proc bdim {} \
{
	global l_dims
	global box
	#get box size coord
	set b_xdim [expr ($box * 2) + [lindex $l_dims 0]]
	set b_ydim [expr ($box * 2) + [lindex $l_dims 1]]
	set b_zdim [expr ($box * 2) + [lindex $l_dims 2]]
	return [list $b_xdim $b_ydim $b_zdim]
}

proc bdimtrans {} \
{
	global b_dims
	global b_molid
	#create trans factors
	set b_xdim_trans [list [lindex $b_dims 0] 0 0]
	set b_ydim_trans [list 0 [lindex $b_dims 1] 0]
	set b_zdim_trans [list 0 0 [lindex $b_dims 2]]
	#create selection to move box vertiz
	set sel_b_mvBx [atomselect $b_molid "name DUB DUC DUF DUG"]
	set sel_b_mvBy [atomselect $b_molid "name DUE DUF DUG DUH"]
	set sel_b_mvBz [atomselect $b_molid "name DUC DUD DUG DUH"]
	#move box vertiz
	$sel_b_mvBx moveby $b_xdim_trans
	$sel_b_mvBy moveby $b_ydim_trans
	$sel_b_mvBz moveby $b_zdim_trans
}

proc getvxl {} \
{
	global vxl_sz
	set vxl_sz_dx [format {%.3f} [expr {1.0 / $vxl_sz}]]

	global b_dims
	#get num voxels
	set x_vxl [expr {round([lindex $b_dims 0] * $vxl_sz_dx)}]
	set y_vxl [expr {round([lindex $b_dims 1] * $vxl_sz_dx)}]
	set z_vxl [expr {round([lindex $b_dims 2] * $vxl_sz_dx)}]
	#check if voxel is even if not make it even
	#if { [expr $x_vxl%2] != 0 } { set x_vxl [expr $x_vxl + 1] }
	#if { [expr $y_vxl%2] != 0 } { set y_vxl [expr $y_vxl + 1] }
	#if { [expr $z_vxl%2] != 0 } { set z_vxl [expr $z_vxl + 1] }
	return [list $x_vxl $y_vxl $z_vxl]
}

proc up_vxl_all {} \
{
	global vxls
	global sel_b
	global vxl_sz
	set vxl_sz_dx [format {%.3f} [expr {1.0 / $vxl_sz}]]
	
	set pos 0
	foreach coord [$sel_b get {x y z}] {
		set v_$pos $coord
		incr pos
	}
	#get num voxels
	set x_vxl [expr {round([vecdist $v_0 $v_1] * $vxl_sz_dx)}] 
	set y_vxl [expr {round([vecdist $v_0 $v_4] * $vxl_sz_dx)}] 
	set z_vxl [expr {round([vecdist $v_0 $v_3] * $vxl_sz_dx)}]
	#check if voxel is even if not make it even
	#if { [expr $x_vxl%2] != 0 } { set x_vxl [expr $x_vxl + 1] }
	#if { [expr $y_vxl%2] != 0 } { set y_vxl [expr $y_vxl + 1] }
	#if { [expr $z_vxl%2] != 0 } { set z_vxl [expr $z_vxl + 1] }
	set vxls [list $x_vxl $y_vxl $z_vxl]
}

proc up_vxl_sing {sel_b axis} \
{
	global vxl_sz
	set vxl_sz_dx [format {%.3f} [expr {1.0 / $vxl_sz}]]
	set pos 0
	foreach coord [$sel_b get {x y z}] {
		set v_$pos $coord
		incr pos
	}
	switch -exact -- $axis {
		X {
			set x_vxl [expr {round([vecdist $v_0 $v_1] * $vxl_sz_dx)}] 
			#if { [expr $x_vxl%2] != 0 } { set x_vxl [expr $x_vxl + 1] }
			return $x_vxl
		}
		Y {
			set y_vxl [expr {round([vecdist $v_0 $v_4] * $vxl_sz_dx)}]
			#if { [expr $y_vxl%2] != 0 } { set y_vxl [expr $y_vxl + 1] }
			return $y_vxl
		}
		Z {
			set z_vxl [expr {round([vecdist $v_0 $v_3] * $vxl_sz_dx)}]
			#if { [expr $z_vxl%2] != 0 } { set z_vxl [expr $z_vxl + 1] }
			return $z_vxl
		}
		default {
			puts "$coord ::> Is not a valid option"
		}
	}
}

proc mv_bface {facedir} \
{
	global d_objs
	global sel_b
	global sel_b_grow_nx
	global sel_b_grow_px
	global sel_b_grow_ny
	global sel_b_grow_py
	global sel_b_grow_nz
	global sel_b_grow_pz
	global vxls

	global vxl_sz
	set vxl_sz_dx [format {%.3f} [expr  {$vxl_sz / 2}]]

	if { [llength $d_objs] > 0 } {
		draw delete all
		set d_objs {}
	}
	switch -exact -- $facedir {
		px {
			$sel_b_grow_nx moveby [vecscale $vxl_sz_dx { -1 0 0 }]
			$sel_b_grow_px moveby [vecscale $vxl_sz_dx { 1 0 0 }]
			lappend d_objs [draw bface $sel_b]
			lset vxls 0 [up_vxl_sing $sel_b "X"] 
		}
		nx {
			$sel_b_grow_nx moveby [vecscale $vxl_sz_dx { 1 0 0 }]
			$sel_b_grow_px moveby [vecscale $vxl_sz_dx { -1 0 0 }]
			lappend d_objs [draw bface $sel_b]	
			lset vxls 0 [up_vxl_sing $sel_b "X"] 
		}
		py {
			$sel_b_grow_ny moveby [vecscale $vxl_sz_dx { 0 -1 0 }]
			$sel_b_grow_py moveby [vecscale $vxl_sz_dx { 0 1 0 }]
			lappend d_objs [draw bface $sel_b]
			lset vxls 1 [up_vxl_sing $sel_b "Y"]
		}
		ny {
			$sel_b_grow_ny moveby [vecscale $vxl_sz_dx { 0 1 0 }]
			$sel_b_grow_py moveby [vecscale $vxl_sz_dx { 0 -1 0 }]
			lappend d_objs [draw bface $sel_b]
			lset vxls 1 [up_vxl_sing $sel_b "Y"]
		}
		pz { 
			$sel_b_grow_nz moveby [vecscale $vxl_sz_dx { 0 0 -1 }]
			$sel_b_grow_pz moveby [vecscale $vxl_sz_dx { 0 0 1 }]
			lappend d_objs [draw bface $sel_b]
			lset vxls 2 [up_vxl_sing $sel_b "Z"] 
		}
		nz {
			$sel_b_grow_nz moveby [vecscale $vxl_sz_dx { 0 0 1 }]
			$sel_b_grow_pz moveby [vecscale $vxl_sz_dx { 0 0 -1 }]
			lappend d_objs [draw bface $sel_b]
			lset vxls 2 [up_vxl_sing $sel_b "Z"]
		}
		default {
			puts "$facedir ::> Not an option"
		}
	}
}

proc mv_bcntr {cntrdir} \
{
	global d_objs
	global sel_b
	global sz_dx
	
	if { [llength $d_objs] > 0 } {
		draw delete all
		set d_objs {}
	}
	switch -exact -- $cntrdir {
		c_px {
			$sel_b moveby [vecscale $sz_dx { 1 0 0 }]
			lappend d_objs [draw bface $sel_b]	
		}
		c_nx {
			$sel_b moveby [vecscale $sz_dx { -1 0 0 }]
			lappend d_objs [draw bface $sel_b]
		}
		c_py {
			$sel_b moveby [vecscale $sz_dx { 0 1 0 }]
			lappend d_objs [draw bface $sel_b]
		}
		c_ny {
			$sel_b moveby [vecscale $sz_dx { 0 -1 0 }]
			lappend d_objs [draw bface $sel_b]
		}
		c_pz {
			$sel_b moveby [vecscale $sz_dx { 0 0 1 }]
			lappend d_objs [draw bface $sel_b]
		}
		c_nz {
			$sel_b moveby [vecscale $sz_dx { 0 0 -1 }]
			lappend d_objs [draw bface $sel_b]
		}
		default {
			puts "$cntrdir ::> Not an option"
		}
	}
	up_boxcntr
}

proc man_crtl {args} \
{
	#===============================================================================
	# Start Manual Options Faces
	#===============================================================================

	#grow box in x
	user add key X {
		mv_bface "px"
	}
	#grow box in x
	user add key x {
		mv_bface "nx"	
	}
	#grow box in y
	user add key Y {
		mv_bface "py"	
	}
	#grow box in y
	user add key y {
		mv_bface "ny"	
	}
	#grow box in z
	user add key Z {
		mv_bface "pz"	
	}
	#grow box in z
	user add key z {
		mv_bface "nz"
	}

	#===============================================================================
	# Start Manual Options Center
	#===============================================================================

	user add key {Right} {
		mv_bcntr "c_px"
	}

	user add key {Left} {
		mv_bcntr "c_nx"
	}

	user add key {Up} {
		mv_bcntr "c_py"
	}

	user add key {Down} {
		mv_bcntr "c_ny"
	}

	user add key {>} {
		mv_bcntr "c_pz"
	}

	user add key {<} {
		mv_bcntr "c_nz"
	}
}

#===============================================================================
# Start Script
#===============================================================================

#load box pdb and rename
mkboxpdb
mkbox

#delete intermediate file
file delete "gist_box.vmd"
#select the box
set sel_b [atomselect top "all"]

#if load protein and ligand the the box this is
#going to be the order
set b_molid [$sel_b molid]
set l_molid [expr $b_molid -1]

#setup default values for the box
#7 A from ligand edge 
set box 7
#voxels size
set sz_dx 0.25
set vxl_sz 0.5
#selecting the ligand
set sel_l [atomselect $l_molid "all not water"]
#get ligand center
set cntr [measure center $sel_l]

#ligand minmax coord
set minmax [measure minmax $sel_l]

#ligand size in xyz coord
set l_dims [ldim]
#get box origin
set box_o [boxo]
#Move box dummies to origin
$sel_b moveto $box_o
#get box size coord
set b_dims [bdim]
#create trans factors
#move box vertiz
bdimtrans
#get num voxels and fix them
set vxls [getvxl]
#reste view
display resetview
#print gist commant
gist_com
#puts -nonewline "gist gridcntr $cntr griddim $x_vxl $y_vxl $z_vxl " 
#puts "gridspacn 0.5 out gits_out.dat"

set d_objs {}
lappend d_objs [draw bface $sel_b]

#For manual creation of the box
#create selection to grow box in the different axex
set sel_b_grow_nx [atomselect $b_molid "name DUA DUD DUE DUH"]
set sel_b_grow_px [atomselect $b_molid "name DUB DUC DUF DUG"]
set sel_b_grow_ny [atomselect $b_molid "name DUA DUB DUC DUD"]
set sel_b_grow_py [atomselect $b_molid "name DUE DUF DUG DUH"]
set sel_b_grow_nz [atomselect $b_molid "name DUA DUB DUE DUF"]
set sel_b_grow_pz [atomselect $b_molid "name DUC DUD DUG DUH"]

#initialize gui

#center coord
set x_cent [format {%.3f} [lindex $cntr 0]]
set y_cent [format {%.3f} [lindex $cntr 1]]
set z_cent [format {%.3f} [lindex $cntr 2]]
#voxls
set x_face [lindex $vxls 0]
set y_face [lindex $vxls 1]
set z_face [lindex $vxls 2]
#input and output files
set topfilename "prmtop file"
set trajfilename "trajectory file"
set cpptraj_in "cpptraj input"
set box_vmd "box vmd file"



