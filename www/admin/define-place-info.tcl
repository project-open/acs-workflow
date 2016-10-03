# packages/acs-workflow/www/admin/define-place-info.tcl
# @author Lars Pind (lars@pinds.com)
# @creation-date November 21, 2000
# @cvs-id $Id$
#
# Expects:
#    workflow:onerow (magic thing)
#    place_key
#    mode
#    format
#    return_url
#    modifiable_p (optional)
# Returns:
#    workflow_key
#    place:onerow(place_key, place_name, edit_url, delete_url, arc_add_url, arc_delete_url)
#    producing_transitions:multirow(url, transition_key, transition_name, guard_pretty, 
#                                   guard_edit_url, guard_delete_url, guard_add_url, arc_delete_url)
#    consuming_transitions:multirow(url, transition_key, transition_name, arc_delete_url)

set workflow_key $workflow(workflow_key)

if { ![info exists modifiable_p] } {
    set modifiable_p 1
}

# place:onerow(place_key, place_name, edit_url, delete_url)

set place(place_key) $place_key
set place(place_name) $workflow(place,$place_key,place_name)
set place(edit_url) "place-edit?[export_vars -url { workflow_key place_key return_url}]"
if { $modifiable_p } {
    set place(delete_url) "place-delete?[export_vars -url { workflow_key place_key return_url}]"
    set place(arc_add_url) "define?[export_ns_set_vars {url} {mode}]&mode=arcadd"
    set place(arc_delete_url) "define?[export_ns_set_vars {url} {mode}]&mode=arcdelete"
} else {
    set place(delete_url) ""
    set place(arc_add_url) ""
    set place(arc_delete_url) ""
}

# producing_transitions:multirow(transition_key, transition_name, url, arc_delete_url
#                                guard_pretty, guard_edit_url, guard_delete_url, guard_add_url)

template::multirow create producing_transitions transition_key transition_name url arc_delete_url \
	guard_pretty guard_edit_url guard_delete_url guard_add_url

set direction "out"
foreach loop_transition_key $workflow(arcs,place,$place_key,out) {
    set url [export_vars -base "define" { workflow_key {transition_key $loop_transition_key} format}]
    if { $modifiable_p } {
	set arc_delete_url [export_vars -base "arc-delete" { workflow_key {transition_key $loop_transition_key} place_key direction return_url}]
    } else {
	set arc_delete_url ""
    }
    set guard_pretty [ad_decode $workflow(arc,$loop_transition_key,$place_key,out,guard_description) \
	    "" $workflow(arc,$loop_transition_key,$place_key,out,guard_callback) \
	    $workflow(arc,$loop_transition_key,$place_key,out,guard_description)]
    set guard_edit_url [export_vars -base "arc-edit" { workflow_key {transition_key $loop_transition_key} place_key direction return_url}]
    set guard_delete_url [export_vars -base "arc-edit-2" { workflow_key {transition_key $loop_transition_key} place_key direction return_url {guard_callback ""} {guard_custom_arg ""} {guard_description ""}}]
    set guard_add_url [export_vars -base "arc-edit" { workflow_key {transition_key $loop_transition_key} place_key direction return_url}]
    
    template::multirow append producing_transitions $loop_transition_key \
	    $workflow(transition,$loop_transition_key,transition_name) $url $arc_delete_url \
	    $guard_pretty $guard_edit_url $guard_delete_url $guard_add_url
}

# consuming_transitions:multirow(url, transition_key, transition_name, arc_delete_url)

template::multirow create consuming_transitions transition_key transition_name url arc_delete_url

set direction "in"
foreach loop_transition_key $workflow(arcs,place,$place_key,in) {
    set url [export_vars -base "define" { workflow_key {transition_key $loop_transition_key} format}]
    if { $modifiable_p } {
	set arc_delete_url [export_vars -base "arc-delete" {workflow_key {transition_key $loop_transition_key} place_key direction return_url}]
    } else {
	set arc_delete_url ""
    }
    template::multirow append consuming_transitions $loop_transition_key \
	    $workflow(transition,$loop_transition_key,transition_name) $url $arc_delete_url
}

ad_return_template



