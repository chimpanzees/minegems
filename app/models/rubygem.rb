class Rubygem < ActiveRecord::Base
  has_many :versions
  validates_presence_of :name
  # before_validation :create_data_from_gemspec

  scope :by_name, lambda { |name|
    where("name = ?", name)
  }

  def self.create_version(file)
    Version.create_from_file(file).rubygem || new
  end

  def version(number)
    versions.first(:conditions => [ "versions.number = ?", number ])
  end

  private
    def create_data_from_gemspec
      self.name = name
      self.versions.build(:number => spec.try(:version).try(:version))
    end
end
