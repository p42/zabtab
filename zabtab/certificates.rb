def update_zabbix_certificate(zbx, config, name, port, action)
  status = case action
           when 'enable' then '0'
           when 'enabled' then '0'
           when 'disable' then '1'
           when 'disabled' then '1'
           when 'delete' then 'DELETE'
           when 'deleted' then 'DELETE'
           else '1'
           end

  # print "Host ID = #{status}\n"
  if status == 'DELETE'
    puts "Deleting Certificate Monitoring: #{name}"
  else
    puts "Creating or Updating Certificate Monitoring: #{name}"

    ### Make so pass in hostid instead of config for flexibility
    interfaceid = get_host_interface(zbx, config)
    monitor_host = config['certificates']['host']

    # Item - Certificate Exiration date
    zbx.items.create_or_update(
      name: "Certificate Expiration Date - #{name}",
      description: "The date #{name} expires",
      key_: "custom.cert.expireDate[#{name},#{port}]",
      type: 0,
      value_type: 4,
      delay: 86_400,
      history: 365,
      trends: 0,
      status: status,
      hostid: zbx.hosts.get_id(host: config['certificates']['host']),
      interfaceid: interfaceid,
      applications: [zbx.applications.get_id(name: config['certificates']['application'])]
    )

    # Item - Certificate Expiration Seconds
    zbx.items.create_or_update(
      name: "Certificate Expiration Seconds - #{name}",
      description: "Seconds until #{name} expires",
      key_: "custom.cert.expireSeconds[#{name},#{port}]",
      type: 0,
      value_type: 0,
      delay: 3600,
      history: 14,
      trends: 365,
      units: 's',
      formula: 1,
      status: status,
      hostid: zbx.hosts.get_id(host: config['certificates']['host']),
      interfaceid: interfaceid,
      applications: [zbx.applications.get_id(name: config['certificates']['application'])]
    )

    # Triger - Certificate Near expiring
    zbx.triggers.create_or_update(
      description: "Certificate for #{name} near expiring",
      expression: "{#{monitor_host}:custom.cert.expireSeconds[#{name},#{port}].last(#1)}<1209600",
      comments: "Certificate for #{name} will expire in less then 2 weeks",
      priority: 2,
      status: status,
      hostid: zbx.hosts.get_id(host: config['certificates']['host']),
      type: 0
    )

    # Triger - Certificate expiring
    zbx.triggers.create_or_update(
      description: "Certificate for #{name} expiring",
      expression: "{#{monitor_host}:custom.cert.expireSeconds[#{name},#{port}].last(#1)}<172800",
      comments: "Certificate for #{name} will expire in less then 2 days",
      priority: 4,
      status: status,
      hostid: zbx.hosts.get_id(host: config['certificates']['host']),
      type: 0
    )

    # Graph
    gitems = {
      itemid: zbx.items.get_id(name: "Certificate Expiration Seconds - #{name}"),
      calc_fnc: 2,
      type: 2,
      drawtype: 5,
      color: 777_777
    }
    zbx.graphs.create_or_update(
      gitems: [gitems],
      show_triggers: '1',
      name: "Certificate Valid Time - #{name}",
      graphtype: 0,
      width: '300',
      height: '200',
      ymin_type: 1,
      yaxismin: 0.0000,
      ymax_type: 1,
      yaxismax: 7_776_000.0000,
      show_work_period: 0,
      show_legend: 1,
      hostid: zbx.templates.get_id(host: 'template')
    )

    # Screen
    # zbx.screens.create_or_update(
    #   screen_name: "Certificate - #{name}",
    #   hsize: 1,
    #   vsize: 3
    # )
  end
end

def parse_certificates(certificates, zbx, config)
  certificates.each do |cert|
    if cert[1].nil?
      name = cert[0]
      port = '443'
      status = 'enabled'
    else
      cert[1]['name'] = cert[0] unless cert[1].key?('name')
      cert[1]['port'] = '443' unless cert[1].key?('port')
      cert[1]['status'] = 'enabled' unless cert[1].key?('status')

      name = cert[1]['name']
      port = cert[1]['port']
      status = cert[1]['status']
    end

    update_zabbix_certificate(zbx, config, name, port, status)
  end
end
