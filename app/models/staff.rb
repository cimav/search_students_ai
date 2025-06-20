class Staff < ApplicationRecord

  def full_name
    "#{first_name} #{last_name}".strip.titleize
  end

  def short_name
    first = first_name.to_s.strip.split.first
    last = last_name.to_s.strip.split.first
    "#{first} #{last}".titleize
  end

end
