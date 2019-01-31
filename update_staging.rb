#update_staging.rb
require 'dotenv'
Dotenv.load
require 'httparty'
require 'resque'
require 'sinatra'
require 'active_record'
require "sinatra/activerecord"
require_relative 'models/model'
require_relative 'background_helper'
#require 'pry'

module FixStaging
  class SubUpdater
    def initialize
      Dotenv.load
      recharge_regular = ENV['RECHARGE_ACCESS_TOKEN']
      @sleep_recharge = ENV['RECHARGE_SLEEP_TIME']
      @my_header = {
        "X-Recharge-Access-Token" => recharge_regular
      }
      @my_change_charge_header = {
        "X-Recharge-Access-Token" => recharge_regular,
        "Accept" => "application/json",
        "Content-Type" =>"application/json"
      }
      
    end

    def generate_random_index(mylength)
      return_length = rand(5..mylength)
      return return_length

  end

    def update_staging
      #Fix Staging
      StagingSubscriptionUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('staging_subscriptions_updated')

      subs_update = "insert into staging_subscriptions_updated (subscription_id, address_id, customer_id, created_at, updated_at, next_charge_scheduled_at, cancelled_at, product_title, price, status, shopify_product_id, shopify_variant_id, sku, order_interval_unit, order_interval_frequency, charge_interval_frequency, order_day_of_month, order_day_of_week, raw_line_item_properties, synced_at, expire_after_specific_number_charges) select subscription_id, address_id, customer_id, created_at, updated_at, next_charge_scheduled_at, cancelled_at, product_title, price, status, shopify_product_id, shopify_variant_id, sku, order_interval_unit, order_interval_frequency, charge_interval_frequency, order_day_of_month, order_day_of_week, raw_line_item_properties, synced_at, expire_after_specific_number_charges from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at is null "

      ActiveRecord::Base.connection.execute(subs_update)


      my_update_subs = StagingSubscriptionUpdated.where("updated = ?", false)
      my_update_subs.each do |mysub|
        
        my_day_date = generate_random_index(28)
        if my_day_date < 10
          my_day_date = "0#{my_day_date}"
        end
        my_revised_date = "2019-02-#{my_day_date}"
        mysub.next_charge_scheduled_at = my_revised_date
        mysub.save!
        puts mysub.inspect
      end
      

    end

    def temp_fix_subs
      my_local_subs = Subscription.where("next_charge_scheduled_at = ?" nil)
      my_local_subs.each do |mysub|
        my_day_date = generate_random_index(28)
        if my_day_date < 10
          my_day_date = "0#{my_day_date}"
        end
        my_revised_date = "2019-02-#{my_day_date}"
        mysub.next_charge_scheduled_at = my_revised_date
        mysub.save!
        puts mysub.inspect


      end
      puts "Done updating temp fix all subs on staging"

    end


    def update_subscription_next_charge
      params = {"action" => "updating subscription next_charge_scheduled_at date", "recharge_change_header" => @my_change_charge_header}
      puts "Sending to background task"
      Resque.enqueue(UpdateSubscriptionNextCharge, params)
    end

    class UpdateSubscriptionNextCharge
      extend BackgroundHelper

      @queue = "subscription_next_charge"
      puts "Backgrounding now"
      def self.perform(params)
        # logger.info "UpdateSubscriptionProduct#perform params: #{params.inspect}"
        update_subscriptions_next_charge(params)
      end
    end


  end
end