class ProcessWrapper
  attr_reader :pid, :state, :name, :path, :username, :cpu, :mem, :working_time

  STAT_ATTRIBUTES_MAPPING = {
    pid: 0,
    name: 1,
    state: 2,
    utime: 13,
    stime: 14,
    cutime: 15,
    cstime: 16,
    starttime: 21
  }.freeze

  def initialize stat, mem_total, page_size, uptime
    @stat      = stat
    @mem_total = mem_total * 1024

    @pid, @name, @state, @utime, @stime, @cutime, @cstime, @starttime = parse_stat

    @cmdline = File.open(['/proc/', @pid.to_i, '/cmdline'].join(''), 'r').each_line.first
    @statm   = File.open(['/proc/', @pid.to_i, '/statm'].join(''), 'r').each_line.first
    @mem = @statm.split(' ')[1].to_f * (page_size / 1024) / mem_total * 100
    
    @working_time = uptime - (@starttime / Process.clock_getres(1, :hertz))
    @username = figure_out_username
  end

  def calculate_cpu process_diff, cpu_diff
    @cpu = process_diff / cpu_diff * 100
  end

  def time
    @utime + @stime + @cutime + @cstime
  end

  def figure_out_username
    `uid=$(awk '/^Uid:/{print $2}' /proc/#{@pid}/status); getent passwd "$uid" | awk -F: '{print $1}'`.gsub("\n", '')
  end

  def parse_stat
    @stat
      .split(' ')
      .each_with_index
      .select { |k,v| STAT_ATTRIBUTES_MAPPING.values.include? v }
      .map(&:first)
      .map do |item|
        /[^\d]+/.match(item).nil? ? item.to_f : item
      end
  end
end