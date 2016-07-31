name 'consul-replicate'
default_source :community
cookbook 'consul-replicate', path: '.'
run_list 'sudo::default', 'consul::default', 'consul-replicate::default'
named_run_list :centos, 'yum::default', 'yum-epel::default', run_list
named_run_list :debian, 'apt::default', run_list
named_run_list :freebsd, 'freebsd::default', run_list
override['consul']['config']['bootstrap'] = true
override['consul']['config']['server'] = true
