ad_page_contract {
    Edit arc.
} {
    workflow_key
    transition_key
    place_key
    direction
    return_url:optional
} -properties {
    context
    export_vars
    guard_description
    guard_options:multirow
    guard_custom_arg
}

db_1row arc_info {
    select a.guard_callback,
           a.guard_custom_arg,
           a.guard_description
    from   wf_arcs a
    where  a.workflow_key = :workflow_key
    and    a.transition_key = :transition_key
    and    a.place_key = :place_key
    and    a.direction = :direction
}

set guard_description [ad_quotehtml $guard_description]
set guard_custom_arg [ad_quotehtml $guard_custom_arg]

# Query Oracle's data dictionary to find all the functions matching the signature that guards
# must match
# Ugh! This is ugly. We really need that callback repository!

set possible_guards [util_memoize [list db_list possible_guards ""] 3600]

template::multirow create guard_options value selected name
template::multirow append guard_options "" [ad_decode $guard_callback "" "SELECTED" ""] "--no guard-- [ad_decode $guard_callback "" "(current)" ""]"
template::multirow append guard_options "#" [ad_decode $guard_callback "#" "SELECTED" ""] "No other guards were satsified [ad_decode $guard_callback "#" "(current)" ""]"

if { ![empty_string_p $guard_callback] && ![string equal $guard_callback "#"] && \
	[lsearch -exact $possible_guards $guard_callback] == -1 } {
    template::multirow append guard_options [ad_quotehtml $guard_callback] "SELECTED" "[ad_quotehtml $guard_callback] (current&#151;appears to be invalid)"
}

foreach possible_guard $possible_guards {
    set selected_p [string equal $possible_guard $guard_callback]
    template::multirow append guard_options [ad_quotehtml $possible_guard] [ad_decode $selected_p 1 "SELECTED" ""] [ad_quotehtml $possible_guard] [ad_decode $selected_p 1 "(current)" ""]
}
 

set context [list [list "define?[export_url_vars workflow_key]" "Process Builder"] "Edit arc"]
set export_vars [export_form_vars workflow_key transition_key place_key direction return_url]


ad_return_template
