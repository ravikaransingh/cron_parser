# frozen_string_literal: true

require 'time'

class CronParser
  attr_reader :minute, :hour, :day_of_month, :month, :day_of_week

  def initialize(expression)
    @expression = expression
    parse_expression
  end

  def next_times(count = 5)
    now = Time.now
    next_times = []

    count.times do
      # Calculate next execution time based on parsed expression
      next_time = calculate_next_time(now)
      next_times << next_time
      now = next_time + 1 # Move to the next second to avoid duplicate times
    end

    next_times
  end

  private

  def parse_expression
    fields = @expression.split
    raise ArgumentError, "Invalid cron expression: #{@expression}" unless fields.size == 5

    @minute = parse_field(fields[0], 0, 59)
    @hour = parse_field(fields[1], 0, 23)
    @day_of_month = parse_field(fields[2], 1, 31)
    @month = parse_field(fields[3], 1, 12)
    @day_of_week = parse_field(fields[4], 0, 6)
  end

  def parse_field(field, min_value, max_value)
    if field == '*'
      (min_value..max_value).to_a
    elsif field.include?(',')
      field.split(',').map { |part| parse_field(part, min_value, max_value) }.flatten.uniq.sort
    elsif field.include?('-')
      range = field.split('-').map(&:to_i)
      (range[0]..range[1]).to_a
    elsif field.include?('/')
      parts = field.split('/')
      start = parts[0].to_i
      step = parts[1].to_i
      (start..max_value).step(step).to_a
    else
      [field.to_i]
    end
  end

  def calculate_next_time(current_time)
    loop do
      current_time += 60  # Move to the next minute
      next_minute = current_time.min
      next_hour = current_time.hour
      next_day_of_month = current_time.day
      next_month = current_time.month
      next_day_of_week = current_time.wday

      return current_time if @minute.include?(next_minute) &&
                             @hour.include?(next_hour) &&
                             @day_of_month.include?(next_day_of_month) &&
                             @month.include?(next_month) &&
                             @day_of_week.include?(next_day_of_week)
    end
  end
end
