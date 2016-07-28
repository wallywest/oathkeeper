module OathKeeperSpecHelpers
  def enable_oathkeeper
    OathKeeper::Config.enabled = true
  end

  def disable_oathkeeper
    OathKeeper::Config.enabled = false
  end
end
