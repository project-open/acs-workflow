ad_page_contract { 
    Delete a workflow definition from the system.

    @author Lars Pind (lars@pinds.com)
    @creation-date 28 September 2000
    @cvs-id $Id$
} {
    workflow_key:notnull
} -validate {
    workflow_exists -requires {workflow_key} {
	if ![db_string workflow_exists "
	select 1 from wf_workflows 
	where workflow_key = :workflow_key"] {
	    ad_complain "You seem to have specified a nonexistent workflow."
	}
    }
}



set cases_table [db_string cases_table { select table_name from acs_object_types where object_type = :workflow_key }]

# If the table does not exist, it's probably because it was already deleted in a faulty attempt to delete the process.
# At least, let us not prevent the guy from trying to delete the process again.

if { [db_table_exists $cases_table] } {
   db_exec_plsql delete_cases {
	begin 
	    workflow.delete_cases(workflow_key => :workflow_key);
	end;
    }
    
    db_dml drop_cases_table "
	drop table $cases_table
    "   
}

db_exec_plsql delete_workflow {
    begin
        workflow.drop_workflow(workflow_key => :workflow_key);
    end;
}

ad_returnredirect ""
