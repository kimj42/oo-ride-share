require_relative 'spec_helper'
require_relative '../lib/driver'

describe "Driver class" do

  describe "Driver instantiation" do
    before do
      @driver = RideShare::Driver.new({id: 54, name: "Rogers Bartell IV",
        vin: "1C9EVBRM0YBC564DZ",
        phone: '111-111-1111',
        status: :AVAILABLE})
      end

      it "is an instance of Driver" do
        expect(@driver).must_be_kind_of RideShare::Driver
      end

      it "throws an argument error with a bad ID value" do
        expect{ RideShare::Driver.new(id: 0, name: "George", vin: "33133313331333133", status: :AVAILABLE)}.must_raise ArgumentError
      end

      it "throws an argument error with a bad VIN value" do
        expect{ RideShare::Driver.new(id: 100, name: "George", vin: "", status: :AVAILABLE)}.must_raise ArgumentError
        expect{ RideShare::Driver.new(id: 100, name: "George", vin: "33133313331333133extranums", status: :AVAILABLE)}.must_raise ArgumentError
      end

      it "sets trips to an empty array if not provided" do
        expect(@driver.driven_trips).must_be_kind_of Array
        expect(@driver.driven_trips.length).must_equal 0
      end

      it "is set up for specific attributes and data types" do
        [:id, :name, :vehicle_id, :status, :driven_trips].each do |prop|
          expect(@driver).must_respond_to prop
        end

        expect(@driver.id).must_be_kind_of Integer
        expect(@driver.name).must_be_kind_of String
        expect(@driver.vehicle_id).must_be_kind_of String
        expect(@driver.status).must_be_kind_of Symbol
      end
    end

    describe "add_driven_trip method" do
      before do
        start_time = "2018-05-25 11:30:00 -0700"
        end_time = "2018-05-25 11:40:00 -0700"
        pass = RideShare::User.new(id: 1, name: "Ada", phone: "412-432-7640")
        @driver = RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678", status: :AVAILABLE)
        @trip = RideShare::Trip.new({id: 8, driver: @driver, passenger: pass, start_time: Time.parse(start_time), end_time: Time.parse(end_time), cost: 10,  rating: 5})
      end

      it "throws an argument error if trip is not provided" do
        expect{ @driver.add_driven_trip(1) }.must_raise ArgumentError
      end

      it "increases the trip count by one" do
        previous = @driver.driven_trips.length
        @driver.add_driven_trip(@trip)
        expect(@driver.driven_trips.length).must_equal previous + 1
      end
    end

    describe "average_rating method" do
      before do
        start_time = "2018-05-25 11:20:00 -0700"
        end_time = "2018-05-25 11:30:00 -0700"
        @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
          vin: "1C9EVBRM0YBC564DZ", status: :AVAILABLE)

          trip = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil, start_time: Time.parse(start_time), end_time: Time.parse(end_time), cost: 15.0, rating: 5)

          @driver.add_driven_trip(trip)
        end

        it "returns a float" do
          expect(@driver.average_rating).must_equal 5.0
          expect(@driver.average_rating).must_be_kind_of Float
        end

        it "returns a float within range of 1.0 to 5.0" do
          average = @driver.average_rating
          expect(average).must_be :>=, 1.0
          expect(average).must_be :<=, 5.0
        end

        it "returns zero if no trips" do
          driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
            vin: "1C9EVBRM0YBC564DZ", status: :AVAILABLE)
            expect(driver.average_rating).must_equal 0
          end

          it "correctly calculates the average rating" do
            trip2 = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil,
              start_time: Time.parse("2018-04-25 11:20:00 -0700"), end_time: Time.parse("2018-04-25 11:30:00 -0700"), cost: 10.0, rating: 1)
              @driver.add_driven_trip(trip2)

              expect(@driver.average_rating).must_be_close_to (5.0 + 1.0) / 2.0, 0.01
            end


          end

          describe "total_revenue" do
            # You add tests for the total_revenue method
            before do
              start_time = "2018-05-25 11:20:00 -0700"
              end_time = "2018-05-25 11:30:00 -0700"
              @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                vin: "1C9EVBRM0YBC564DZ", status: :AVAILABLE)

                trip = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil, start_time: Time.parse(start_time), end_time: Time.parse(end_time), cost: 10.0, rating: 5)
                @driver.add_driven_trip(trip)

                trip2 = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil, start_time: Time.parse(start_time), end_time: Time.parse(end_time), cost: 5.0, rating: 5)
                @driver.add_driven_trip(trip2)
              end

              it "returns a float" do
                expect(@driver.total_revenue).must_be_kind_of Float
              end

              it "returns a zero if no trips provided" do
                driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                  vin: "1C9EVBRM0YBC564DZ", status: :AVAILABLE)

                  expect(driver.total_revenue).must_equal 0
                end

                it "correctly calculates the total revenue" do
                  expect(@driver.total_revenue).must_equal 9.36
                end
              end

              describe "net_expenditures" do
                before do
                  start_time = "2018-06-07 04:19:25 -0700"
                  end_time = "2018-06-07 04:20:47 -0700"

                  @driver = RideShare::Driver.new(id: 54, name: "Ada", vin: "1C9EVBRM0YBC564DZ", status: :AVAILABLE)

                  @driver1 = RideShare::Driver.new(id: 60, name: "Ada", vin: "1C9EVBRM0YBC564DZ", status: :AVAILABLE)

                  @user = RideShare::User.new(id: 54, name: "Ada", phone: "353-533-5334")

                  @user1 = RideShare::User.new(id: 55, name: "Ada", phone: "353-533-5334")

                  @trip_data = {
                    id: 8,
                    driver: @driver,
                    passenger: @user1,
                    start_time: Time.parse(start_time),
                    end_time: Time.parse(end_time),
                    cost: 100.00,
                    rating: 3
                  }

                  @trip = RideShare::Trip.new(@trip_data)

                  @driver.add_driven_trip(@trip)

                  @new_trip_data = {
                      id: 9,
                      driver:@driver1,
                      passenger: @user,
                      start_time: Time.parse("2018-06-06 04:12:00 -0700"),
                      end_time: Time.parse("2018-06-06 04:20:00 -0700"),
                      cost: 20.00,
                      rating: 3
                    }

                    trip = RideShare::Trip.new(@new_trip_data)

                    @driver.add_trip(trip)

                end

                it "calculates net expenditure for driver" do
                  expect(@driver.net_expenditures).must_be_close_to -58.68
                end
              end
            end
