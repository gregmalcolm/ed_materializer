module Updater
  extend ActiveSupport::Concern
  
  included do
    before_validation :update_updaters
    
    scope :by_updater, ->(updater) { where("UPPER(TRIM(updater))=?", updater.to_s.upcase.strip ) if updater }
  end
  
  def creator
    updaters.first if updaters
  end

  private 

  def update_updaters
    self.updaters = [self.updater] if self.updaters.blank?

    unless self.updaters.include?(self.updater)
      self.updaters << self.updater
    end
  end
end
