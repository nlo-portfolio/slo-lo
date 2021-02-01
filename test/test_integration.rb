require 'open3'
require 'yaml'
require 'net/http'
require 'test/unit'


# Integration tests depend on curl and wget.
class SloLoIntegrationTest < Test::Unit::TestCase

  def setup
    @timeout = 15
    @config_filename = File.expand_path File.dirname(__FILE__) + '/test_config.yml'
    @config = YAML.load(File.read(@config_filename))
    @sudo = ''
    
    if not ENV['DOCKER']
      @sudo = 'sudo'
    end
    
    # Stop all instances of running slo_lo.
    `pkill --full "../slo_lo.rb --test"`
    
    apache_status = `#{@sudo} service apache2 status`
    # Check if Apache server is installed.
    if apache_status.include? 'Failed to start'
      puts 'Apache server not installed.'
      puts 'Integration tests require functioning Apache server.'
      exit 1
    end
    
    # Check if Apache server is already running.
    @apache_running = false
    unless apache_status.include? 'active'
      `#{@sudo} service apache2 start`
      puts 'Apache HTTP server started.'
    else
      @apache_running = true
      puts 'Apache HTTP server already running.'
    end
  end
  
  def teardown
    # Stop Apache server if not running before tests.
    unless @apache_running
      `#{@sudo} service apache2 stop`
      puts 'Apache HTTP server stopped.'
    end
  end
  
  def test_integration
    # Test Apache server is running and taking requests successfully.
    _, stderr, _ = Open3.capture3("curl --silent --show-error --retry 0 --max-time #{@timeout} 127.0.0.1")
    assert_no_match /Operation timed out/, stderr
    _, stderr, _ = Open3.capture3("wget --tries=1 --no-verbose --timeout=#{@timeout} --delete-after 127.0.0.1")
    assert_no_match /Connection timed out/, stderr
    
    
    # Start the Slow Loris attack.
    t = Thread.new { puts `ruby #{File.expand_path(File.dirname(__FILE__))}/../slo_lo.rb --target 127.0.0.1 --port 80` }
    sleep(3)
    
    # Test that Apache server can no longer serve requests while the Slow Loris attack is active.
    _, stderr, _ = Open3.capture3("curl --silent --show-error --retry 0 --max-time #{@timeout} 127.0.0.1")
    assert_match /Operation timed out/, stderr
    _, stderr, _ = Open3.capture3("wget --tries=1 --no-verbose --timeout=#{@timeout} --delete-after 127.0.0.1")
    assert_match /Connection timed out/, stderr
    
    
    # Terminate the Slow Loris attack thread.
    t.terminate
    # Stop all instances of running slo_lo.
    `pkill --full "../slo_lo.rb --target 127.0.0.1 --port 80"`
    
    # Test Apache server is running and taking requests successfully again.
    _, stderr, _ = Open3.capture3("curl --silent --show-error --retry 0 --max-time #{@timeout} 127.0.0.1")
    assert_no_match /Operation timed out/, stderr
    _, stderr, _ = Open3.capture3("wget --tries=1 --no-verbose --timeout=#{@timeout} --delete-after 127.0.0.1")
    assert_no_match /Connection timed out/, stderr
  end
end
