class ApplicationController < ActionController::Base
	FACTORY = RGeo::Geographic.simple_mercator_factory
end
