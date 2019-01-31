require 'dotenv'
Dotenv.load
require 'redis'
require 'resque'
Resque.redis = Redis.new(url: ENV['REDIS_URL'])
require 'active_record'
#require 'sinatra'
require 'sinatra/activerecord/rake'
require 'resque/tasks'
require_relative 'update_staging'
#require 'pry'

namespace :sub_update do
desc 'setup staging subs with no next_charge_scheduled_at'
task :setup_subs do |t|
    FixStaging::SubUpdater.new.update_staging
end

desc 'send subs to be updated with new next_charge_scheduled_at to background job'
task :background_subs do |t|
    FixStaging::SubUpdater.new.update_subscription_next_charge
end

desc 'temp fix to staging subs for null next_charge_scheduled_at'
task :temp_fix_subs do |t|
    FixStaging::SubUpdater.new.temp_fix_subs
end



end