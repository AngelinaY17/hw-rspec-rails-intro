require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do

    before :each do
      @fake_results = [double('movie1'), double('movie2')]
      @search_params = {
        title: 'hardware',
        release_year: '1990',
        language: 'en'
      }
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).
        with(@search_params).
        and_return(@fake_results)

      get :search_tmdb, params: @search_params
    end

    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).
          and_return(@fake_results)

        get :search_tmdb, params: @search_params
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end

    it 'shows an error when the title is missing' do
      get :search_tmdb, params: {
        title: '',
        language: 'en'
      }

      expect(flash[:danger]).to eq(
        'Please fill in all required fields!'
      )
    end

    it 'shows a message when no movies are found' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])

      get :search_tmdb, params: @search_params

      expect(flash[:warning]).to eq(
        'No movies found with given parameters!'
      )
    end
  end

  describe 'adding a movie from TMDb' do
    it 'saves the movie and redirects to search' do
      movie_params = {
        title: 'Test Movie',
        rating: 'R',
        release_date: '2020-01-01',
        description: 'Test description'
      }

      expect {
        post :add_movie, params: {movie: movie_params}
      }.to change(Movie, :count).by(1)

      expect(response).to redirect_to(search_path)
      expect(flash[:success]).to eq(
        'Test Movie was successfully added to RottenPotatoes.'
      )
    end
  end
end