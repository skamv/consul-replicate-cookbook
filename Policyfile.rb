name 'consul-replicate'
default_source :community
cookbook 'consul-replicate', path: '.'
run_list 'consul-replicate::default'
named_run_list :freebsd, 'freebsd::default', 'consul::default', 'consul-replicate::default'
named_run_list :redhat, 'redhat::default', 'consul::default', 'consul-replicate::default'
named_run_list :ubuntu, 'ubuntu::default', 'consul::default', 'consul-replicate::default'
override['consul']['config']['bootstrap'] = true
override['consul']['config']['server'] = true
