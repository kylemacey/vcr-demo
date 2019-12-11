class Hat
  attr_reader :fortunes

  def initialize
    @fortunes = 20.times.map { Fortune.new(Time.now) }
  end

  def random_fortune
    fortunes.sample
  end
end