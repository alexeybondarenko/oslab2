require "pry"

class OS
  def initialize
    cpu_total_old = cpu_total
    processes_old = processes

    sleep 1

    cpu_total_new = cpu_total
    processes_new = processes

    # utime - 14'th word in process string
    binding.pry
  end

  def cpu_total
    binding.pry
    File.open('/proc/stat', 'r')
      .each_line
      .reject { |l| /cpu /.match(l).nil?  }
      .first
      .split(" ")
      .map(&:to_i)
      .reduce(&:+)
  end

  def pids
    @pids ||= Dir.foreach('/proc').reject { |dirname| dirname == '.' or dirname == '..' or /^\d+/.match(dirname).nil? }
  end

  def processes
    pids.map do |pid|
      File.open(['/proc/', pid, '/stat'].join(''), 'r').each_line.first
    end
  end
end

OS.new.processes