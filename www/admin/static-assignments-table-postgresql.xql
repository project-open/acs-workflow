<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="roles">      
      <querytext>

    select r.role_key, 
           r.role_name,
           p.party_id,
           acs_object__name(p.party_id) as party_name,
           p.email as party_email,
           '' as user_select_widget,
           '' as add_export_vars,
           '' as remove_url
    from   wf_roles r 
	   left outer join
           wf_context_assignments ca 
	   on (ca.context_key = :context_key and ca.role_key = r.role_key)
	   left outer join
           parties p
	   using (party_id)
    where  r.workflow_key = :workflow_key
    order by r.sort_order, r.role_key

      </querytext>
</fullquery>

 
<fullquery name="parties">      
      <querytext>
      
            select p.party_id as sel_party_id,
                   acs_object__name(p.party_id) as sel_name,
                   p.email as sel_email
            from   parties p
            where  p.party_id not in 
                  (select ca.party_id 
                   from   wf_context_assignments ca
                   where  ca.workflow_key = :workflow_key 
                   and    ca.context_key = :context_key 
                   and    ca.role_key = :role_key)
	
      </querytext>
</fullquery>

 
</queryset>
