class World < ActiveRecord::Base
  include Updater
  has_paper_trail

  before_save :update_system

  belongs_to :system
  has_many :basecamps, dependent: :destroy
  has_one :world_survey, dependent: :destroy
  has_many :site_surveys, through: :basecamps

  scope :by_system_id,  ->(system_id) { where(system_id: system_id) if system_id }
  scope :by_system,     ->(system_name) { where("UPPER(TRIM(system_name))=?", 
                                                system_name.to_s.upcase.strip ) if system_name }
  scope :by_world,      ->(world)       { where("UPPER(TRIM(world))=?", 
                                                world.to_s.upcase.strip ) if world }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :updater, :system_name, :world, presence: true
  validate :key_fields_must_be_unique
  
  def has_children?
    world_survey.present? || basecamps.any?
  end

  def parent_system
    System.by_system(system_name).first
  end

  private

  def key_fields_must_be_unique
    if World.by_system(self.system_name)
            .by_world(self.world)
            .not_me(self.id)
            .any?
      errors.add(:world, "has already been taken for this system")
    end
  end

  def update_system
    parent = parent_system
    attributes = { system: self.system_name, updater: self.updater }
    if parent
      parent.update(attributes)
    else
      parent = System.create(attributes)
    end
    self.system_id = parent.id
  end
end

