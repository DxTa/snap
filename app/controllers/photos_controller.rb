class PhotosController < ApplicationController
	# before_filter :signed_in_user
	before_filter :authenticated_user, only: [:facebook]

	def index
		store_location
		@photos = Photo.order("created_at DESC").paginate(page: params[:page],per_page: 15)
	end

	def new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def pc
    @photo=Photo.new
    store_location
  end

  def url
    @photo=Photo.new
    store_location
  end

  def facebook
    @photo=Photo.new
    token = current_user.authentications.find_by_provider('facebook').access_token

    client = FBGraph::Client.new(:client_id => GRAPH_APP_ID, :secret_id => GRAPH_SECRET, :token => token)
    @photos =client.selection.me.photos.limit(0).info!
    @photos = @photos.data.data.map(&:source)

    user =FbGraph::User.me(token)
    albums=user.albums.map(&:photos);
    albums.each do |album|
      uploaded_photos= album.collection
      uploaded_photos.each do |uploaded_photo|
        @photos << uploaded_photo[:source]
      end
    end
    @photos = @photos.paginate(page: params[:page],per_page: 10)
    store_location
  end

  def create
    if params[:photo][:remote_image_url] == ""
      params[:photo].delete("remote_image_url")
    elsif !params[:photo][:remote_image_url].nil? && params[:photo][:remote_image_url].index("http://#{Settings.hostname}/").nil?
      image = open(params[:photo][:remote_image_url])
      if image.is_a? StringIO
      else
        params[:photo][:image] = image
        params[:photo].delete("remote_image_url")
      end
    end

    @photo=Photo.new(params[:photo])
    if @photo.save
      @flashfacebook = "Upload new photo successfully"
      respond_to do |format|
        format.html { redirect_back_or params[:location]  }
        format.js
      end

    else
      @flashfacebook = "Upload failed"
      respond_to do |format|
        format.html { render 'pc' }
        format.js
      end
    end

  end

  def edit
    @photo=Photo.find(params[:id])
  end

  def update
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(params[:photo])
      flash[:success] = "Photo details updated"
      redirect_to boxes_path
    else
      render 'edit'
    end
  end

  def show
    @photo = Photo.find(params[:id])
    if @photo
      respond_to do |format|
        format.html
        format.js
      end
    else
      respond_to do |format|
        format.js { render "show_error" }
      end
    end
  end

  def destroy
    photo = Photo.find(params[:id])
    box = photo.box
    photo.destroy
    flash[:success] = "Photo deleted"
    redirect_back_or box_path(box)
  end

  def like_users
    photo = Photo.find(params[:id])
    @users = photo.like_users
  end

  def pon_users
    photo = Photo.find(params[:id])
    @users = photo.pon_users
  end

  def new_repin
    @repin = Photo.new
    @origin_photo = Photo.find(params[:id])
    @boxes = current_user.boxes
    respond_to do |format|
      format.js
    end
  end

  def repin
    @origin = Photo.find(params[:origin_photo_id])
    @box = Box.find(params[:box_id])
    @repin = @box.photos.new(name: @origin.name,description: params[:description],origin_id: @origin.id,image: @origin.image)
    if @repin.valid? && @origin.increase_repin_count
      if @repin.save
        respond_to do |format|
          format.html
          format.js
        end
      end
    end
  end

  def authenticated_user
    redirect_to root_path unless !current_user.authentications.find_by_provider('facebook').nil?
  end

end
