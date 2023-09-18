# frozen_string_literal: true

# This class represents a book entity.
class Book < ApplicationRecord
  enum sales_status: {
    reservation: 0,
    now_on_sale: 1,
    end_of_print: 2
  }

  belongs_to :publisher
  has_many :book_authors
  has_many :authors, through: :book_authors

  validates :name, presence: true
  validates :name, length: { maximum: 25 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :add_lovely_to_cat
  after_destroy do
    Rails.logger.info "Book is deleted: #{attributes}"
  end

  def add_lovely_to_cat
    self.name = name.gsub(/Cat/) do |matched|
      "lovely #{matched}"
    end
  end
end
