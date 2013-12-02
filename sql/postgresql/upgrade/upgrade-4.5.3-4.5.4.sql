-- upgrade-4.5.3-4.5.4.sql

-- Fix: Failed update 11/2013 - coming from V3.2
-- we can't assume that im_lang_add_message already exists

create or replace function im_lang_add_message(text, text, text, text)
returns integer as $body$
DECLARE
        p_locale        alias for $1;
        p_package_key        alias for $2;
        p_message_key        alias for $3;
        p_message        alias for $4;

        v_count                integer;
BEGIN
        -- Do not insert strings for packages that do not exist
        --
        select        count(*) into v_count from apm_packages
        where        package_key = p_package_key;
        IF 0 = v_count THEN return 0; END IF;

        -- Make sure there is an entry in lang_message_keys
        --
        select        count(*) into v_count from lang_message_keys
        where        package_key = p_package_key and message_key = p_message_key;
        IF 0 = v_count THEN
                insert into lang_message_keys (
                        message_key, package_key
                ) values (
                        p_message_key, p_package_key
                );
        END IF;

        -- Create the translation entry
        --
        select        count(*) into v_count from lang_messages
        where        locale = p_locale and package_key = p_package_key and message_key = p_message_key;
        IF 0 = v_count THEN
                insert into lang_messages (
                        message_key, package_key, locale, message, sync_time, upgrade_status
                ) values (
                        p_message_key, p_package_key, p_locale, p_message, now(), 'added'
                );
        END IF;

        return 1;
END;$body$ language 'plpgsql';


-- Localization

SELECT im_lang_add_message('en_US','acs-workflow','Task_Has_Not_Been_Started_Yet','This task has not been started yet.');
SELECT im_lang_add_message('de_DE','acs-workflow','Task_Has_Not_Been_Started_Yet','Workflow Aufgabe noch nicht gestarted');

SELECT im_lang_add_message('en_US','acs-workflow','You_Are_The_Only_Person','You are the only person assigned to this task.');
SELECT im_lang_add_message('de_DE','acs-workflow','You_Are_The_Only_Person','Sie sind alleiniger Aufgabentr&auml;ger ');

SELECT im_lang_add_message('en_US','acs-workflow','Other_Assignees','Other assignees:');
SELECT im_lang_add_message('de_DE','acs-workflow','Other_Assignees','Weitere Aufgabentr@auml;ger:');

SELECT im_lang_add_message('en_US','acs-workflow','Assign_Yourself','assign yourself');
SELECT im_lang_add_message('de_DE','acs-workflow','Assign_Yourself','Aufgabe selbst ausf&uuml;hren');

SELECT im_lang_add_message('en_US','acs-workflow','Reassign','reassign');
SELECT im_lang_add_message('de_DE','acs-workflow','Reassign','Aufgabe anderer Person zuordnen');


