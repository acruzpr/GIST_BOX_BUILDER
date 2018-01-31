#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    package require Tk
    switch $tcl_platform(platform) {
	windows {
	    option add *Button.padY 0
	}
	default {
	    option add *Scrollbar.width 10
	    option add *Scrollbar.highlightThickness 0
	    option add *Scrollbar.elementBorderWidth 2
	    option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v8.6.0.5 Project
#


#############################################################################
# vTcl Code to Load Stock Fonts


if {![info exist vTcl(sourcing)]} {
set vTcl(fonts,counter) 0
#############################################################################
## Procedure:  vTcl:font:add_font

proc ::vTcl:font:add_font {font_descr font_type {newkey {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[info exists ::vTcl(fonts,$font_descr,object)]} {
	## cool, it already exists
	return $::vTcl(fonts,$font_descr,object)
    }

     incr ::vTcl(fonts,counter)
     set newfont [eval font create $font_descr]
     lappend ::vTcl(fonts,objects) $newfont

     ## each font has its unique key so that when a project is
     ## reloaded, the key is used to find the font description
     if {$newkey == ""} {
	  set newkey vTcl:font$::vTcl(fonts,counter)

	  ## let's find an unused font key
	  while {[vTcl:font:get_font $newkey] != ""} {
	     incr ::vTcl(fonts,counter)
	     set newkey vTcl:font$::vTcl(fonts,counter)
	  }
     }

     set ::vTcl(fonts,$newfont,type)       $font_type
     set ::vTcl(fonts,$newfont,key)	$newkey
     set ::vTcl(fonts,$newfont,font_descr) $font_descr
     set ::vTcl(fonts,$font_descr,object)  $newfont
     set ::vTcl(fonts,$newkey,object)      $newfont

     lappend ::vTcl(fonts,$font_type) $newfont

     ## in case caller needs it
     return $newfont
}

#############################################################################
## Procedure:  vTcl:font:getFontFromDescr

proc ::vTcl:font:getFontFromDescr {font_descr} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[info exists ::vTcl(fonts,$font_descr,object)]} {
	return $::vTcl(fonts,$font_descr,object)
    } else {
	return ""
    }
}

}
#############################################################################
# vTcl Code to Load User Fonts

vTcl:font:add_font \
    "-family Courier -size 10 -weight normal -slant roman -underline 0 -overstrike 0" \
    user \
    vTcl:font12
vTcl:font:add_font \
    "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0" \
    user \
    vTcl:font11
#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
	show {
	    if {$exists} {
		wm deiconify $newname
	    } elseif {[info procs vTclWindow$name] != ""} {
		eval "vTclWindow$name $newname $rest"
	    }
	    if {[winfo exists $newname] && [wm state $newname] == "normal"} {
		vTcl:FireEvent $newname <<Show>>
	    }
	}
	hide    {
	    if {$exists} {
		wm withdraw $newname
		vTcl:FireEvent $newname <<Hide>>
		return}
	}
	iconify { if $exists {wm iconify $newname; return} }
	destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
	interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
	set widget($top_or_alias,$alias) $target
	if {$cmdalias} {
	    interp alias {} $top_or_alias.$alias {} $widgetProc $target
	}
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
	set tag_events [bind $bindtag]
	set stop_processing 0
	foreach tag_event $tag_events {
	    if {$tag_event == $event} {
		set bind_code [bind $bindtag $tag_event]
		foreach rep "\{%W $target\} $params" {
		    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
		}
		set result [catch {uplevel #0 $bind_code} errortext]
		if {$result == 3} {
		    ## break exception, stop processing
		    set stop_processing 1
		} elseif {$result != 0} {
		    bgerror $errortext
		}
		break
	    }
	}
	if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
	## If no arguments, returns the path the alias points to
	return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top44
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    set site_3_0 $base.lab47
    set site_4_0 $site_3_0.lab44
    set site_4_0 $site_3_0.lab49
    set site_3_0 $base.lab48
    set site_4_0 $site_3_0.lab45
    set site_4_0 $site_3_0.lab46
    set site_3_0 $base.lab49
    set site_3_0 $base.lab45
    set site_3_0 $base.lab44
    set site_4_0 $site_3_0.lab45
    set site_4_0 $site_3_0.lab50
    set site_4_0 $site_3_0.lab43
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {

}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 1x1+0+0; update
    wm maxsize $top 3825 1170
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl.tcl"
    bindtags $top "$top Vtcl.tcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top44 {base} {
    if {$base == ""} {
        set base .top44
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
		-menu "$top.m50" -highlightcolor black 
    wm focusmodel $top passive
    wm geometry $top 590x519+432+142; update
    wm maxsize $top 1351 716
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    wm title $top "GIST Box Builder"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    labelframe $top.lab47 \
		-borderwidth 5 -foreground black -text {AMBER Files} -height 155 \
		-highlightcolor black -width 340 
    vTcl:DefineAlias "$top.lab47" "Labelframe1" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.lab47
    labelframe $site_3_0.lab44 \
		-foreground black -text {Prmtop file} -height 60 \
		-highlightcolor black -width 315 
    vTcl:DefineAlias "$site_3_0.lab44" "Labelframe6" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.lab44
    label $site_4_0.lab47 \
		-activebackground {#f9f9f9} -activeforeground black \
		-font [vTcl:font:getFontFromDescr "-family Courier -size 10 -weight normal -slant roman -underline 0 -overstrike 0"] \
		-foreground black -highlightcolor black -relief sunken \
		-text {prmtop file} -textvariable topfilename 
    vTcl:DefineAlias "$site_4_0.lab47" "Label7" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but48 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {set types {
    {{prmtop AMBER7 PARM}      {.prmtop}    }
    {{parm7 AMBER7 PARM}      {.parm7}      }
    {{All Files}        *                   }
}
if {[catch {set topfilename_full [tk_getOpenFile -title "Open AMBER PARM file" -filetypes $types]}]} {
}
if { $topfilename == ""} {
    set topfilename "prmtop file"
} else {
    set topfilename [file tail $topfilename_full]
}} \
		-cursor crosshair -foreground black -highlightcolor black \
		-text Load... 
    vTcl:DefineAlias "$site_4_0.but48" "Button13" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_0.lab47 \
		-in $site_4_0 -x 5 -y 21 -width 232 -height 24 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but48 \
		-in $site_4_0 -x 246 -y 19 -width 62 -height 27 -anchor nw \
		-bordermode ignore 
    labelframe $site_3_0.lab49 \
		-foreground black -text {Trajectory file} -height 60 \
		-highlightcolor black -width 315 
    vTcl:DefineAlias "$site_3_0.lab49" "Labelframe7" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.lab49
    label $site_4_0.lab50 \
		-activebackground {#f9f9f9} -activeforeground black \
		-font [vTcl:font:getFontFromDescr "-family Courier -size 10 -weight normal -slant roman -underline 0 -overstrike 0"] \
		-foreground black -highlightcolor black -relief sunken \
		-text {trajectory file} -textvariable trajfilename 
    vTcl:DefineAlias "$site_4_0.lab50" "Label8" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but51 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {set types {
    {{NETCDF AMBER TRAJ}      {.nc}    }
    {{mdcrd AMBER7 TRAJ}      {.mdcrd} }
    {{All Files}        *              }
}
if {[catch {set trajfilename_full [tk_getOpenFile -title "Open AMBER Traj file" -filetypes $types]}]} {
}
if {$trajfilename_full == ""} {
    set trajfilename "trajectory file"
} else {
    set trajfilename [file tail $trajfilename_full]
}} \
		-cursor crosshair -foreground black -highlightcolor black \
		-text Load... 
    vTcl:DefineAlias "$site_4_0.but51" "Button14" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_0.lab50 \
		-in $site_4_0 -x 6 -y 24 -width 232 -height 24 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but51 \
		-in $site_4_0 -x 246 -y 22 -width 62 -height 27 -anchor nw \
		-bordermode ignore 
    place $site_3_0.lab44 \
		-in $site_3_0 -x 10 -y 15 -width 315 -height 60 -anchor nw \
		-bordermode ignore 
    place $site_3_0.lab49 \
		-in $site_3_0 -x 10 -y 81 -width 315 -height 60 -anchor nw \
		-bordermode ignore 
    labelframe $top.lab48 \
		-borderwidth 5 -foreground black -text {Box Details} -height 120 \
		-highlightcolor black -width 555 
    vTcl:DefineAlias "$top.lab48" "Labelframe2" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.lab48
    labelframe $site_3_0.lab45 \
		-foreground black -text {Move Box Side} -height 85 \
		-highlightcolor black -width 250 
    vTcl:DefineAlias "$site_3_0.lab45" "Labelframe4" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.lab45
    button $site_4_0.but51 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bface nx
set x_face [lindex $vxls 0]} -cursor hand1 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#ff0000} -highlightcolor black -text -X 
    vTcl:DefineAlias "$site_4_0.but51" "Button1" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but52 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bface px
set x_face [lindex $vxls 0]} -cursor hand1 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#ff0000} -highlightcolor black -text +X 
    vTcl:DefineAlias "$site_4_0.but52" "Button2" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but53 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bface ny
set y_face [lindex $vxls 1]} -cursor hand1 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#00ff00} -highlightcolor black -text -Y 
    vTcl:DefineAlias "$site_4_0.but53" "Button3" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but54 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bface py
set y_face [lindex $vxls 1]} -cursor hand1 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#00ff00} -highlightcolor black -state active -text +Y 
    vTcl:DefineAlias "$site_4_0.but54" "Button4" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but55 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bface nz
set z_face [lindex $vxls 2]} -cursor hand1 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#0000ff} -highlightcolor black -text -Z 
    vTcl:DefineAlias "$site_4_0.but55" "Button5" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but56 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bface pz
set z_face [lindex $vxls 2]} -cursor hand1 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#0000ff} -highlightcolor black -text +Z 
    vTcl:DefineAlias "$site_4_0.but56" "Button6" vTcl:WidgetProc "Toplevel1" 1
    label $site_4_0.lab58 \
		-activebackground {#f9f9f9} -activeforeground black \
		-foreground {#ff0000} -highlightcolor black -relief sunken \
		-text {X coord} -textvariable x_face 
    vTcl:DefineAlias "$site_4_0.lab58" "Label2" vTcl:WidgetProc "Toplevel1" 1
    label $site_4_0.lab60 \
		-activebackground {#f9f9f9} -activeforeground black \
		-foreground {#00ff00} -highlightcolor black -relief sunken \
		-text {Y coord} -textvariable y_face 
    vTcl:DefineAlias "$site_4_0.lab60" "Label3" vTcl:WidgetProc "Toplevel1" 1
    label $site_4_0.lab61 \
		-activebackground {#f9f9f9} -activeforeground black \
		-foreground {#0000ff} -highlightcolor black -relief sunken \
		-text {Z coord} -textvariable z_face 
    vTcl:DefineAlias "$site_4_0.lab61" "Label4" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_0.but51 \
		-in $site_4_0 -x 4 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but52 \
		-in $site_4_0 -x 40 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but53 \
		-in $site_4_0 -x 89 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but54 \
		-in $site_4_0 -x 124 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but55 \
		-in $site_4_0 -x 174 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but56 \
		-in $site_4_0 -x 209 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.lab58 \
		-in $site_4_0 -x 5 -y 25 -width 66 -anchor nw -bordermode ignore 
    place $site_4_0.lab60 \
		-in $site_4_0 -x 90 -y 25 -width 66 -anchor nw -bordermode ignore 
    place $site_4_0.lab61 \
		-in $site_4_0 -x 175 -y 25 -width 66 -anchor nw -bordermode ignore 
    labelframe $site_3_0.lab46 \
		-foreground black -text {Move Box Center} -height 85 \
		-highlightcolor black -width 250 
    vTcl:DefineAlias "$site_3_0.lab46" "Labelframe5" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.lab46
    label $site_4_0.lab63 \
		-activebackground {#f9f9f9} -activeforeground black \
		-foreground {#ff0000} -highlightcolor black -relief sunken \
		-text {x coord} -textvariable x_cent 
    vTcl:DefineAlias "$site_4_0.lab63" "Label1" vTcl:WidgetProc "Toplevel1" 1
    label $site_4_0.lab65 \
		-activebackground {#f9f9f9} -activeforeground black \
		-foreground {#00ff00} -highlightcolor black -relief sunken \
		-text {y coord} -textvariable y_cent 
    vTcl:DefineAlias "$site_4_0.lab65" "Label5" vTcl:WidgetProc "Toplevel1" 1
    label $site_4_0.lab66 \
		-activebackground {#f9f9f9} -activeforeground black \
		-foreground {#0000ff} -highlightcolor black -relief sunken \
		-text {z coord} -textvariable z_cent 
    vTcl:DefineAlias "$site_4_0.lab66" "Label6" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but67 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bcntr c_nx
set x_cent [format {%.3f} [lindex $cntr 0]]} \
		-cursor hand2 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#ff0000} -highlightcolor black -text -X 
    vTcl:DefineAlias "$site_4_0.but67" "Button7" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but68 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bcntr c_px
set x_cent [format {%.3f} [lindex $cntr 0]]} \
		-cursor hand2 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#ff0000} -highlightcolor black -text +X 
    vTcl:DefineAlias "$site_4_0.but68" "Button8" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but69 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bcntr c_ny
set y_cent [format {%.3f} [lindex $cntr 1]]} \
		-cursor hand2 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#00ff00} -highlightcolor black -text -Y 
    vTcl:DefineAlias "$site_4_0.but69" "Button9" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but70 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bcntr c_py
set y_cent [format {%.3f} [lindex $cntr 1]]} \
		-cursor hand2 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#00ff00} -highlightcolor black -text +Y 
    vTcl:DefineAlias "$site_4_0.but70" "Button10" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but71 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bcntr c_nz
set z_cent [format {%.3f} [lindex $cntr 2]]} \
		-cursor hand2 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#0000ff} -highlightcolor black -text -Z 
    vTcl:DefineAlias "$site_4_0.but71" "Button11" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but72 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {mv_bcntr c_pz
set z_cent [format {%.3f} [lindex $cntr 2]]} \
		-cursor hand2 \
		-font [vTcl:font:getFontFromDescr "-family Helvetica -size 10 -weight bold -slant roman -underline 0 -overstrike 0"] \
		-foreground {#0000ff} -highlightcolor black -text +Z 
    vTcl:DefineAlias "$site_4_0.but72" "Button12" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_0.lab63 \
		-in $site_4_0 -x 5 -y 25 -width 66 -anchor nw -bordermode ignore 
    place $site_4_0.lab65 \
		-in $site_4_0 -x 90 -y 25 -width 66 -anchor nw -bordermode ignore 
    place $site_4_0.lab66 \
		-in $site_4_0 -x 175 -y 25 -width 66 -anchor nw -bordermode ignore 
    place $site_4_0.but67 \
		-in $site_4_0 -x 4 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but68 \
		-in $site_4_0 -x 40 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but69 \
		-in $site_4_0 -x 89 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but70 \
		-in $site_4_0 -x 125 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but71 \
		-in $site_4_0 -x 173 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but72 \
		-in $site_4_0 -x 210 -y 50 -width 33 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_3_0.lab45 \
		-in $site_3_0 -x 20 -y 20 -width 250 -height 85 -anchor nw \
		-bordermode ignore 
    place $site_3_0.lab46 \
		-in $site_3_0 -x 285 -y 21 -width 250 -height 85 -anchor nw \
		-bordermode ignore 
    labelframe $top.lab49 \
		-borderwidth 5 -foreground black -relief ridge \
		-text {GIST cpptraj comman} -height 100 -highlightcolor black \
		-width 555 
    vTcl:DefineAlias "$top.lab49" "Labelframe3" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.lab49
    message $site_3_0.mes44 \
		-background {#ffffff} -cursor xterm -foreground black \
		-highlightcolor black -relief sunken -text {Generate GIST command} \
		-textvariable gist_cmd -width 533 
    vTcl:DefineAlias "$site_3_0.mes44" "Message1" vTcl:WidgetProc "Toplevel1" 1
    button $site_3_0.but55 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command [list vTcl:DoCmdOption $site_3_0.but55 {up_vxl_all
set x_vxl [lindex $vxls 0]
set y_vxl [lindex $vxls 1]
set z_vxl [lindex $vxls 2]

if { [expr $x_vxl%2] !=0 } { set x_vxl [expr $x_vxl + 1] }
if { [expr $y_vxl%2] !=0 } { set y_vxl [expr $y_vxl + 1] }
if { [expr $z_vxl%2] !=0 } { set z_vxl [expr $z_vxl + 1] }

set gist_cmd "gist gridcntr [format {%.3f %.3f %.3f} [lindex $cntr 0] [lindex $cntr 1] [lindex $cntr 2]] griddim $x_vxl $y_vxl $z_vxl gridspacn $vxl_sz out gist_out.dat"}] \
		-cursor cross_reverse -foreground black -highlightcolor black \
		-text {Generate GIST command} 
    vTcl:DefineAlias "$site_3_0.but55" "Button16" vTcl:WidgetProc "Toplevel1" 1
    place $site_3_0.mes44 \
		-in $site_3_0 -x 12 -y 20 -width 533 -height 35 -anchor nw \
		-bordermode ignore 
    place $site_3_0.but55 \
		-in $site_3_0 -x 190 -y 63 -width 176 -height 26 -anchor nw \
		-bordermode ignore 
    menu $top.m50 \
		-activebackground {#f9f9f9} -activeforeground black -cursor {} \
		-foreground black 
    labelframe $top.lab45 \
		-borderwidth 5 -foreground black -relief ridge -text Actions \
		-height 90 -highlightcolor black -width 555 
    vTcl:DefineAlias "$top.lab45" "Labelframe8" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.lab45
    button $site_3_0.but48 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {set types {
    {{in cpptraj input}       {.in}}
    {{All Files}        *        }
}
if {[catch {set cpptraj_in [tk_getSaveFile -title "Save cpptraj input file" -filetypes $types]}]} {
    #set cppinfile [open $cpptraj_in w]
    #puts $cppinfile "parm $topfilename\ntrajin $trajfilename\n$gist_cmd\ngo\nquit"
    #close $cppinfile
    #svcpp_in $topfilename $trajfilename $gist_cmd $cpptraj_in
}
if {$cpptraj_in == ""} {
    set cpptraj_in "cpptraj input"
} else {
    if {$fopt == 1} {
        svcpp_in $topfilename $trajfilename $gist_cmd $cpptraj_in
    } else {
        svcpp_in $topfilename_full $trajfilename_full $gist_cmd $cpptraj_in
    }
}} \
		-cursor pencil -foreground black -highlightcolor black \
		-text {Save cpptraj input} 
    vTcl:DefineAlias "$site_3_0.but48" "Button15" vTcl:WidgetProc "Toplevel1" 1
    button $site_3_0.but56 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {set types {
    {{vmd VMD state}    {.vmd}}
    {{All files}    *         }
}
if {[catch {set box_vmd [tk_getSaveFile -title "Save VMD Box file" -filetypes $types]}]} {
    #svbox_vis $box_vmd
}
if {$box_vmd == ""} {
    set box_vmd "box vmd file"
} else {
    svbox_vis $box_vmd
}} \
		-cursor pencil -foreground black -highlightcolor black \
		-text {Save VMD box} 
    vTcl:DefineAlias "$site_3_0.but56" "Button17" vTcl:WidgetProc "Toplevel1" 1
    label $site_3_0.lab57 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -relief sunken -textvariable cpptraj_in 
    vTcl:DefineAlias "$site_3_0.lab57" "Label9" vTcl:WidgetProc "Toplevel1" 1
    label $site_3_0.lab59 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -relief sunken -textvariable box_vmd 
    vTcl:DefineAlias "$site_3_0.lab59" "Label10" vTcl:WidgetProc "Toplevel1" 1
    place $site_3_0.but48 \
		-in $site_3_0 -x 15 -y 20 -width 135 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_3_0.but56 \
		-in $site_3_0 -x 39 -y 52 -width 111 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_3_0.lab57 \
		-in $site_3_0 -x 160 -y 24 -width 383 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_3_0.lab59 \
		-in $site_3_0 -x 160 -y 56 -width 383 -height 18 -anchor nw \
		-bordermode ignore 
    labelframe $top.lab44 \
		-borderwidth 5 -foreground black -text {Setup Parameters} -height 155 \
		-highlightcolor black -width 205 
    vTcl:DefineAlias "$top.lab44" "Labelframe9" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.lab44
    labelframe $site_3_0.lab45 \
		-foreground black -text {Grid Size} -height 45 -highlightcolor black \
		-width 75 
    vTcl:DefineAlias "$site_3_0.lab45" "Labelframe10" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.lab45
    entry $site_4_0.ent47 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -justify center -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable vxl_sz 
    vTcl:DefineAlias "$site_4_0.ent47" "Entry1" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_0.ent47 \
		-in $site_4_0 -x 6 -y 15 -width 61 -height 25 -anchor nw \
		-bordermode ignore 
    labelframe $site_3_0.lab50 \
		-foreground black -text {AMBER Files cpptraj.in} -height 55 \
		-highlightcolor black -width 170 
    vTcl:DefineAlias "$site_3_0.lab50" "Labelframe12" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.lab50
    radiobutton $site_4_0.rad54 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Full Path Names} -variable fopt 
    vTcl:DefineAlias "$site_4_0.rad54" "Radiobutton1" vTcl:WidgetProc "Toplevel1" 1
    radiobutton $site_4_0.rad55 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Names Only} -value 1 -variable fopt 
    vTcl:DefineAlias "$site_4_0.rad55" "Radiobutton2" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_0.rad54 \
		-in $site_4_0 -x 5 -y 15 -width 124 -height 20 -anchor nw \
		-bordermode ignore 
    place $site_4_0.rad55 \
		-in $site_4_0 -x 5 -y 33 -width 103 -height 20 -anchor nw \
		-bordermode ignore 
    button $site_3_0.but45 \
		-activebackground {#f9f9f9} -activeforeground black -borderwidth 3 \
		-command {up_vxl_all
set x_face [lindex $vxls 0]
set y_face [lindex $vxls 1]
set z_face [lindex $vxls 2]} \
		-cursor tcross -foreground black -highlightcolor black \
		-text {Apply New Values} 
    vTcl:DefineAlias "$site_3_0.but45" "Button18" vTcl:WidgetProc "Toplevel1" 1
    labelframe $site_3_0.lab43 \
		-foreground black -text {Cntr step size} -height 40 \
		-highlightcolor black -width 90 
    vTcl:DefineAlias "$site_3_0.lab43" "Labelframe11" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.lab43
    entry $site_4_0.ent44 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -justify center -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable sz_dx 
    vTcl:DefineAlias "$site_4_0.ent44" "Entry2" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_0.ent44 \
		-in $site_4_0 -x 15 -y 15 -width 61 -height 25 -anchor nw \
		-bordermode ignore 
    place $site_3_0.lab45 \
		-in $site_3_0 -x 13 -y 15 -width 75 -height 45 -anchor nw \
		-bordermode ignore 
    place $site_3_0.lab50 \
		-in $site_3_0 -x 18 -y 91 -width 170 -height 55 -anchor nw \
		-bordermode ignore 
    place $site_3_0.but45 \
		-in $site_3_0 -x 36 -y 63 -width 130 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_3_0.lab43 \
		-in $site_3_0 -x 100 -y 16 -width 90 -height 45 -anchor nw \
		-bordermode ignore 
    ###################
    # SETTING GEOMETRY
    ###################
    place $top.lab47 \
		-in $top -x 20 -y 9 -width 340 -height 155 -anchor nw \
		-bordermode ignore 
    place $top.lab48 \
		-in $top -x 20 -y 173 -width 555 -height 120 -anchor nw \
		-bordermode ignore 
    place $top.lab49 \
		-in $top -x 20 -y 305 -width 555 -height 100 -anchor nw \
		-bordermode ignore 
    place $top.lab45 \
		-in $top -x 20 -y 415 -width 555 -height 90 -anchor nw \
		-bordermode ignore 
    place $top.lab44 \
		-in $top -x 370 -y 9 -width 205 -height 155 -anchor nw \
		-bordermode ignore 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {
                    draw delete all
                    mol delete $b_molid
                }
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}

Window show .
Window show .top44

main $argc $argv
