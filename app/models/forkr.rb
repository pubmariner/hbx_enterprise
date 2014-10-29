class Forkr
  attr_reader :master_pid, :children, :inbound, :outbound, :child_count

  def initialize(forklet, num_kids = 1)
    @worker_client = forklet 
    @master_pid = $$
    @children = []
    @child_count = num_kids
    @in_shutdown = false
  end

  def run
    @inbound, @outbound = IO.pipe
    Signal.trap('CHLD') { dead_child }
    Signal.trap('INT') { shutdown }
    Signal.trap('TERM') { shutdown }
    Signal.trap('TTIN') { add_worker }
    Signal.trap('TTOU') { remove_worker }
    master_loop
  end

  def add_worker
    return(nil) if $$ != master_pid
    return(nil) if @in_shutdown
    @outbound.write("+")
  end

  def remove_worker
    return(nil) if $$ != master_pid
    return(nil) if @in_shutdown
    @outbound.write("-")
  end

  def shutdown
    return(nil) if $$ != master_pid
    @outbound.write("K")
  end

  def dead_child
    return(nil) if $$ != master_pid
    return(nil) if @in_shutdown
    @outbound.write("D")
  end

  def spawn_worker
    if new_pid = fork
      @children << new_pid
    else
      worker_loop
    end
  end

  def increment_workers
    @child_count = @child_count + 1
  end

  def decrement_workers
    if @child_count > 1
      @child_count = @child_count - 1
    end
  end


  def master_loop
    ensure_right_worker_count
    loop do
      fds = IO.select([@inbound],nil,nil,2)
      unless fds.nil?
        data_read = fds.first.first.read(1)
        if data_read == "K"
          @in_shutdown = true
          raise StopIteration.new
        elsif data_read == "+"
          increment_workers
        elsif data_read == "-"
          decrement_workers
        end
      end
      prune_workers
      ensure_right_worker_count
    end
    kill_all_workers
    reap_all_workers
    @outbound.close
    @inbound.close
  end

  def reap_all_workers
    begin
      wpid, status = Process.waitpid2(-1, Process::WNOHANG)
    rescue Errno::ECHILD
      break
    end while true
  end

  def ensure_right_worker_count
    existing_workers = @children.length
    off_by = @child_count - @children.length
    if off_by > 0
      off_by.times do
        spawn_worker
      end
    elsif off_by < 0
      @children.take(off_by.abs).each do |kid|
        term_worker(kid)
      end
    end
  end

  def kill_all_workers
    @children.each { |c| kill_worker(c) }
  end

  def signal_worker(wpid, signal)
    begin
      Process.kill(signal, wpid)
    rescue Errno::ESRCH
    end
  end

  def term_worker(wpid)
    signal_worker(wpid, :TERM)
  end

  def kill_worker(wpid)
    signal_worker(wpid, :KILL)
  end

  def prune_workers
    @children = @children.reject { |pid| child_dead?(pid) }
  end

  def worker_loop
    @worker_client.after_fork if @worker_client.respond_to?(:after_fork)
    @inbound.close
    @outbound.close
    $stdout.puts "Worker spawned as #{$$}!"
    @worker_client.run
  end

  def child_dead?(pid)
    status = Process.waitpid(pid, Process::WNOHANG)
    unless status.nil?
      puts "Process #{pid} exit: #{status}"
    end
    !status.nil?
  end
end
