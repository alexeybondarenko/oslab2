require "pry"
require "./process_wrapper"

class OS
  def initialize
    cpu_total_old = cpu_total
    processes_old = processes

    sleep 1

    cpu_total_new = cpu_total
    processes_new = processes

    cpu_total_diff = cpu_total_new - cpu_total_old

    processes_old.map do |process|
      existing_process = processes_new.find { |p| p.pid == process.pid }

      if existing_process
        process.calculate_cpu (existing_process.time - process.time), cpu_total_diff
        process
      end
    end.compact
  end

  def cpu_total
    File.open('/proc/stat', 'r')
      .each_line
      .reject { |l| /cpu /.match(l).nil?  }
      .first
      .split(" ")
      .map(&:to_i)
      .reduce(:+)
  end

  def pids
    @pids ||= Dir.foreach('/proc').reject { |dirname| dirname == '.' or dirname == '..' or /^\d+/.match(dirname).nil? }
  end

  def processes
    pids.map do |pid|
      ProcessWrapper.new File.open(['/proc/', pid, '/stat'].join(''), 'r').each_line.first, File.open(['/proc/', pid, '/cmdline'].join(''), 'r').each_line.first
    end
  end
end

OS.new