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
    open("http://yerkee.com/api/fortune") do |r|
      data = JSON.parse(r.read)
      return data["fortune"]
    end
  end

  def formatted_date
    date.strftime("%D")
  end
end