def print_hosts(host)
  puts host
  print 'name = ', host['name'], ', host = ', host['host'], "\n"
end

def get_host_interface(zbx, config)
  result = zbx.query(
    method: 'hostinterface.get',
    params: {
      output: 'extend',
      hostids: zbx.hosts.get_id(host: config['certificates']['host']),
      main: '1'
    }
  )

  result[0]['interfaceid']
end
