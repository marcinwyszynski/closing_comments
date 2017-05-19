require 'json'
require 'net/http'
require 'singleton'

require 'colorize'

class EnsureVersion
  include Singleton

  def call
    if compare
      puts "#{'[OK]'.green} Local version (#{local_version}) higher than " \
           "remote (#{remote_version})."
      Kernel.exit(0)
    end
    puts "#{'[FAIL]'.red} Local version (#{local_version}) not higher than " \
         "remote (#{remote_version}), please bump."
    Kernel.exit(1)
  end

  private

  def compare
    local_version > remote_version
  end

  def local_version
    Gem.loaded_specs[name].version
  end

  def remote_version
    @remote_version ||= begin
      version = JSON.parse(rubygems_response.body).fetch('version')
      Gem::Version.new(version == 'unknown' ? 0 : version)
    end
  end

  # This method reeks of :reek:FeatureEnvy (url).
  def rubygems_response
    url = URI.parse("https://rubygems.org/api/v1/versions/#{name}/latest.json")
    req = Net::HTTP::Get.new(url.to_s)
    Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      http.request(req)
    end
  end

  def name
    'closing_comments'
  end
end # class EnsureVersion

EnsureVersion.instance.call if __FILE__ == $PROGRAM_NAME
