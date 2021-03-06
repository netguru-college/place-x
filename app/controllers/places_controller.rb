# frozen_string_literal: true

class PlacesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_place, only: [:show, :edit, :update, :destroy]
  before_action :initialize_markers, only: [:index]
  autocomplete :tag, :name

  # GET /places
  # GET /places.json
  def index
    @places = Place.all
  end

  # GET /places/1
  # GET /places/1.json
  def show
    # no-op
  end

  # GET /places/new
  def new
    @place = Place.new
  end

  # GET /places/1/edit
  def edit
    # no-op
  end

  # POST /places
  # POST /places.json
  def create


    @place = Place.new(place_params.except(:tag_list))
    # binding.pry
    respond_to do |format|
      if @place.save
        @place.tag_list.add(place_params[:tag_list])
        @place.save
        format.html { redirect_to @place, notice: "Place was successfully created." }
        format.json { render :show, status: :created, location: @place }
      else
        format.html { render :new }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    # binding.pry
    respond_to do |format|
      if @place.update(place_params)
        @place.tag_list.add(place_params[:tag_list])
        @place.save
        format.html { redirect_to @place, notice: "Place was successfully updated." }
        format.json { render :show, status: :ok, location: @place }
      else
        format.html { render :edit }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place.destroy
    respond_to do |format|
      format.html { redirect_to places_url, notice: "Place was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def tags
    tags = ActsAsTaggableOn::Tag.where("lower(name) LIKE :prefix", prefix: "#{params[:q]}%")

    respond_to do |format|
      format.json { render json: tags }
    end
  end

  private

  def initialize_markers
    @markers = Gmaps4rails.build_markers(Place.all) do |place, marker|
      marker.lat place.lat
      marker.lng place.lng
      marker.infowindow place.name
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_place
    @place = Place.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def place_params
    params.require(:place).permit(:name, :description, :lat, :lng, :tag_list)

  end
end
