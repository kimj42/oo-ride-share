require 'csv'
require 'time'

require_relative 'user'
require_relative 'trip'
require_relative 'driver'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(user_file = 'support/users.csv', trip_file = 'support/trips.csv', driver_file =  'support/drivers.csv')
      @passengers = load_users(user_file)
      @drivers = load_drivers(driver_file)
      @trips = load_trips(trip_file)
    end

    def load_users(filename)
      users = []

      CSV.read(filename, headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        users << User.new(input_data)
      end

      return users
    end


    def load_trips(filename)
      trips = []
      trip_data = CSV.open(filename, 'r', headers: true,
                                          header_converters: :symbol)

      trip_data.each do |raw_trip|
        passenger = find_passenger(raw_trip[:passenger_id].to_i)
        driver = find_driver(raw_trip[:driver_id].to_i)

        parsed_trip = {
          id: raw_trip[:id].to_i,
          driver: driver,
          passenger: passenger,
          start_time: Time.parse(raw_trip[:start_time]),
          end_time: Time.parse(raw_trip[:end_time]),
          cost: raw_trip[:cost].to_f,
          rating: raw_trip[:rating].to_i
        }

        trip = Trip.new(parsed_trip)
        passenger.add_trip(trip)
        driver.add_trip(trip)
        trips << trip
      end

      return trips
    end

    def load_drivers(filename)
      drivers = []

      CSV.read(filename, 'r', headers: true).each do |line|
        driver_data = {}

        driver_data[:id] = line[0].to_i
        driver_data[:vin] = line[1]
        driver_data[:status] = line[2].to_sym

        driver_data[:name] = find_passenger(line[0].to_i).name
        driver_data[:phone] = find_passenger(line[0].to_i).phone_number

        drivers << Driver.new(driver_data)
      end

      return drivers
    end

    def find_passenger(id)
      check_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end

    def find_driver(id)
      check_id(id)
      return @drivers.find { |driver| driver.id == id }
    end

    def inspect
      return "#<#{self.class.name}:0x#{self.object_id.to_s(16)} \
              #{trips.count} trips, \
              #{drivers.count} drivers, \
              #{passengers.count} passengers>"
    end

    private

    def check_id(id)
      raise ArgumentError, "ID cannot be blank or less than zero. (got #{id})" if id.nil? || id <= 0
    end

    def request_trip(user_id)
      new_user = find_passenger(user_id)
      driver = @driver.select {|driver| driver.status == :AVAILABLE}

      new_start_time = Time.now
      new_end_time = nil
      new_cost = nil
      new_rating = nil

      trip_data = {
          id: @trips.length + 1,
          driver: driver,
          passenger: new_user,
          start_time: new_start_time,
          end_time: new_end_time,
          cost: new_cost,
          rating: new_rating
        }

      trip = Trip.new(trip_data)
      driver.add_driven_trip(trip)

      driver.status = :UNAVAILABLE
      new_user.add_trip(trip)

      @trips << trip

      return trip
    end
  end
end
