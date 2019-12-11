class Fortune
  attr_reader :date, :parable, :weather

  def initialize(date)
    @date = date
    @parable = get_parable
    @weather = get_weather
  end

  def message
    @message ||= "It's #{formatted_date}\n#{parable}\n#{weather}"
  end

  private

  def get_parable
    open("http://yerkee.com/api/fortune") do |r|
      data = JSON.parse(r.read)
      return data["fortune"]
    end
  end

  def get_weather
    open("https://www.metaweather.com/api/location/2487956/") do |r|
      data = JSON.parse(r.read)
      temp = ["consolidated_weather"].first["the_temp"]
      return "#{temp}°C"
    end
  end

  def formatted_date
    date.strftime("%D")
  end
end