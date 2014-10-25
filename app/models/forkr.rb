class Forkr
  attr_reader :master_pid, :children, :inbound, :outbound, :child_count

  def initialize(forklet, num_kids = 3)
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
    master_loop
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

  def master_loop
    spawn_missing_workers
    loop do
      fds = IO.select([@inbound],nil,nil,2)
      unless fds.nil?
        data_read = fds.first.first.read(1)
        if data_read == "K"
          @in_shutdown = true
          raise StopIteration.new
        end
      end
      prune_workers
      spawn_missing_workers
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

  def spawn_missing_workers
    missing_amount = @child_count - @children.length
    if missing_amount > 0
      missing_amount.times do
        spawn_worker
      end
    end
  end

  def kill_all_workers
    @children.each { |c| kill_worker(c) }
  end

  def kill_worker(wpid)
    begin
      Process.kill(:KILL, wpid)
    rescue Errno::ESRCH
    end
  end

  def prune_workers
    @children = @children.reject { |pid| child_dead?(pid) }
  end

  def worker_loop
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
