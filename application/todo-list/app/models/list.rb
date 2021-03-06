class List < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :tasks
  belongs_to :user

  after_initialize :update_state
  before_save :update_date

  def update_date()
    self.date ||= Date.today

    # All 'before_*' methods have to return true if they have to be applied.
    return true
  end

  def update_state()
    self.available = self.tasks.select { |task| !task.closed }.count > 0 || self.tasks.count == 0

    # All 'before_*' methods have to return true if they have to be applied.
    return true
  end

  def open!()
    self.available = true
  end

  def close!()
    self.available = false
  end

  def reopen!()
    self.tasks.each do |task|
      task.open!
      task.save!
    end

    self.save!
  end
end