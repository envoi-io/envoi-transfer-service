#!/usr/bin/env ruby
# frozen_string_literal: true

environment_file_path = '/etc/envoi/envoi-transfer-worker.env'
File.write(environment_file_path, <<~ENV_VARS
  ACTIVITY_ARN=
ENV_VARS
)


service_def = <<~SERVICE_DEF
  [Unit]
  Description=Envoi Transfer Worker

  [Service]
  Type=simple
  Restart=always
  ExecStart=#{`which ruby`.strip} exe/envoi-transfer-worker
  WorkingDirectory=#{File.absolute_path "#{File.dirname(__FILE__)}/.."}
  EnvironmentFile=#{environment_file_path}
  [Install]
  WantedBy=multi-user.target

SERVICE_DEF

File.write('/etc/systemd/system/envoi-transfer-worker.service', service_def)
`systemctl daemon-reload`
`systemctl enable envoi-transfer-worker`
`service envoi-transfer-worker restart`
sleep 2
`service envoi-transfer-worker status`
