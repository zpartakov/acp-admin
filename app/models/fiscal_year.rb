class FiscalYear
  def self.current(start_month = 1)
    new(Date.current, start_month)
  end

  def self.for(year, start_month = 1)
    date = Date.new(year, start_month)
    new(date, start_month)
  end

  def initialize(date, start_month = 1)
    @start_month = start_month
    @date = date
  end

  def beginning_of_year
    @date.beginning_of_year + months_diff
  end

  def end_of_year
    @date.end_of_year + months_diff
  end

  def range
    beginning_of_year..end_of_year
  end

  def year
    beginning_of_year.year
  end

  private

  def months_diff
    if @date.month < @start_month
      - (13 - @start_month).months
    else
      (@start_month - 1).months
    end
  end
end
