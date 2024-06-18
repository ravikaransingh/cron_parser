# cron_parser


# Example usage:
cron_expression = "*/15 * * * *"

parser = CronParser.new(cron_expression)

next_times = parser.next_times(5)

puts "Next 5 execution times for '#{cron_expression}':"


next_times.each { |time| puts time }


