ad_page_contract {
    Add a comment to the journal for a case.
    
    @cvs-id $Id$
} {
    case_id:integer
    return_url:optional
} -properties {
    context
    case:onerow
    export_vars
}

db_1row case {
    select case_id,
           acs_object.name(object_id) as object_name,
           state
    from   wf_cases
    where  case_id = :case_id
} -column_array case

set context [list [list "./" "Work List"] [list "case?[export_vars -url { case_id}]" "Case $case(object_name)"] "Comment"]

set export_vars [export_vars -form {case_id return_url}]

ad_return_template


