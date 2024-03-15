# This template expects the following properties:
#   task:onerow
#   task_attributes_to_set:multirow
#   task_assigned_users:multirow
#   task_roles_to_assign:multirow

set user_id [ad_conn user_id]


# ------------------------------------------------------------
# Check for manually entered comments and display them prominently
# ------------------------------------------------------------

set task_comments_html ""
set task_comments_sql "
	select
		to_char(o.creation_date, 'YYYY-MM-DD HH24:MI') as creation_date,
		im_name_from_user_id(o.creation_user) as user_name,
		je.action_pretty,
		je.msg as comment
	from	journal_entries je,
		acs_objects o
	where	je.journal_id = o.object_id and
		je.object_id in (
				select	case_id
				from	wf_tasks
				where	task_id = $task(task_id)
		) and
		je.action ~ 'task \[0-9\]+ finish'
"

set task_comments_html [im_ad_hoc_query -format html -border 0 $task_comments_sql]
set task_comments_cnt [db_string comment_count "select count(*) from ($task_comments_sql) t"]

ad_return_template
