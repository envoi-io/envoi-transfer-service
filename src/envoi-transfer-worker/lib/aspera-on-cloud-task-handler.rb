require 'net/https'
require 'open3'
require 'shellwords'

require 'basic-task-handler'
# require('s3-helper')

DEFAULT_TEMP_DIR_PATH = ENV['TEMP_DIR'] || '/tmp/' unless defined? DEFAULT_TEMP_DIR_PATH

class AsperaOnCloudTaskHandler < BasicTaskHandler

  def initialize(args = {}, _options = {})
    super(args)

    @temp_dir = args[:temp_dir] || DEFAULT_TEMP_DIR_PATH
  end

  def process_source
    args = @task_input

    source = args[:source]
    source_url = nil
    source_uri = nil
    source_path = ''
    credentials = nil

    case source
    when Hash
      source_path = source[:path]
      source_url = source[:url]
      credentials = source[:credentials]
    when String
      if source.match(%r{\w*://.*})
        source_uri = URI(source)
        case source_uri.scheme
        when 'http', 'https'
          logger.debug 'HTTP URI'
        when 's3'
          logger.debug 'S3 URI'
          #   Download to source tmp
          # source_path = File.join(tmp_dir_path, source_file_name)
        else
          logger.debug "Unknown URI Scheme: #{source_uri.scheme}. Unsupported Source."
        end
      else
        source_path = source
      end
    else
      # Unknown Source Format
    end

    if source_uri || source_url
      response = S3Downloader.new(uri: source_uri, url: source_url, credentials:).download
      source_path = response[:destination] || ''
    end

    source_path
  end
  
  def run
    args = @task_input

    tmp_dir = @temp_dir
    source_path = process_source

    aoc_url = args.fetch(:url, '')
    aoc_private_key = args.fetch(:private_key, '')
    aoc_username = args.fetch(:username, '')
    aoc_workspace = args.fetch(:workspace, '')
    aoc_to_folder = args.fetch(:to_folder, '')
    aoc_link = args.fetch(:link, '')
    aoc_password = args.fetch(:password, '')

    executable_path = `which ascli`
    executable_path.strip!

    raise Error('ascli executable not found.') if executable_path.empty?

    cmd_ary = %W[
      #{executable_path} aoc files upload
      #{source_path.empty? ? nil : %("#{source_path}")}
      #{aoc_to_folder.empty? ? nil : %( --to-folder="#{aoc_to_folder}")}
      #{aoc_username.empty? ? nil : %( --username="#{aoc_username}")}
      #{aoc_workspace.empty? ? nil : %( --workspace="#{aoc_workspace}")}
      #{aoc_url.empty? ? nil : %( --url="#{aoc_url}")}
      #{aoc_private_key.empty? ? nil : %( --private-key="#{aoc_private_key}")}
      #{aoc_link.empty? || !aoc_url.empty? ? nil : %( --link="#{aoc_link}")}
      #{aoc_password.empty? ? nil : %( --password="#{aoc_password}")}
    ].delete_if(&:empty?)

    # cmd = cmd_ary.shelljoin
    cmd = cmd_ary.join(' ')
    cmd_sanitized = cmd.gsub(/(?:--password="|--private-key=").*?"/, '\1REDACTED"')
    logger.debug "CMD: #{cmd_sanitized}"

    stdout, stderr, status = Open3.capture3(cmd)

    if status.success?
      puts status
      puts stderr
      puts stdout
    else
      logger.error("Error executing command: #{stdout} #{stderr}, #{status}")
    end

    File.delete(source_path) if (source_path || '').start_with?(tmp_dir)
  end

end
