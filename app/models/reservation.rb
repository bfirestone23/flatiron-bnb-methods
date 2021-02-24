class Reservation < ActiveRecord::Base
  belongs_to :listing
  belongs_to :guest, :class_name => "User"
  has_one :review

  validates :checkin, :checkout, presence: true
  validate :guest_and_host_not_the_same, :checkout_after_checkin, :available, :checkin_checkout_not_the_same

  def duration
    (checkout - checkin).to_i
  end

  def total_price
    listing.price * duration
  end

  private

  def guest_and_host_not_the_same
    if guest_id == listing.host_id
      errors.add(:guest_id, "You can't book your own apartment.")
    end
  end

  def checkout_after_checkin
    if checkin && checkout && checkout < checkin
      errors.add(:guest_id, "Your checkout date must be after your checkin date.")
    end
  end

  def checkin_checkout_not_the_same
    if checkin == checkout
      errors.add(:guest_id, "Your checkin and checkout dates must differ.")
    end
  end

  def available
    Reservation.where(listing_id: listing.id).where.not(id: id).each do |r|
      booked_dates = r.checkin..r.checkout
      if booked_dates === checkin || booked_dates === checkout
        errors.add(:guest_id, "Sorry, this listing isn't available for the selected dates.")
      end
    end
  end

end
