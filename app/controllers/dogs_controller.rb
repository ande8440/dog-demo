class DogsController < ApplicationController
  before_action :set_dog, only: [:show, :edit, :update, :destroy, :like]
  before_action :verify_owner, only: [:edit]
  before_action :verify_not_owner, only: [:like]
  before_action :authenticate_user!, only: [:like, :edit, :update]

  # GET /dogs
  # GET /dogs.json
  def index
    @top_sort_active = false
    @active_tab = 'all'

    if params[:sort].to_s.downcase == 'top' && allowed_sort_times.include?(params[:t].to_s)
      @top_sort_active = true
      @active_tab = 'top'
      @dogs = Dog.by_likes(params[:t])

    else
      @dogs = Dog.all
    end

    @dogs = @dogs.paginate(page: params[:page])
  end

  # GET /dogs/1
  # GET /dogs/1.json
  def show
  end

  # GET /dogs/new
  def new
    @dog = Dog.new
  end

  # GET /dogs/1/edit
  def edit
  end

  # POST /dogs
  # POST /dogs.json
  def create
    @dog = Dog.new(dog_params)
    @dog.owner = current_user

    respond_to do |format|
      if @dog.save
        @dog.images.attach(params[:dog][:image]) if params[:dog][:image].present?

        format.html { redirect_to @dog, notice: 'Dog was successfully created.' }
        format.json { render :show, status: :created, location: @dog }
      else
        format.html { render :new }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dogs/1
  # PATCH/PUT /dogs/1.json
  def update
    respond_to do |format|
      if @dog.update(dog_params)
        @dog.images.attach(params[:dog][:image]) if params[:dog][:image].present?

        format.html { redirect_to @dog, notice: 'Dog was successfully updated.' }
        format.json { render :show, status: :ok, location: @dog }
      else
        format.html { render :edit }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dogs/1
  # DELETE /dogs/1.json
  def destroy
    @dog.destroy
    respond_to do |format|
      format.html { redirect_to dogs_url, notice: 'Dog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # /dogs/1/like
  def like
    if current_user.voted_up_on? @dog
      @dog.unliked_by current_user
    else
      @dog.liked_by current_user
    end

    render layout: false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dog
      @dog = Dog.find(params[:id])
    end

    def allowed_sort_times
      %w(hour day week month year)
    end

    #only allow edit of profile by dog owner
    def verify_owner
      if @dog && @dog.owner && @dog.owner != current_user
        redirect_to root_path
      end
    end

    #only allow certain actions by non owners
    def verify_not_owner
      unless current_user && @dog && @dog.owner != current_user
        redirect_to root_path
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dog_params
      params.require(:dog).permit(:name, :description, :owner_id, images: [])
    end
end