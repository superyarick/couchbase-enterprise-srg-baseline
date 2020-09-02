# encoding: UTF-8

control "V-32391" do
  title "Couchbase must use system clocks to generate time stamps for use in
audit records and application data."
  desc  "Internal system clocks are typically a feature of server hardware and
are maintained and used by the operating system. They are typically
synchronized with an authoritative time server at regular intervals.

    Without an internal system clock used as the reference for the time stored
on each event to provide a trusted common reference for the time, forensic
analysis would be impeded. Determining the correct time a particular event
occurred on a system is critical when conducting forensic analysis and
investigating system events.

    Time stamps generated by the internal system clock and used by Couchbase
shall include both date and time. The time may be expressed in Coordinated
Universal Time (UTC), a modern continuation of Greenwich Mean Time (GMT), or
local time with an offset from UTC.

    If time sources other than the system time are used for audit records, the
timeline of events can get skewed. This makes forensic analysis of the logs
much less reliable.
  "
  desc  "check", "
    Once enabled on the cluster, Couchbase auditing provides the following
fields by default:
      - \"id\" - ID of Event
      - \"name\" - Name of Event (can indicate success/failure)
      - \"description\" - Event Description (can indicate success/failure)
      - \"filtering_permitted\" - Whether the event is filterable
      - \"mandatory_fields\" - Includes \"timestamp\" (UTC time and ISO 8601
format) and \"user\" fields
    Note that different event-types generate different field-subsets. Below are
some of the fields provided:
      - \"node_id\" - ID of Node
      - \"session_id\" - ID of current Session
      - \"ip\" - Remote IP address
      - \"port\" - Remote port
      - \"bucket_name\" - Name of Bucket
    Couchbase Server 6.5.0 and earlier -
      As root or a sudo user, verify that the \"audit.log\" file exists in the
var/lib/couchbase/logs directory of the Couchbase application home (example:
/opt/couchbase/var/lib/couchbase/logs) and is populated with data captured.
      Review the audit.log file. If it does not exist or not populated with
data captured, this is a finding.
    Couchbase Server Version 6.5.1 and later -
      As the Full Admin, verify that auditing is enabled by executing the
following command:
       $ couchbase-cli setting-audit -c <host>:<port> -u <Full Admin> -p
<Password> --get-settings
      Review the output of the command. If \"Audit enabled\" is not set to
\"true\", this is finding.
  "
  desc  "fix", "
    Enable session auditing on the Couchbase cluster to enable the use of
system clocks to generate time stamps for audit records.
    Couchbase Server 6.5.0 and earlier -
      As the Full Admin, execute the following command to enable auditing:
       $ couchbase-cli setting-audit --cluster <host>:<port> --u <Full Admin>
--password <Password> --audit-enabled 1 --audit-log-rotate-interval 604800
--audit-log-path /opt/couchbase/var/lib/couchbase/logs
    Couchbase Server Version 6.5.1 and later -
      As the Full Admin, execute the following command to enable auditing:
       $ couchbase-cli setting-audit --cluster <host>:<port> --u <Full Admin>
--password <Password> --set  --audit-enabled 1 --audit-log-rotate-interval
604800 --audit-log-path /opt/couchbase/var/lib/couchbase/logs
  "
  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000116-DB-000057"
  tag "gid": "V-32391"
  tag "rid": "SV-42728r3_rule"
  tag "stig_id": "SRG-APP-000116-DB-000057"
  tag "fix_id": "F-36306r2_fix"
  tag "cci": ["CCI-000159"]
  tag "nist": ["AU-8 a", "Rev_4"]

  couchbase_version = command('couchbase-server -v').stdout

  if couchbase_version.include?("6.5.1") || couchbase_version.include?("6.6.0")
    describe command("couchbase-cli setting-audit -u #{input('cb_full_admin')} -p #{input('cb_full_admin_password')} --cluster #{input('cb_cluster_host')}:#{input('cb_cluster_port')} --get-settings | grep 'Audit enabled:'") do
      its('stdout') { should include "True" }
    end 
  else
    describe json( command: "curl -v -X GET -u #{input('cb_full_admin')}:#{input('cb_full_admin_password')} http://#{input('cb_cluster_host')}:#{input('cb_cluster_port')}/settings/audit") do
      its('auditdEnabled') { should eq true }
    end 
  end
end
