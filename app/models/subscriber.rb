class Subscriber < ApplicationRecord
    validates :name, presence: true
    validates :email, presence: true, email: true
    validates_uniqueness_of :email, :case_sensitive => false
    validates :status, :inclusion => { :in => %w{active inactive} }
end
