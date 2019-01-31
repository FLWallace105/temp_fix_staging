#background_helper.rb
require 'dotenv'
require 'active_support/core_ext'
require 'sinatra/activerecord'
require 'httparty'
require_relative 'models/model'
#require 'pry'

Dotenv.load

module BackgroundHelper

    def determine_limits(recharge_header, limit)
        puts "recharge_header = #{recharge_header}"
        my_numbers = recharge_header.split("/")
        my_numerator = my_numbers[0].to_f
        my_denominator = my_numbers[1].to_f
        my_limits = (my_numerator/ my_denominator)
        puts "We are using #{my_limits} % of our API calls"
        if my_limits > limit
            puts "Sleeping 15 seconds"
            sleep 15
        else
            puts "not sleeping at all"
        end
  
      end



    def update_subscriptions_next_charge(params)
        puts "Received params #{params.inspect}"
        recharge_change_header = params['recharge_change_header']
        

        my_now = Time.now

        my_update_subs = StagingSubscriptionUpdated.where("updated = ? ", false)
        my_update_subs.each do |mysub|
            puts mysub.inspect
            date_to_send_to_recharge = mysub.next_charge_scheduled_at.to_s.gsub(/\s.*/i, "")

            body = {"date" => date_to_send_to_recharge}.to_json
            puts body.inspect
            

            #POST /subscriptions/<subscription_id>/set_next_charge_date
            my_update_sub = HTTParty.post("https://api.rechargeapps.com/subscriptions/#{mysub.subscription_id}/set_next_charge_date",:headers => recharge_change_header, :body => body, :timeout => 80 )
            puts my_update_sub.inspect
            if my_update_sub.code == 200
                mysub.updated = true
                time_updated = DateTime.now
                time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
                mysub.updated_at = time_updated_str
                mysub.save!
                puts "processed subscription_id #{mysub.subscription_id}"
            else
                
                puts "Cannot process subscription_id #{mysub.subscription_id}"
            end


            exit

            #recharge_limit = my_update_sub.response["x-recharge-limit"]

            my_current = Time.now
            duration = (my_current - my_now).ceil
            puts "Been running #{duration} seconds"
      

            if duration > 480
                puts "Been running more than 8 minutes must exit"
                break
            end

        end

        puts "All done"
    
    end



end
