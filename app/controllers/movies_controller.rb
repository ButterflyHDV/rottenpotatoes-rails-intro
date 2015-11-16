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
      session[:ratings] = params[:ratings]
      @ratings = params[:ratings].is_a?(Hash) ? params[:ratings].keys : params[:ratings]
    elsif session[:ratings]
      flash.keep
      redirect_to movies_path(ratings: session[:ratings], order: params[:order]) and return
    else
      @ratings = @all_ratings
      session[:ratings] = @all_ratings
    end
    
    if params[:order]
      session[:order] = params[:order]
      @order = params[:order]
    elsif session[:order]
      flash.keep
      redirect_to movies_path(order: session[:order], ratings: params[:ratings]) and return
    else
      @order = "title"
      session[:order] = @order
    end
    
    @movies = Movie.order(@order).where('rating in (?)', @ratings)
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
