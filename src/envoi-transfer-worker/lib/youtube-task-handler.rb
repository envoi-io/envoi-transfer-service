require 'net/https'
require 'open3'
require 'pty'
require 'shellwords'

DEFAULT_TEMP_DIR_PATH = ENV['TEMP_DIR'] || '/tmp/' unless defined? DEFAULT_TEMP_DIR_PATH


YOUTUBE_VIDEO_INSERT_EXE_PATH = ENV['YOUTUBE_VIDEO_INSERT_EXE_PATH'] || File.expand_path(
  File.join(File.dirname(__FILE__), '../../youtube-js/youtube-video-insert.sh')
)

# puts "YouTube Video Insert Executable Path: #{YOUTUBE_VIDEO_INSERT_EXE_PATH}"

require('basic-task-handler')
class YouTubeTaskHandler < BasicTaskHandler

  def initialize(args = {}, _options = {})

    @temp_dir = args[:temp_dir] || DEFAULT_TEMP_DIR_PATH
    @youtube_video_insert_exe_path = YOUTUBE_VIDEO_INSERT_EXE_PATH
    super(args)
  end

  def run
    executable_file_path = @youtube_video_insert_exe_path
    logger.debug { "Executable File Path: ''#{executable_file_path}' Exists? #{File.exist?(executable_file_path)}" }

    input_file_path = File.join(@temp_dir, 'youtube-task-in.json')
    output_file_path = File.join(@temp_dir, 'youtube-task-out.json')

    File.write(input_file_path, JSON.pretty_generate(@task_input))

    cmd_ary = %W[#{executable_file_path} -i #{input_file_path} -o #{output_file_path}]
    cmd = cmd_ary.shelljoin
    logger.debug { "Executing command '#{cmd}'" }
    exec_cmd(cmd)

    File.read(output_file_path)
  end

  def exec_cmd(cmd)
    require 'pty'
    begin
      PTY.spawn( cmd ) do |stdout, _stdin, pid|
        begin
          stdout.each { |line| print line }
        rescue Errno::EIO
          puts pid
        end
      end
    rescue PTY::ChildExited
      puts 'The child process exited!'
    end
  end

  def exec_cmd_open3(cmd)
    stdout, stderr, status = Open3.capture3(cmd)
    puts stdout
    puts stderr
    puts status
  end

end

def run_executable
  executable_file_path = File.expand_path(File.join(File.dirname(__FILE__), 'youtube-js/youtube-video-insert.sh'))
  puts "#{executable_file_path} #{File.exist?(executable_file_path)}"
  cmd_ary = %W[#{executable_file_path}]
  cmd = cmd_ary.shelljoin
  puts "cmd #{cmd}"
  stdout, stderr, status = Open3.capture3(cmd)
  puts stdout
  puts stderr
  puts status

  # payload = {}
  # YouTubeTaskHandler.new(payload).run

end

if __FILE__ == $PROGRAM_NAME
  run_executable
end
