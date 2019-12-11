class Fortune
  attr_reader :date, :parable, :weather

  def initialize(date)
    @date = date
    @parable = get_parable
  end

  def message
    @message ||= "It's #{formatted_date}\n#{parable}"
  end

  private

  def get_parable
    type = %w{good bad ok}.sample
    "Today will be a #{type} day"
  end

  def formatted_date
    date.strftime("%D")
  end
end