require "pry"
require "json"
require "./process_wrapper"

class OS
  def initialize
    cpu_total_old = cpu_total
    processes_old = processes

    sleep 1

    cpu_total_new = cpu_total
    processes_new = processes

    cpu_total_diff = cpu_total_new - cpu_total_old

    @calculated_processes = processes_old.map do |process|
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
      .reduce(&:+)
  end

  def uptime
    @uptime ||= File.open('/proc/uptime', 'r').each_line.first.split(' ').first.to_f
  end

  def mem_total
    @mem_total ||= /(\d+)/.match(File.open('/proc/meminfo', 'r').each_line.first)[0].to_i
  end

  def page_size
    @statm_page_size ||= begin
      `getconf PAGESIZE`.to_i
    rescue
      4
    end
  end

  def pids
    @pids ||= Dir.foreach('/proc').reject { |dirname| dirname == '.' or dirname == '..' or /^\d+/.match(dirname).nil? }
  end

  def processes
    pids.map do |pid|
      begin
        ProcessWrapper.new File.open(['/proc/', pid, '/stat'].join(''), 'r').each_line.first, mem_total, page_size, uptime
      rescue
        nil
      end
    end.compact
  end

  def to_json
    @calculated_processes.map do |item|
      item.to_hash
    end.to_json  
  end
end