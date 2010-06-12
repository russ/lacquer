class ResqueJob
  @queue = :lacquer

  def self.perform(command)
    VarnishInterface.send_command(command)
  end
end
