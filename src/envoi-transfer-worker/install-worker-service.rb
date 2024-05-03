#!/usr/bin/env ruby
# frozen_string_literal: true

# ACTIVITY_ARN
puts 'Enter the ARN of the activity to run: '
activity_arn = gets.chomp

# TRANSFER_WORKER_NAME
puts 'Enter the name of the transfer worker: '
worker_name = gets.chomp

service_def = <<~SERVICE_DEF
  [Unit]
  Description=Envoi Transfer Worker

  [Service]
  Type=simple
  Restart=always
  ExecStart=#{`which ruby`.strip} exe/envoi-transfer-worker
  WorkingDirectory=#{File.absolute_path File.dirname(__FILE__)}
  Environment=ACTIVITY_ARN=#{activity_arn}
  Environment=TRANSFER_WORKER_NAME=#{worker_name}
  [Install]
  WantedBy=multi-user.target

SERVICE_DEF

File.write('/etc/systemd/system/envoi-transfer-worker.service', service_def)
`systemctl daemon-reload`
`systemctl enable envoi-transfer-worker`
`service envoi-transfer-worker restart`
sleep 2
`service envoi-transfer-worker status`
