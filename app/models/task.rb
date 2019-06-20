class Task < ApplicationRecord
	belongs_to :partner, class_name: "Partner"
end
