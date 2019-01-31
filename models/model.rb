#model.rb
class Subscription < ActiveRecord::Base
    self.table_name = "subscriptions"
end

class StagingSubscriptionUpdated < ActiveRecord::Base
    self.table_name = "staging_subscriptions_updated"
end