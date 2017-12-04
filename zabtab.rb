#!/usr/bin/env ruby

# Make sure PWD where the script lives
Dir.chdir(File.dirname(__FILE__)) unless Dir.pwd == File.dirname(__FILE__)

require 'zabbixapi'
require 'yaml'

require_relative 'zabtab/certificates'
require_relative 'zabtab/hosts'

config = YAML.safe_load(File.read('config/config.yaml'))

##################
# Zabbix connect #
##################
zbx = ZabbixApi.connect(
  url: config['zabbix']['url'],
  user: config['zabbix']['user'],
  password: config['zabbix']['password']
)

################
# Certificates #
################
certificates = YAML.safe_load(File.read('config/certificates.yaml'))
parse_certificates(certificates, zbx, config)
