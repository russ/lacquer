class DelayedJobJob < Struct.new(:command)
  def perform
    VarnishInterface.send_command(command)
  end
end
