class ProcessWrapper
  attr_reader :pid, :state, :name, :path, :username, :cpu, :mem

  STAT_ATTRIBUTES_MAPPING = {
    pid: 0,
    name: 1,
    state: 2,
    utime: 13,
    stime: 14,
    cutime: 15,
    cstime: 16
  }.freeze

  def initialize stat, cmdline
    @stat    = stat
    @cmdline = cmdline

    @pid, @name, @state, @utime, @stime, @cutime, @cstime = parse_stat
  end

  def calculate_cpu process_diff, cpu_diff
    @cpu = process_diff / cpu_diff * 100
  end

  def time
    @utime + @stime + @cutime + @cstime
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