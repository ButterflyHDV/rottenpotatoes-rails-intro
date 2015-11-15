class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.uniq.order(:rating).pluck(:rating)
    
    if params[:ratings]
      # user has given a selection
      session[:ratings] = params[:ratings]
      # using _ as placeholder for a value that you don't care about
      # stores and returns transformed hash to array
      @ratings = params[:ratings].inject([]) { |memo, (key,_)| memo << key }
    elsif session[:ratings]
    # if remember some ratings, redirect to movies index page with previous selection, and then stop, don't do anything further
    # if you specified an order, we will add that sorting as well
      redirect_to movies_path(ratings: session[:ratings], order: params[:order]) and return
    else
      @ratings = @all_ratings
    end
    
    @movies = Movie.order(params[:order]).where('rating in (?)', @ratings)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
